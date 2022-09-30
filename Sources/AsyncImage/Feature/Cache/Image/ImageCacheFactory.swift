//
//  ImageCacheFactory.swift
//  
//
//  Created by Marc Biosca on 9/29/22.
//

public enum ImageCacheFactory {
    public static func makeTemporaryCache() -> ImageCache {
        TemporaryImageCache()
    }
}
