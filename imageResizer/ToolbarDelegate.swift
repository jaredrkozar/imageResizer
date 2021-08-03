//
//  ToolbarDelegate.swift
//  imageResizer
//
//  Created by Jared Kozar on 8/3/21.
//


import UIKit

class ToolbarDelegate: NSObject {
    #if targetEnvironment(macCatalyst)
    var shareRecipe: NSSharingServicePickerToolbarItem?
    #endif
}

#if targetEnvironment(macCatalyst)
extension NSToolbarItem.Identifier {
    static let addImage = NSToolbarItem.Identifier("com.jkozar.imageResizer.addImage")
}

extension ToolbarDelegate: NSToolbarDelegate {
    
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        let identifiers: [NSToolbarItem.Identifier] = [
            .addImage
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
        
        switch itemIdentifier {
            
        case .addImage:
            let item = NSMenuToolbarItem(itemIdentifier: itemIdentifier)
            item.itemMenu = UIMenu(title: "JJJ", image: UIImage(systemName: "ellipsis.circle"), identifier: .window, options: [], children: [UICommand(title: "Camera", action: #selector(ViewController.presentCamera)),
                                                                                                                                                           UICommand(title: "Photo Library", action: #selector(ViewController.presentPhotoPicker)),
                                                                                                                                                           UICommand(title: "URL", action: #selector(ViewController.presentURLPicker))
                                                                                                                                                          ])
                    item.image = UIImage(systemName: "plus")
                    return item
        
        default:
            toolbarItem = nil
        }
        
        return toolbarItem
    }

    
}
#endif

