//
//  CusstomTextField.swift
//  imageResizer
//
//  Created by Jared Kozar on 5/19/23.
//

import UIKit

class CusstomTextField: UITextField {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.textAlignment = .center
        self.translatesAutoresizingMaskIntoConstraints = false
        self.layer.backgroundColor = UIColor.systemGray4.cgColor
        self.font = UIFont.preferredFont(forTextStyle: .title3, compatibleWith: nil)
        self.layer.cornerRadius = 7.0
        self.keyboardType = .numberPad
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
