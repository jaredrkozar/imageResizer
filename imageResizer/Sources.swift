//
//  Sources.swift
//  Sources
//
//  Created by Jared Kozar on 9/20/21.
//

import UIKit

enum Sources: CaseIterable {
    case scandoc
    case camera
    case photolibrary
    case files
    case url
    
    var icon: UIImage {
        let config = UIImage.SymbolConfiguration(font: UIFont.preferredFont(forTextStyle: .title1))
        
        switch self {
            case .scandoc:
            return UIImage(systemName: "doc.text.viewfinder", withConfiguration: config)!
            case .camera:
            return UIImage(systemName: "camera", withConfiguration: config)!
            case .photolibrary:
            return UIImage(systemName: "photo", withConfiguration: config)!
            case .files:
            return UIImage(systemName: "folder", withConfiguration: config)!
            case .url:
            return UIImage(systemName: "link", withConfiguration: config)!
                
        }
    }
    
    var title: String {
        
        switch self {
            case .scandoc:
                return "Scan Document"
            case .camera:
                return "Camera"
            case .photolibrary:
                return "Photo Library"
            case .files:
                return "Files"
            case .url:
                return "URL"
        }
    }
}
