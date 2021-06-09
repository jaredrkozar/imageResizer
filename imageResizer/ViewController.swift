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
            self.layer.cornerRadius = 5.0
        self.layer.backgroundColor = UIColor(named: "AccentColor")?.cgColor
        self.titleLabel?.textColor = UIColor.white
        #endif
    }
}

class ViewController: UIViewController, PHPickerViewControllerDelegate, UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate {
    var imageDetails = [Images]()
    
    var presets = [String]()
    var selectedPresets = [String]()
    
    var newImage = UIImage()
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var resizeImageButton: StandardButton!
    
    @IBOutlet var aspectRatioLocked: UISwitch!

    @IBOutlet var presetCellsView: UITableView!
    
    let nc = NotificationCenter.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    
        title = "Image Resizer"

        if imageView.image == UIImage(systemName: "photo") {
            resizeImageButton.isEnabled = false;
            resizeImageButton.alpha = 0.5
        }
    
        self.presetCellsView.allowsMultipleSelection = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(isImageSelected(_:)), name: NSNotification.Name( "widthHeightEntered"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(addtoTable(_:)), name: NSNotification.Name( "addWidthHeighttoTable"), object: nil)
        
        presetCellsView.delegate = self
        presetCellsView.dataSource = self
    }
    
    //Table code
    
    @objc func addtoTable(_ notification: Notification) {
        let heightnum = UserDefaults.standard.integer(forKey: "height")
        let widthnum = UserDefaults.standard.integer(forKey: "width")
        let dimensions = String("\(heightnum) x \(widthnum)")
        
        presets.append(dimensions)
        let indexPath = IndexPath(row: (self.presets.count - 1), section: 0)
        presetCellsView.insertRows(at: [indexPath], with: .automatic)
        
        UserDefaults.standard.set(presets, forKey: "presets")
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
        self.selectedPresets.append(presets[indexPath.row])
    
        NotificationCenter.default.post(name: Notification.Name( "widthHeightEntered"), object: nil)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath as IndexPath)?.accessoryType = .none
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Presets"
    }
    
    
    //Button code
    
    @IBAction func importButtonTapped(_ sender: UIBarButtonItem) {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    
    @IBAction func resizeButtonTapped(_ sender: Any) {
        if aspectRatioLocked.isOn {
            resizeImageWithAspectRatio()
        } else {
            resizeImage()
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
    
    //Image Picker
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {

        if let itemProvider = results.first?.itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
            
            let previousImage = imageView.image
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                DispatchQueue.main.async {
                    guard let self = self, let image = image as? UIImage, self.imageView.image == previousImage else { return }
                    self.imageView.image = image
                    NotificationCenter.default.post(name: Notification.Name( "widthHeightEntered"), object: nil)
                }
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    //Image Selection
    @objc func isImageSelected(_ notification: Notification) {
        if imageView.image != UIImage(systemName: "photo") && selectedPresets.count  >= 1 {
            resizeImageButton.isEnabled = true;
            resizeImageButton.alpha = 1.0;
        }
    }
    
    //Image Resizing Code
        
    func resizeImage() {
        
        for dimension in selectedPresets {
            
            let HeightWidthArr = dimension.components(separatedBy: " x ")
            
            let heightnum = Double(HeightWidthArr[0])! / 2
            let widthnum = Double(HeightWidthArr[1])! / 2

            if let image = imageView.image {
                UIGraphicsBeginImageContextWithOptions(CGSize(width: widthnum, height: heightnum), false, 0.0)
                image.draw(in: CGRect(x: 0, y: 0, width: widthnum, height: heightnum))
                newImage = UIGraphicsGetImageFromCurrentImageContext()!
                UIGraphicsEndImageContext()
                
                if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? resizedImagesController {
                    vc.dimension = dimension
                    vc.cellImage = newImage
                    present(vc, animated: true, completion: nil)
                }
            }
        }
    }
    
    func resizeImageWithAspectRatio() {
       
        for dimension in selectedPresets {
            
            let HeightWidthArr = dimension.components(separatedBy: " x ")
            
            let heightnum = Double(HeightWidthArr[0])!
            let widthnum = Double(HeightWidthArr[1])!
            let image = imageView.image
            let widthRatio  = widthnum  / Double(image!.size.width)
            let heightRatio = heightnum / Double(image!.size.height)

            var newSize: CGSize
            
            if(widthRatio > heightRatio) {
                newSize = CGSize(width: Double(image!.size.width) * heightRatio, height: Double(Int(image!.size.height)) * heightRatio)
            } else {
                newSize = CGSize(width: Double(image!.size.width) * widthRatio, height: Double(image!.size.height) * widthRatio)
            }

            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            image!.draw(in: CGRect(origin: .zero, size: newSize))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? resizedImagesController {
                vc.dimension = dimension
                vc.cellImage = newImage
                present(vc, animated: true, completion: nil)
            }
        }
    }
}
