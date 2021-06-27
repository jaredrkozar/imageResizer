//
//  Images.swift
//  imageResizer
//
//  Created by Jared Kozar on 6/6/21.
//

import UIKit

class Images: NSObject {

    var dimensions: String = ""
    var image: UIImage
    
    init(dimensions: String, image: UIImage) {
        self.dimensions = dimensions
        self.image = image
    }
}
