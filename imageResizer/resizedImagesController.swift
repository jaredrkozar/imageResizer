//
//  resizedImagesController.swift
//  imageResizer
//
//  Created by Jared Kozar on 6/6/21.
//

import UIKit

class resizedImagesController: UICollectionViewController {

    var imageDetails = [Images]()
    var cellImage: UIImage!
    var dimension: String = ""
    var selectedImages = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Resized Images"
        
        let image = UIImage(systemName: "square.and.arrow.up")
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .done, target: nil, action: #selector(shareButtonTapped))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
        
        collectionView.reloadData()
        collectionView.allowsMultipleSelection = true

    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageDetails.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "image", for: indexPath) as? ImageCell else {
            fatalError("Unable to dequeue the image cell.")
        }
        
        let image = imageDetails[indexPath.item]

        cell.dimensions.text = image.dimensions

        cell.imageView.image = image.image

        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let getImage = imageDetails[indexPath.item]
        selectedImages.append(getImage.image)

        if let cell = collectionView.cellForItem(at: indexPath) {
            cell.layer.borderWidth = 3.0
            cell.layer.borderColor = UIColor(named: "AccentColor")?.cgColor
            cell.layer.backgroundColor = UIColor(named: "bgColor")?.cgColor
            cell.layer.cornerRadius = 5.0
        }
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            cell.layer.backgroundColor = UIColor.systemBackground.cgColor
            cell.layer.borderWidth = 0.0
        }
    }
    
    @objc func shareButtonTapped(_ sender: UIBarButtonItem) {
        
        let items = [imageDetails]
        let vc = UIActivityViewController(activityItems: items, applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.leftBarButtonItem
        present(vc, animated: true)
    }
    
    @objc func doneButtonTapped(_ sender: UIBarButtonItem) {
       dismiss(animated: true, completion: nil)
    }
    
}
