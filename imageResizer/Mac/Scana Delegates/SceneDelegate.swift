//
//  SceneDelegate.swift
//  imageResizer
//
//  Created by Jared Kozar on 5/26/21.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    #if targetEnvironment(macCatalyst)
    var toolbarDelegate: NSToolbarDelegate?
    #endif

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }

        
        #if targetEnvironment(macCatalyst)
        currentDevice = "Mac"
        toolbarDelegate = MainToolbarDelegate()
        let toolbar = NSToolbar(identifier: "main")
        toolbar.delegate = toolbarDelegate
        toolbar.displayMode = .iconOnly
        toolbar.allowsUserCustomization = true
        toolbar.autosavesConfiguration = true
        toolbar.showsBaselineSeparator = false

        windowScene.title = "imageResizer"

        if let titlebar = windowScene.titlebar {
            titlebar.toolbar = toolbar
            titlebar.toolbarStyle = .unified
            titlebar.separatorStyle = .shadow
        }
        
        #else
            currentDevice = "iPad"
        #endif
        
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            let navController = UINavigationController(rootViewController: ViewController())
            window.rootViewController = navController
            
            self.window = window
            window.makeKeyAndVisible()
        }
        
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}

#if targetEnvironment(macCatalyst)
extension NSToolbarItem.Identifier {
    static let addImage = NSToolbarItem.Identifier("com.jkozar.imageResizer.addImage")
    static let resizeImage = NSToolbarItem.Identifier("com.jkozar.imageResizer.resizeImage")
}

class MainToolbarDelegate: NSObject {
}

extension MainToolbarDelegate: NSToolbarDelegate {
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        let identifiers: [NSToolbarItemGroup.Identifier] = [
            .addImage,
            .resizeImage,
        ]
        return identifiers
    }
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return toolbarDefaultItemIdentifiers(toolbar)
    }
    
    func toolbar(_ toolbar: NSToolbar,
                 itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
                 willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        var toolbarItem: NSToolbarItem?
        let item = NSMenuToolbarItem(itemIdentifier: itemIdentifier)
        
        item.isBordered = true
        item.target = nil
        
        switch itemIdentifier {
            case .addImage:
            item.itemMenu = UIMenu(title: "JJJ", image: UIImage(systemName: "ellipsis.circle"), identifier: .window, options: [], children: [UICommand(title: "Camera", action: #selector(ViewController.presentCamera)),
                                                                                                                                                 UICommand(title: "Photo Library", action: #selector(ViewController.presentPhotoPicker)),
                                                                                                                                                 UICommand(title: "URL", action: #selector(ViewController.presentURLPicker))
                                                                                                                                                ])
              item.image = UIImage(systemName: "plus")
              return item
        case .resizeImage:
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
            item.image = UIImage(systemName: "arrow.up.right.and.arrow.down.left.rectangle")
            item.label = "Resize Image"
            item.action = #selector(ViewController.resizeButtonTapped(_:))
            item.isBordered = true
            return item
        default:
            toolbarItem = nil
        }
        item.toolTip = item.label
        item.autovalidates = true
        return toolbarItem
    }
}

#endif

