//
//  Extensions.swift
//  imageResizer
//
//  Created by Jared Kozar on 8/2/21.
//

import UIKit
import Foundation
var isEditingDimension: Bool = false

var presets = [Preset]()

let vc = ViewController()

public var dimensionwidth: String = ""
public var dimensionheight: String = ""
public var selectedSource: String = ""

public var imageDetails: [Images] {
    //saves the color, for use throughout the app
    get{
        return vc.imageArray
    }
    set{
        vc.imageArray = newValue
    }
}

extension UIImage {
    
    func resizeImageWithoutAspectRatio(dimension: String) -> UIImage {
        let HeightWidthArr = dimension.components(separatedBy: " x ")
        
        let heightnum = Double(HeightWidthArr[0])! / 2
        let widthnum = Double(HeightWidthArr[1])! / 2
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: widthnum, height: heightnum), false, 0.0)
        self.draw(in: CGRect(x: 0, y: 0, width: widthnum, height: heightnum))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
        
    func resizeImageWithAspectRatio(dimension: String) -> UIImage {
        
        let HeightWidthArr = dimension.components(separatedBy: " x ")
        
        let heightnum = Double(HeightWidthArr[0])!
        let widthnum = Double(HeightWidthArr[1])!

        let widthRatio  = widthnum  / Double(self.size.width)
        let heightRatio = heightnum / Double(self.size.height)

        
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: Double(self.size.width) * heightRatio, height: Double(Int(self.size.height)) * heightRatio)
        } else {
            newSize = CGSize(width: Double(self.size.width) * widthRatio, height: Double(self.size.height) * widthRatio)
        }
        CGSize(width: Double(self.size.width) * heightRatio, height: Double(Int(self.size.height)) * heightRatio)
        
        //creates a new image based off of the dimensions found above
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}

extension Array where Element == Preset {
    func save() {
        print(self.count)
        if let savedData = try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "presets")
        }
    }
    
    mutating func load() -> [Preset] {
        if let savedPresets = UserDefaults.standard.object(forKey: "presets") as? Data {
            if let decodedPresets = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedPresets) as? [Preset] {
                self = decodedPresets
            }
        }
        return self
    }
}
