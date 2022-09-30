//
//  ImageState.swift
//  
//
//  Created by Marc Biosca on 9/29/22.
//

import SwiftUI

enum ImageState {
    case empty
    case success(UIImage)
    case failure(Error)
    
    var image: UIImage? {
        guard case .success(let image) = self else { return nil }
        
        return image
    }
    
    var error: Error? {
        guard case .failure(let error) = self else { return nil }
        
        return error
    }
    
    var loading: Bool {
        guard case .empty = self else { return false }
        
        return true
    }
}
