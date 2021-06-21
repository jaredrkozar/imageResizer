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
    
    @IBOutlet var noPresetsLabel: UILabel!

    @IBOutlet var imageView: UIImageView!

    @IBOutlet var resizeImageButton: StandardButton!
    
    @IBOutlet var aspectRatioLocked: UISwitch!

    @IBOutlet var presetCellsView: UITableView!
    
    @IBOutlet var addPresetButton: UIButton!
    
    let nc = NotificationCenter.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    
        title = "Image Resizer"
        noPresets()
        
        if imageView.image == UIImage(systemName: "photo") {
            resizeImageButton.isEnabled = false;
            resizeImageButton.alpha = 0.5
        }
    
        self.presetCellsView.allowsMultipleSelection = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(isImageSelected(_:)), name: NSNotification.Name( "widthHeightEntered"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(addtoTable(_:)), name: NSNotification.Name( "addWidthHeighttoTable"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(editedPreset(_:)), name: NSNotification.Name( "editedPreset"), object: nil)
        
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
        noPresets()
        UserDefaults.standard.set(presets, forKey: "presets")
        
    }
    
    func noPresets() {
        if presets.count == 0 {
            noPresetsLabel.text = "No presets available. Add a preset thing the 'Add Preset' button above and you'll see them here."
        } else {
            noPresetsLabel.text = ""
        }
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
        selectedPresets.remove(at: indexPath.row)
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
        for dimension in selectedPresets {
            if aspectRatioLocked.isOn {
                resizeImageWithAspectRatio(dimension: dimension)
            } else {
                resizeImage(dimension: dimension)
            }
        }
    }
    
    @IBAction func addPresetButton(_ sender: Any) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "addPreset") as? AddPresetViewController {
            self.navigationController?.modalPresentationStyle = .popover
                 
            vc.modalPresentationStyle = UIModalPresentationStyle.popover
            vc.preferredContentSize = CGSize(width: 400, height: 400)
               
            present(vc, animated: true, completion: nil)
               
            let popoverPresentationController = vc.popoverPresentationController
            popoverPresentationController?.sourceView = addPresetButton
            popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
            popoverPresentationController?.sourceRect = CGRect(x: 30, y: 0, width: 0, height: 25)
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
        
    func resizeImage(dimension: String) {
        
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
    
    func resizeImageWithAspectRatio(dimension: String) {
       
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
    
    //Context Menu code
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let preset = presets[indexPath.row]
        let row = indexPath.row
        print(row)
        UserDefaults.standard.set(row, forKey: "row")
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let editAction = UIAction(
              title: "Edit",
                image: UIImage(systemName: "pencil")) { [self] _ in
                let HeightWidthArr = preset.components(separatedBy: " x ")
                let height = Double(HeightWidthArr[0])!
                let width = Double(HeightWidthArr[1])!
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: "editPreset") as? EditPresetViewController {
                    self.navigationController?.modalPresentationStyle = .popover
                    
                    vc.modalPresentationStyle = UIModalPresentationStyle.popover
                    vc.preferredContentSize = CGSize(width: 400, height: 600)
                    vc.height = String(Int(height))
                    vc.width = String(Int(width))
                    self.present(vc, animated: true, completion: nil)
                       
                    let popoverPresentationController = vc.popoverPresentationController
                    popoverPresentationController?.sourceView = self.presetCellsView
                
                    popoverPresentationController?.sourceRect = CGRect(x: 0, y: 0, width: 0, height: 0)
                }
            }
            
            let deleteAction = UIAction(
              title: "Delete",
              image: UIImage(systemName: "trash"),
              attributes: .destructive) { _ in
                self.presets.remove(at: indexPath.row)
                tableView.reloadData()
                self.noPresets()
            }
            return UIMenu(title: "", children: [editAction, deleteAction])
        }
    }
    
    @objc func editedPreset(_ tableView: UITableView) {
        let row = UserDefaults.standard.integer(forKey: "row")
        let editedDimensions = UserDefaults.standard.string(forKey: "editedDimension")
        presets[row] = editedDimensions!
        self.presetCellsView.reloadData()
    }
    
}
