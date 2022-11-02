//
//  TemporaryImageCache.swift
//  
//
//  Created by Marc Biosca on 9/29/22.
//

import Foundation
import UIKit

final class TemporaryImageCache: ImageCache {
    // To facilitate integrations
    static let shared = TemporaryImageCache()
    
    private let cache = NSCache<NSURL, UIImage>()
    
    init() {
        self.cache.totalCostLimit = 1024 * 1024 * 100
        self.cache.countLimit = 100
    }
    
    subscript(_ key: URL) -> UIImage? {
        get {
            self.cache.object(forKey: key as NSURL)
        }
        set {
            newValue == nil ? self.cache.removeObject(forKey: key as NSURL) : self.cache.setObject(newValue!, forKey: key as NSURL)
        }
    }
}
