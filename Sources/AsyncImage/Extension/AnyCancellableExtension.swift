//
//  AnyCancellableExtension.swift
//  
//
//  Created by Marc Biosca on 9/29/22.
//

import Combine

extension AnyCancellable {
    func keep(in publisher: inout AnyCancellable?) {
        publisher = self
    }
}
