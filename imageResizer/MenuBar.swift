//
//  MenuBar.swift
//  MenuBar
//
//  Created by Jared Kozar on 9/19/21.
//

import UIKit

extension AppDelegate {
  override func buildMenu(with builder: UIMenuBuilder) {
      
      guard builder.system == .main else { return }
        // First remove the menus in the menu bar that are not needed, in this case the Format menu.
        builder.remove(menu: .format)
        
        // Adds import commands and keyboard shorcuts to the file menu
        builder.insertChild(addPresets(), atStartOfMenu: .file)
      builder.insertChild(importMenu(), atEndOfMenu: .file)
      
    }
        
    func importMenu() -> UIMenu {
        let cameracommand =
            UIKeyCommand(title: "Import from Camera",
                         image: nil,
                         action: #selector(ViewController.presentCamera),
                         input: "C",
                         modifierFlags: .command,
                         propertyList: nil)
        
        let photosCommand =
            UIKeyCommand(title: "Import from Photos Library",
                         image: nil,
                         action: #selector(ViewController.presentPhotoPicker),
                         input: "P",
                         modifierFlags: .command,
                         propertyList: nil)
        
        let urlCommand =
            UIKeyCommand(title: "Import from URL",
                         image: nil,
                         action: #selector(ViewController.presentURLPicker),
                         input: "U",
                         modifierFlags: .command,
                         propertyList: nil)
        
        let openMenu =
            UIMenu(title: "",
                   image: nil,
                   identifier: UIMenu.Identifier("com.example.apple-samplecode.menus.openMenu"),
                   options: .displayInline,
                   children: [cameracommand, photosCommand, urlCommand])
        return openMenu
    }
    
    func addPresets() -> UIMenu {
        
        let addPreset =
            UIKeyCommand(title: "Add Preset",
                         image: nil,
                         action: #selector(ViewController.addPresetButton(_:)),
                         input: "P",
                         modifierFlags: [.command],
                         propertyList: nil)
        addPreset.discoverabilityTitle = "Add New Preset"
        
        let openMenu =
            UIMenu(title: "",
                   image: nil,
                   identifier: UIMenu.Identifier("com.example.apple-samplecode.menus.openMenu"),
                   options: .displayInline,
                   children: [addPreset])
        return openMenu
        
    }
}
