//
//  ImageCell.swift
//  imageResizer
//
//  Created by Jared Kozar on 6/6/21.
//

import UIKit

class ImageCell: UICollectionViewCell {
    //sets up the collection view cell
    
    var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var dimensionText: UILabel = {
        let text = UILabel()
        text.translatesAutoresizingMaskIntoConstraints = false
        text.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        return text
    }()
    
    override func layoutSubviews() {
        contentView.addSubview(dimensionText)
        contentView.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 0),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            imageView.heightAnchor.constraint(equalToConstant: 150),
            imageView.widthAnchor.constraint(equalToConstant: 150),
            
            dimensionText.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 0),
            dimensionText.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 15),
            dimensionText.heightAnchor.constraint(equalToConstant: 20),
        ])
    }
}
