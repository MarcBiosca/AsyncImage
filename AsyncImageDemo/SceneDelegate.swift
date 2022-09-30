//
//  SceneDelegate.swift
//  AsyncImageDemo
//
//  Created by Marc Biosca on 9/29/22.
//

import SwiftUI
import AsyncImage

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let globalImageCache = ImageCacheFactory.makeTemporaryCache()
            
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView(
            imageCache: globalImageCache
        )

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            
            self.window = window
            window.makeKeyAndVisible()
        }
    }
}
