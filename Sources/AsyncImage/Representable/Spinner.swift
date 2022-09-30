//
//  Spinner.swift
//  
//
//  Created by Marc Biosca on 9/29/22.
//

import SwiftUI
import UIKit

struct Spinner: UIViewRepresentable {
    let animating: Bool
    let style: UIActivityIndicatorView.Style
    let color: UIColor
    
    init(animating: Bool, style: UIActivityIndicatorView.Style, color: UIColor) {
         self.animating = animating
         self.style = style
         self.color = color
     }
    
    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let spinner = UIActivityIndicatorView(style: self.style)
        spinner.hidesWhenStopped = true
        spinner.color = self.color
        
        return spinner
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        self.animating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}
