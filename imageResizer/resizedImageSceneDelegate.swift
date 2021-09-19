//
//  resizedImageSceneDelegate.swift
//  resizedImageSceneDelegate
//
//  Created by Jared Kozar on 9/18/21.
//

import UIKit

class resizedImageSceneDelegate: UIResponder, UIWindowSceneDelegate {
     
#if targetEnvironment(macCatalyst)
var toolbarDelegate: NSToolbarDelegate?
#endif

    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        #if targetEnvironment(macCatalyst)
        toolbarDelegate = resizedImagesToolbarDelegate()
        let toolbar = NSToolbar(identifier: "main")
        toolbar.delegate = toolbarDelegate
        toolbar.displayMode = .iconOnly
        toolbar.allowsUserCustomization = true
        toolbar.autosavesConfiguration = true
        toolbar.showsBaselineSeparator = false

        windowScene.title = "Resized Images"

        if let titlebar = windowScene.titlebar {
            titlebar.toolbar = toolbar
            titlebar.toolbarStyle = .unified
            titlebar.separatorStyle = .shadow
        }
        #endif
        
        
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            let detailView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Detail")
            window.rootViewController = detailView
            self.window = window
            window.makeKeyAndVisible()
        }
       
    }
}


#if targetEnvironment(macCatalyst)
extension NSToolbarItem.Identifier {
    static let shareImages = NSToolbarItem.Identifier("com.jkozar.imageResizer.shareImages")
}

class resizedImagesToolbarDelegate: NSObject {
}

extension resizedImagesToolbarDelegate: NSToolbarDelegate {
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        let identifiers: [NSToolbarItemGroup.Identifier] = [
            .shareImages
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
        let item = NSToolbarItem(itemIdentifier: itemIdentifier)
        item.isBordered = true
        item.target = nil
        switch itemIdentifier {
            case .shareImages:
                item.image = UIImage(systemName: "square.and.arrow.up")
                item.label = "Share Images"
            item.action = #selector(resizedImagesController.shareButtonTapped(_:))
                toolbarItem = item
            default:
                toolbarItem = nil
        }
        item.toolTip = item.label
        item.autovalidates = true
        return toolbarItem
    }
    
}

#endif

