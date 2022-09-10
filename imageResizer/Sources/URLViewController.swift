//
//  URLViewController.swift
//  URLViewController
//
//  Created by Jared Kozar on 9/21/21.
//

import UIKit

extension ViewController {

    @objc func presentURLPicker() {
        let enterURL = UIAlertController(title: "Enter URL", message: "Enter the direct URL of the image you want to get the text from.", preferredStyle: .alert)
    
        enterURL.addTextField()
        
        enterURL.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
        enterURL.addAction(UIAlertAction(title: "OK", style: .default) { [weak self, weak enterURL] _ in

            let textField = enterURL?.textFields![0]
                    
            let url = URL(string: (textField?.text)!)

            if UIApplication.shared.canOpenURL(url! as URL) == true {
                DispatchQueue.global().async { [weak self] in
                    if let data = try? Data(contentsOf: url!) {
                        if let image = UIImage(data: data) {
                            DispatchQueue.main.async {
                                self!.imageView.image = image
                                NotificationCenter.default.post(name: Notification.Name( "isImageSelected"), object: nil)
                                
                            }
                        }
                    }
                }
            } else {
                let invalidURL = UIAlertController(title: "Invalid URL", message: "The direct image URL you entered is invalid. Please enter another URL.", preferredStyle: .alert)
                
                invalidURL.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                
                self!.present(invalidURL, animated: true)
            }
        })
        present(enterURL, animated: true)
    }
}
