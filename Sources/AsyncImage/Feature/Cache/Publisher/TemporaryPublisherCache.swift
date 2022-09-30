//
//  TemporaryPublisherCache.swift
//  
//
//  Created by Marc Biosca on 9/29/22.
//

import Combine
import UIKit

final class TemporaryPublisherCache: PublisherCache {
    private var cache = [String: UIImageErrorPublisher]()
    private let concurrentQueue = DispatchQueue(label: "temporary-publisher", attributes: .concurrent)
    
    func set(_ value: UIImageErrorPublisher?, for key: String) {
        self.concurrentQueue.async(flags: .barrier) { [weak self] in
            self?.cache[key] = value
        }
    }
    
    func get(_ key: String) -> UIImageErrorPublisher? {
        self.concurrentQueue.sync {
            return self.cache[key]
        }
    }
}
