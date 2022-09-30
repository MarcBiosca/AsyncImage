//
//  TemporaryImageCacheMock.swift
//  
//
//  Created by Marc Biosca on 9/29/22.
//

import AsyncImage
import UIKit

class TemporaryImageCacheMock: ImageCache {
    var cache = [URL: UIImage]()
    var cacheReturned = 0
    
    subscript(url: URL) -> UIImage? {
        get {
            self.cacheReturned += 1
            
            return self.cache[url]
        }
        set(newValue) {}
    }
}
