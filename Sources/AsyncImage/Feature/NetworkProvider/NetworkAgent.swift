//
//  URLProtocolMock.swift
//
//
//  Created by Marc Biosca on 9/29/22.
//

import Combine
import Foundation
import UIKit

final class NetworkAgent: NetworkAgentProtocol {
    private let configuration: NetworkConfiguration
    
    init(with configuration: NetworkConfiguration = NetworkConfiguration()) {
        self.configuration = configuration
    }
    
    func run<T: Decodable>(_ request: URLRequest?, decode: T.Type) -> GenericErrorPublisher<T> {
        self.basePublisher(from: request)
            .decode(type: T.self, decoder: self.configuration.decoder)
            .eraseToAnyPublisher()
    }
    
    func download(from request: URLRequest?) -> UIImageErrorPublisher {
        self.basePublisher(from: request)
            .compactMap { UIImage(data: $0) }
            .eraseToAnyPublisher()
    }
}

private extension NetworkAgent {
    typealias DataErrorPublisher = AnyPublisher<Data, Error>
    
    func basePublisher(from request: URLRequest?) -> DataErrorPublisher {
        Just(())
            .tryMap { () -> URLRequest in
                guard let urlRequest = request else { throw URLError(.badURL) }
       
                return urlRequest
            }
            .flatMap {
                return self.configuration.session
                    .dataTaskPublisher(for: $0)
                    .tryMap { result -> Data in
                        guard let httpResponse = result.response as? HTTPURLResponse,
                              (200..<300).contains(httpResponse.statusCode) else {
                            throw URLError(.badServerResponse)
                        }
                        
                        return result.data
                    }
                    .retry(self.configuration.retries)
            }
            .eraseToAnyPublisher()
    }
}
