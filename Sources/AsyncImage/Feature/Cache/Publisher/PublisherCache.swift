//
//  PublisherCache.swift
//  
//
//  Created by Marc Biosca on 9/29/22.
//

public protocol PublisherCache {
    func set(_ value: UIImageErrorPublisher?, for key: String)
    func get(_ key: String) -> UIImageErrorPublisher?
}
