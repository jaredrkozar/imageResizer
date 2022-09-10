//
//  CustomButton.swift
//  imageResizer
//
//  Created by Jared Kozar on 9/7/22.
//

import UIKit

class StandardButton: UIButton {
    override func draw(_ rect: CGRect) {
        #if !targetEnvironment(macCatalyst)
            self.layer.masksToBounds = true
            self.layer.cornerCurve = .continuous
            self.layer.cornerRadius = 7.0
        self.layer.backgroundColor = UIColor.systemBlue.cgColor
            self.setTitleColor(.white, for: .normal)
        #endif
    }
}
