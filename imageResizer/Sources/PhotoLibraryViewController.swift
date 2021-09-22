//
//  PhotoLibraryViewController.swift
//  PhotoLibraryViewController
//
//  Created by Jared Kozar on 9/21/21.
//

import UIKit
import PhotosUI

//manages the Photos Library image selection
extension ViewController: PHPickerViewControllerDelegate {
    
    @objc func presentPhotoPicker() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        self.present(picker, animated: true)
    }
    
    //Image Picker
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        //set the photo symbol to previousImage and set the image the user selected to imageView.image, which displays it in the image view on the left side of the screen
        
        if let itemProvider = results.first?.itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
            
            let previousImage = imageView.image
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                DispatchQueue.main.async {
                    guard let self = self, let image = image as? UIImage, self.imageView.image == previousImage else { return }
                    self.imageView.image = image.resizeImageWithAspectRatio(dimension: "773.5 x 284")
                    NotificationCenter.default.post(name: Notification.Name( "isImageSelected"), object: nil)
                }
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
}
