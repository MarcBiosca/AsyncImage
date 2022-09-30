//
//  StringExtension.swift
//  
//
//  Created by Marc Biosca on 9/29/22.
//

import Foundation

public extension String {
    var urlRequest: URLRequest? {
        guard let url = URL(string: self) else { return nil }
        
        return URLRequest(url: url)
    }
}
