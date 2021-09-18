//
//  resizedImageSceneDelegate.swift
//  resizedImageSceneDelegate
//
//  Created by Jared Kozar on 9/18/21.
//

import UIKit

class resizedImageSceneDelegate: UIResponder, UIWindowSceneDelegate {
     
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            let presetView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Detail")
            window.rootViewController = presetView
            self.window = window
            window.makeKeyAndVisible()
        }
        
    }
}
