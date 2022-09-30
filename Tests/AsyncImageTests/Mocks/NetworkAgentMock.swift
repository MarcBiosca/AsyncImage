//
//  NetworkAgentMock.swift
//  
//
//  Created by Marc Biosca on 9/29/22.
//

import AsyncImage
import Combine
import UIKit

class NetworkAgentMock: NetworkAgentProtocol {
    var image = UIImage(systemName: "camera")!
    var networkCalls = 0
    
    func run<T>(_ request: URLRequest?, decode: T.Type) -> GenericErrorPublisher<T> where T : Decodable {
        self.networkCalls += 1
        
        return Just(())
            .tryMap { T.self as! T }
            .eraseToAnyPublisher()
    }
    
    func download(from request: URLRequest?) -> UIImageErrorPublisher {
        self.networkCalls += 1
        
        return Just(())
            .tryMap { self.image }
            .eraseToAnyPublisher()
    }
}
