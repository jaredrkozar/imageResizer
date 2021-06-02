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
        #if !targetEnvironment(macCatalyst)
            self.layer.masksToBounds = true
            self.layer.cornerCurve = .continuous
            self.backgroundColor = UIColor(named: "AccentColor")
            self.layer.cornerRadius = 5.0
        #elseif targetEnvironment(macCatalyst)
            self.backgroundColor = UIColor.white
        #endif
    }
}

class ViewController: UIViewController, PHPickerViewControllerDelegate, UITableViewDataSource, UITableViewDelegate {

    var presets = [String]()
    
    var selectedPresets = Set<Int>()
    
    var newImage = UIImage()
    // create a set of integer type
    
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var resizeImageButton: UIButton!
    
    @IBOutlet var aspectRatioLocked: UISwitch!

    @IBOutlet var presetCellsView: UITableView!
    
    var heightnum = UserDefaults.standard.integer(forKey: "height")
    
    var widthnum = UserDefaults.standard.integer(forKey: "width")

    let nc = NotificationCenter.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    
        title = "Image Resizer"
        
        NotificationCenter.default.addObserver(self, selector: #selector(isImageSelected(_:)), name: NSNotification.Name( "widthHeightEntered"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(addtoTable(_:)), name: NSNotification.Name( "addWidthHeighttoTable"), object: nil)
        
        if imageView.image == nil {
            imageView.image = UIImage(systemName: "photo")
            resizeImageButton.isEnabled = false;
            resizeImageButton.alpha = 0.5
        }
        
        presetCellsView.delegate = self
        presetCellsView.dataSource = self
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presets.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "presetCell", for: indexPath)
        cell.textLabel?.text = presets[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.cellForRow(at: indexPath as IndexPath)?.accessoryType = .checkmark
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath as IndexPath)?.accessoryType = .none
    }

    @IBAction func importButtonTapped(_ sender: UIBarButtonItem) {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc func addtoTable(_ notification: Notification) {
        let dimensions = String("\(heightnum) x \(widthnum)")
        presets.append(dimensions)
    }
    @objc func isImageSelected(_ notification: Notification) {
        if imageView.image != UIImage(systemName: "photo") {
            resizeImageButton.isEnabled = true;
            resizeImageButton.alpha = 1.0;
        }
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
        }
        picker.dismiss(animated: true, completion: nil)
    }

    @IBAction func resizeButtonTapped(_ sender: Any) {
        if aspectRatioLocked.isOn {
            resizeImageWithAspectRatio()
        } else {
            resizeImage()
        }
    }
        
    func resizeImage() {
        let heightnum = Double(heightnum)
        let widthnum = Double(widthnum)
        
        if let image = imageView.image {
            UIGraphicsBeginImageContextWithOptions(CGSize(width: widthnum, height: heightnum), false, 0.0)
            image.draw(in: CGRect(x: 0, y: 0, width: widthnum, height: heightnum))
            newImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            imageView.image = newImage
        }
        
    }
    
    func resizeImageWithAspectRatio() {
        
        var image = imageView.image
        let heightnum = Double(heightnum)
        let widthnum = Double(widthnum)
        
        
        let widthRatio  = widthnum  / Double(image!.size.width)
        
        let heightRatio = heightnum / Double(image!.size.height)

        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: Double(image!.size.width) * heightRatio, height: Double(Int(image!.size.height)) * heightRatio)
        } else {
            newSize = CGSize(width: Double(image!.size.width) * widthRatio, height: Double(image!.size.height) * widthRatio)
        }

        if let image = imageView.image {
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            image.draw(in: CGRect(origin: .zero, size: newSize))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            imageView.image = newImage
        }
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

