//
//  NetworkAgentProtocol.swift
//  
//
//  Created by Marc Biosca on 9/29/22.
//

import Combine
import UIKit

public typealias UIImageErrorPublisher = AnyPublisher<UIImage, Error>
public typealias GenericErrorPublisher<T> = AnyPublisher<T, Error>

public protocol NetworkAgentProtocol {
    func run<T: Decodable>(_ request: URLRequest?, decode: T.Type) -> GenericErrorPublisher<T>
    func download(from request: URLRequest?) -> UIImageErrorPublisher
}
