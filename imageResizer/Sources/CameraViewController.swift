//
//  CameraViewController.swift
//  CameraViewController
//
//  Created by Jared Kozar on 9/21/21.
//

import UIKit

extension ViewController: UIImagePickerControllerDelegate {
    
    @objc func presentCamera() {

        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.allowsEditing = true
        vc.delegate = self
        self.present(vc, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            picker.dismiss(animated: true)

            guard let image = info[.editedImage] as? UIImage else {
                print("No image was found at this location. Please try again.")
                return
            }

            dismiss(animated: true, completion: nil)
        imageView.image = image.resizeImageWithAspectRatio(dimension: "773.5 x 284")
            NotificationCenter.default.post(name: Notification.Name( "isImageSelected"), object: nil)
    }
    
}
