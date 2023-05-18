//
//  Extensions.swift
//  imageResizer
//
//  Created by Jared Kozar on 8/2/21.
//

import UIKit
import Foundation
import AVFoundation

var presets = [Preset]()
var currentDevice: String?

let vc = ViewController()

public var selectedSource: String = ""

public var imageDetails = [UIImage]()

public var layout: UICollectionViewFlowLayout = {
   let layout = UICollectionViewFlowLayout()
    layout.estimatedItemSize = CGSize(width: 230, height: 230)
    layout.itemSize = CGSize(width: 230, height: 230)
    return layout
}()
extension String {
    func getHeightWidth() -> (Int, Int) {
        let HeightWidthArr = self.components(separatedBy: " x ")
        
        let heightnum = Int(HeightWidthArr[0])!
        let widthnum = Int(HeightWidthArr[1])!
        return (widthnum, heightnum)
    }
}

extension UIImage {
    
    func resizeImage(dimension: String, maintainAspectRatio: Bool) -> UIImage {

        var size = CGSize()
        let splitDimension = dimension.getHeightWidth()
        
        if maintainAspectRatio == true {
            size = AVMakeRect(aspectRatio: self.size, insideRect: CGRect(origin: .zero, size: CGSize(width: splitDimension.0, height: splitDimension.1))).size
        } else {
            size = CGSize(width: splitDimension.0, height: splitDimension.1)
        }
        
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { (context) in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

extension Array where Element == Preset {
    func save() {
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
