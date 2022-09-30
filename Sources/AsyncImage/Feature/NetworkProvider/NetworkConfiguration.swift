//
//  NetworkConfiguration.swift
//  
//
//  Created by Marc Biosca on 9/29/22.
//

import Foundation

public struct NetworkConfiguration {
    internal let session: URLSession
    internal let retries: Int
    internal let decoder: JSONDecoder
    
    public init(
        session: URLSession = .shared,
        decoder: JSONDecoder = .init(),
        retries: Int = 2
    ) {
        self.session = session
        self.retries = retries
        self.decoder = decoder
    }
}
