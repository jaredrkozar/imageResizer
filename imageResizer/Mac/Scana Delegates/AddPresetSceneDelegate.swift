//
//  AddPresetSceneDelegate.swift
//  AddPresetSceneDelegate
//
//  Created by Jared Kozar on 9/19/21.
//

import UIKit

class AddPresetSceneDelegate: UIResponder, UIWindowSceneDelegate {
     
#if targetEnvironment(macCatalyst)
var toolbarDelegate: NSToolbarDelegate?
#endif

    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        #if targetEnvironment(macCatalyst)
        toolbarDelegate = addPresetToolbarDelegate()
        let toolbar = NSToolbar(identifier: "main")
        toolbar.delegate = toolbarDelegate
        toolbar.displayMode = .iconOnly
        toolbar.allowsUserCustomization = true
        toolbar.autosavesConfiguration = true
        toolbar.showsBaselineSeparator = false

        if isEditingDimension == true {
            windowScene.title = "Edit Preset"
        } else {
            windowScene.title = "Add Preset"
        }
        
        if let titlebar = windowScene.titlebar {
            titlebar.toolbar = toolbar
            titlebar.toolbarStyle = .unified
            titlebar.separatorStyle = .shadow
        }
        #endif
        
        
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            let addPreset = AddPresetViewController()
    
            window.rootViewController = addPreset
            
            windowScene.sizeRestrictions?.minimumSize = CGSize(width: 375, height: 190)
            
            self.window = window
            window.makeKeyAndVisible()
        }
    }
}


#if targetEnvironment(macCatalyst)
extension NSToolbarItem.Identifier {
    static let savePreset = NSToolbarItem.Identifier("com.jkozar.imageResizer.savePreset")
}

class addPresetToolbarDelegate: NSObject {
}

extension addPresetToolbarDelegate: NSToolbarDelegate {
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        let identifiers: [NSToolbarItemGroup.Identifier] = [
            .savePreset
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
            case .savePreset:
                item.image = UIImage(systemName: "checkmark.circle")
                item.label = "Save Preset"
            item.action = #selector(AddPresetViewController.savePresetButtonTapped(_:))
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


