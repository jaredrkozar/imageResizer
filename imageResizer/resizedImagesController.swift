//
//  resizedImagesController.swift
//  imageResizer
//
//  Created by Jared Kozar on 6/6/21.
//

import UIKit
import MobileCoreServices

class resizedImagesController: UICollectionViewController, UIAdaptivePresentationControllerDelegate, UICollectionViewDragDelegate {

    var cellImage: UIImage!
    var dimension: String = ""
    var selectedImages = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //sets up the UIBarButton items and since no images are currently selected, the left bar button items (the share button) is set to false (this is done in the checkImages() function)
        title = "Resized Images"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
        
        let image = UIImage(systemName: "square.and.arrow.up")
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .done, target: self, action: #selector(shareButtonTapped))
        
        checkImages()
        collectionView.dragDelegate = self

        collectionView.dragInteractionEnabled = true
        
        //reloads the collection view when its being presented, allows multiple selction, and sets the presentation controller delegate to this class.
        collectionView.reloadData()
        collectionView.allowsMultipleSelection = true
        self.navigationController?.presentationController?.delegate = self
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let provider = NSItemProvider(object: imageDetails[indexPath.row].image)
        let dragItem = UIDragItem(itemProvider: provider)
        return [dragItem]
                                      
    }
       
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        let provider = NSItemProvider(object: selectedImages[indexPath.row])
        let dragItem = UIDragItem(itemProvider: provider)
        return [dragItem]
    }
    
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        //sends a notification to the emptyImagesArray in the main ViewController class to remove all items in the imageDetails array (in case the user adds/removes currently selected presets)
        
        NotificationCenter.default.post(name: Notification.Name( "emptyImagesArray"), object: nil)
        dismiss(animated: true, completion: nil)
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

        cell.imageView.image = image.image.resizeImageWithAspectRatio(dimension: "150 x 150")

        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //ads the currently selected image to the selectedImages array, and tells the checkImages() function to enable the share button
        
        let imagetoAdd = imageDetails[indexPath.item]
        selectedImages.append(imagetoAdd.image)
        checkImages()
        
        if let cell = collectionView.cellForItem(at: indexPath) {
            //what a cell looks like when the user selects it
            cell.layer.borderWidth = 3.0
            cell.layer.borderColor = UIColor(named: "AccentColor")?.cgColor
            cell.layer.backgroundColor = UIColor(named: "bgColor")?.cgColor
            cell.layer.cornerRadius = 5.0
        }
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        //removes the image from the selectedImages array, and if there are no images in the selectedImages array, tells the checkImages() function to disable the share button
        
        let imagetoRemove = imageDetails[indexPath.item]
        let imageRemove = selectedImages.firstIndex(of: imagetoRemove.image)!
        selectedImages.remove(at: imageRemove)
        
        checkImages()
        
        if let cell = collectionView.cellForItem(at: indexPath) {
            //what a cell looks like when a user deselects it
            cell.layer.backgroundColor = UIColor.secondarySystemGroupedBackground.cgColor
            cell.layer.borderWidth = 0.0
        }
    }
    
    @objc func shareButtonTapped(_ sender: UIBarButtonItem) {
          
        let vc = UIActivityViewController(activityItems: selectedImages, applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.leftBarButtonItem
        present(vc, animated: true)
      }
    
    @objc func doneButtonTapped(_ sender: UIBarButtonItem) {
        NotificationCenter.default.post(name: Notification.Name( "emptyImagesArray"), object: nil)
        dismiss(animated: true, completion: nil)
    }
    
    func checkImages() {
        //if there are no images in the selectedImages array, the share button is disabled, if there are images in the selectedImages array, the button is enabled
        if selectedImages.count == 0 {
            navigationItem.leftBarButtonItem?.isEnabled = false
        } else {
            navigationItem.leftBarButtonItem?.isEnabled = true
        }
    }
    
    func presentationControllerDidDismiss(_ presentationController:
                                            UIPresentationController) {
        //removes all images when the presentation controller is swiped down
        imageDetails.removeAll()
    }
}
