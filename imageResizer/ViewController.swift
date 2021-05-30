//
//  ViewController.swift
//  imageResizer
//
//  Created by Jared Kozar on 5/26/21.
//

import UIKit
import PhotosUI


class StandardButton: UIButton {
    override func draw(_ rect: CGRect) {
        self.layer.masksToBounds = true
        
        self.layer.cornerRadius = 10
        self.layer.cornerCurve = .continuous

        
        self.layer.borderWidth = 1.5
        self.layer.borderColor = UIColor.label.withAlphaComponent(0.075).cgColor
        
    }
}


class ViewController: UIViewController, UIImagePickerControllerDelegate, PHPickerViewControllerDelegate {

    

    var sizes = [String]()
    var newImage = UIImage()
    
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var resizeImageButton: UIButton!
    
    @IBOutlet var heigthField: UITextField!
    
    
    @IBOutlet var aspectRatioLocked: UISwitch!
    
    @IBOutlet var widthField: UITextField!
    
    var widthnum = 0
    var heightnum = 0
    
    let nc = NotificationCenter.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        title = "Image Resizer"
        NotificationCenter.default.addObserver(self, selector: #selector(isImageSelected(_:)), name: NSNotification.Name( "imageSelected"), object: nil)
        
        if imageView.image == nil {
            imageView.image = UIImage(systemName: "photo")
            resizeImageButton.isEnabled = false;
            resizeImageButton.alpha = 0.5;
        }
    }
    
    @IBAction func importButtonTapped(_ sender: UIBarButtonItem) {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc func isImageSelected(_ notification: Notification) {

        resizeImageButton.isEnabled = true;
        resizeImageButton.alpha = 1.0;
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        if let itemProvider = results.first?.itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
            
            let previousImage = imageView.image
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                DispatchQueue.main.async {
                    guard let self = self, let image = image as? UIImage, self.imageView.image == previousImage else { return }
                    self.imageView.image = image
    
                }
            }
            picker.dismiss(animated: true, completion: nil)
            NotificationCenter.default.post(name: Notification.Name( "imageSelected"), object: nil)
            
        }
    }
 
    @IBAction func resizeButtonTapped(_ sender: StandardButton) {
        if aspectRatioLocked.isOn {
            resizeImageWithAspectRatio()
        } else {
            resizeImage()
        }
    }
        
    func resizeImage() {
        
        let heigthFieldInt = heigthField.text!
        heightnum = Int(heigthFieldInt)! / 2
        
        let widthFieldInt = widthField.text!
        widthnum = Int(widthFieldInt)! / 2
        
        if let image = imageView.image {
            UIGraphicsBeginImageContextWithOptions(CGSize(width: widthnum, height: heightnum), false, 0.0)
            image.draw(in: CGRect(x: 0, y: 0, width: widthnum, height: heightnum))
            newImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            imageView.image = newImage
        }
        
    }
    
    func resizeImageWithAspectRatio() {
        var widthRatio: Double = 0.0
        var heightRatio: Double = 0.0
        var image = imageView.image
        
        let heigthFieldInt = heigthField.text!
        heightnum = Int(heigthFieldInt)!
        
        let widthFieldInt = widthField.text!
        widthnum = Int(widthFieldInt)!
        
        widthRatio  = Double(widthnum  / Int(image!.size.width))
        heightRatio = Double(heightnum / Int(image!.size.height))
        print(image!.size.height)
        print(heightnum)
        print(heightRatio)
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: Double(image!.size.width) * heightRatio, height: Double(Int(image!.size.height)) * heightRatio)
        } else {
            newSize = CGSize(width: Double(image!.size.width) * widthRatio, height: Double(image!.size.height) * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(origin: .zero, size: newSize)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image!.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        imageView.image = newImage
    }
    
    @IBAction func shareButtonTapped(_ sender: UIBarButtonItem) {
        
        guard let selectedImage = imageView.image?.jpegData(compressionQuality: 1.0) else {
            print("No image found")
            return
        }

        let vc = UIActivityViewController(activityItems: [selectedImage], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.leftBarButtonItem
        present(vc, animated: true)
    }
}

