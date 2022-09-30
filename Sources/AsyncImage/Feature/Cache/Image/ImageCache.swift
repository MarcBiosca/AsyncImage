//
//  ImageCache.swift
//  
//
//  Created by Marc Biosca on 9/29/22.
//

import UIKit

public protocol ImageCache {
    subscript(_ url: URL) -> UIImage? { get set }
}
