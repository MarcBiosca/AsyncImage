//
//  PublisherCacheFactory.swift
//  
//
//  Created by Marc Biosca on 9/29/22.
//

public enum PublisherCacheFactory {
    public static func makeTemporaryCache() -> PublisherCache {
        TemporaryPublisherCache()
    }
}
