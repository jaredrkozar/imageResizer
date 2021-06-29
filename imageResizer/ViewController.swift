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
            self.setTitleColor(.white, for: .normal)
        #endif
    }
}

class ViewController: UIViewController, PHPickerViewControllerDelegate, UITableViewDataSource, UITableViewDelegate, UIAdaptivePresentationControllerDelegate {
    
    var imageDetails = [Images]()
    var presets = [String]()
    var selectedPresets = [String]()
    var newImage = UIImage()
    var imageArray = [UIImage]()
    var dimensionArray = [String]()
    
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
        
     
        //disables the "Resize Image" button once the app starts
        resizeImageButton.isEnabled = false;
        resizeImageButton.alpha = 0.5
        
        //enables the user to select multiple dimensions in the table view
        self.presetCellsView.allowsMultipleSelection = true
        
        notifications()
        
        //sets the table view's delegate and data source methods
        presetCellsView.delegate = self
        presetCellsView.dataSource = self
    }

    func notifications() {
        
       //sends out notifications to other classes in this view controller
        NotificationCenter.default.addObserver(self, selector: #selector(isImageSelected(_:)), name: NSNotification.Name( "isImageSelected"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(addtoTable(_:)), name: NSNotification.Name( "addWidthHeighttoTable"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(editedPreset(_:)), name: NSNotification.Name( "editedPreset"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(emptyImagesArray(_:)), name: NSNotification.Name( "emptyImagesArray"), object: nil)
        
    }
    
    //Table code
    
    @objc func addtoTable(_ notification: Notification) {
        //adds the dimension the user entednin the AddPresetViewController class to the table view.
        let dimension = UserDefaults.standard.string(forKey: "dimension")
        presets.append(dimension!)
        let indexPath = IndexPath(row: (self.presets.count - 1), section: 0)
        presetCellsView.insertRows(at: [indexPath], with: .automatic)
        noPresets()
        UserDefaults.standard.set(presets, forKey: "presets")
        
    }
    
    func noPresets() {
        //checks of there are any presets in the table view; if there no presets, display a message telling the user to add a preset, and if there are presets, don;t display the message
        
        if presets.count == 0 {
            noPresetsLabel.text = "No presets available. Add a preset using the 'Add Preset' button above and you'll see them here."
            resizeImageButton.isEnabled = false;
            resizeImageButton.alpha = 0.5;
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
        //when the user selects a row, give that row a checkmark accessory,append it to the selectedPresets array, and send a notification to the isImageSelected class, which checks if theres an image
        tableView.cellForRow(at: indexPath as IndexPath)?.accessoryType = .checkmark
        self.selectedPresets.append(presets[indexPath.row])
    
        NotificationCenter.default.post(name: Notification.Name( "isImageSelected"), object: nil)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        //remove the cell from the selectedPresets array and its accessory.
        tableView.cellForRow(at: indexPath as IndexPath)?.accessoryType = .none

        removeSelectedPreset(indexPath: indexPath, tableView)
        
        NotificationCenter.default.post(name: Notification.Name( "isImageSelected"), object: nil)

    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Presets"
    }
    
    
    //Button code
    
    @IBAction func importButtonTapped(_ sender: UIBarButtonItem) {
        
        //brings up the iOS 14 photo picker
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    
    @IBAction func resizeButtonTapped(_ sender: Any) {
    //if the user turned the aspect ratio locked switch on, the resizeImageWithAspectRatio() function runs, and if the switch is off, then run the resizeImage() function, which doesn't keep the aspect ratio the same
        
        if aspectRatioLocked.isOn {
            resizeImageWithAspectRatio()
        } else {
            resizeImage()
        }
        
    }
    
    @IBAction func addPresetButton(_ sender: Any) {
        //if the user taps the Add Preset button, a popover pops up allowing the user to enter a preset
        
        let vc : AddPresetViewController = storyboard!.instantiateViewController(withIdentifier: "addPreset") as! AddPresetViewController
        let navigationController = UINavigationController(rootViewController: vc)
            
        navigationController.modalPresentationStyle = UIModalPresentationStyle.popover
        navigationController.preferredContentSize = CGSize(width: 400, height: 200)
           
        self.present(navigationController, animated: true, completion: nil)
        
        let popoverPresentationController = vc.popoverPresentationController
       popoverPresentationController?.sourceView = addPresetButton
       popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
       popoverPresentationController?.sourceRect = CGRect(x: 30, y: 20, width: 0, height: 5)
    }
    
    //Image Picker
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        //set the photo symbol to previousImage and set the image the user selected to imageView.image, which displays it in the image view on the left side of the screen
        
        if let itemProvider = results.first?.itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
            
            let previousImage = imageView.image
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                DispatchQueue.main.async {
                    guard let self = self, let image = image as? UIImage, self.imageView.image == previousImage else { return }
                    self.imageView.image = image
                    NotificationCenter.default.post(name: Notification.Name( "isImageSelected"), object: nil)
                }
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    //Image Selection
    @objc func isImageSelected(_ notification: Notification) {
        //if the user selects an image and a preset, the Resize Image button is enabled, otherwise it's disabled
        
        if imageView.image != UIImage(systemName: "photo") && selectedPresets.count  >= 1 {
            resizeImageButton.isEnabled = true;
            resizeImageButton.alpha = 1.0;
        } else {
            resizeImageButton.isEnabled = false;
            resizeImageButton.alpha = 0.5;
        }
    }
    
    //Image Resizing Code
        
    func resizeImage() {
        //gets the current dimension and splits it up into 2 parts, heightNum and widthNum, and gets the image that was selected. The image is then duplicated with the specified widthNum and heightNum, and set to newImage, where the newImage and the dimension are appended to the Images array.
        
        for dimension in selectedPresets {
            let HeightWidthArr = dimension.components(separatedBy: " x ")
            
            let heightnum = Double(HeightWidthArr[0])! / 2
            let widthnum = Double(HeightWidthArr[1])! / 2
            
            if let image = self.imageView.image {
                UIGraphicsBeginImageContextWithOptions(CGSize(width: widthnum, height: heightnum), false, 0.0)
                image.draw(in: CGRect(x: 0, y: 0, width: widthnum, height: heightnum))
                self.newImage = UIGraphicsGetImageFromCurrentImageContext()!
                UIGraphicsEndImageContext()
                let cell = Images(dimensions: dimension, image: self.newImage)
                self.imageDetails.append(cell)
            }
            
        }
        
        //brings up the resizedImagesController() modal popover
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc : resizedImagesController = storyboard.instantiateViewController(withIdentifier: "Detail") as! resizedImagesController
        vc.imageDetails = self.imageDetails
        let navigationController = UINavigationController(rootViewController: vc)
        
        self.present(navigationController, animated: true, completion: nil)
    
    }
    
    func resizeImageWithAspectRatio() {
        //gets the current dimension and splits it up into 2 parts, heightNum and widthNum, and gets the image that was selected. The aspect ratio is found by dividing the width the user entered by the image's width (same thing for the height). The new size of the image is found by comparing the two ratios; if the widthRatio is greater than the heightRatio, it gets the images width and multiplies it by the heightRatio, and gets the images height, and multiplies that by the heightRatio. (Vice versa if the heightRatio is greater than the widthRatio).
        
        for dimension in selectedPresets {
            let HeightWidthArr = dimension.components(separatedBy: " x ")
            
            let heightnum = Double(HeightWidthArr[0])!
            let widthnum = Double(HeightWidthArr[1])!
            let widthRatio  = widthnum  / Double(imageView.image!.size.width)
            let heightRatio = heightnum / Double(imageView.image!.size.height)

            
            var newSize: CGSize
            if(widthRatio > heightRatio) {
                newSize = CGSize(width: Double(self.imageView.image!.size.width) * heightRatio, height: Double(Int(self.imageView.image!.size.height)) * heightRatio)
            } else {
                newSize = CGSize(width: Double(self.imageView.image!.size.width) * widthRatio, height: Double(self.imageView.image!.size.height) * widthRatio)
            }
            
            //creates a new image based off of the dimensions found above
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            self.imageView.image!.draw(in: CGRect(origin: .zero, size: newSize))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            let cell = Images(dimensions: dimension, image: newImage)
            self.imageDetails.append(cell)
        }
        
        //brings up the resizedImagesController() modal popover
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc : resizedImagesController = storyboard.instantiateViewController(withIdentifier: "Detail") as! resizedImagesController
        vc.imageDetails = self.imageDetails
        let navigationController = UINavigationController(rootViewController: vc)
        self.present(navigationController, animated: true, completion: nil)
    }
    
    //Context Menu code
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let preset = presets[indexPath.row]
        //saves the row the user bought the context menu appear on in row
        let row = indexPath.row
        UserDefaults.standard.set(row, forKey: "row")
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let editAction = UIAction(
              title: "Edit", image: UIImage(systemName: "pencil")) { [self] _ in
                //gets the current dimension and splits it up into 2 parts, and saves them so they can be shown in the text fields in editPresetViewController. The editPresetViewController is then shown via a popover
                
                let HeightWidthArr = preset.components(separatedBy: " x ")
                let height = Double(HeightWidthArr[0])!
                let width = Double(HeightWidthArr[1])!
                
                let vc : EditPresetViewController = storyboard!.instantiateViewController(withIdentifier: "editPreset") as! EditPresetViewController
                let navigationController = UINavigationController(rootViewController: vc)
                    
                navigationController.modalPresentationStyle = UIModalPresentationStyle.popover
                navigationController.preferredContentSize = CGSize(width: 400, height: 200)
                vc.height = String(Int(height))
                vc.width = String(Int(width))
                   
                self.present(navigationController, animated: true, completion: nil)
                       
                let popoverPresentationController = vc.popoverPresentationController
                
                popoverPresentationController?.sourceView = self.presetCellsView

                popoverPresentationController?.sourceRect = CGRect(x: 0, y: 0, width: 0, height: 0)
                
            }
            
            let deleteAction = UIAction(
                //deletes the current cell
              title: "Delete",
              image: UIImage(systemName: "trash"),
                attributes: .destructive) { [self] _ in
                self.presets.remove(at: indexPath.row)
                self.presetCellsView.reloadData()
                removeSelectedPreset(indexPath: indexPath, tableView)
                self.noPresets()
                
            }
            return UIMenu(title: "", children: [editAction, deleteAction])
        }
    }
    
    @objc func editedPreset(_ tableView: UITableView) {
        //gets the current row from contextMenuConfigurationForRowAt and the new dimensions from EditPresetViewController. If the row is currently selected, delete it from the selectedPreseta and presets arrays, and if it isn't currently selected, just delete it from the presets array.
        
        let row = UserDefaults.standard.integer(forKey: "row")
        let editedDimensions = UserDefaults.standard.string(forKey: "editedDimension")
        if(selectedPresets.contains(presets[row])) {
            selectedPresets[row] = editedDimensions!
            presets[row] = editedDimensions!
        } else {
            presets[row] = editedDimensions!
        }
        self.presetCellsView.reloadData()
    }
    
    @objc func emptyImagesArray(_ notification: Notification) {
        //remove all images from the imageDetails array
        imageDetails.removeAll()
    }
    
    func removeSelectedPreset(indexPath: IndexPath, _ tableView: UITableView) {
        //removes currently selected row from the selectedPresets array
        let selectedpresettoRemove = selectedPresets[indexPath.row]
        let selectedPreset = selectedPresets.firstIndex(of: selectedpresettoRemove)!
        selectedPresets.remove(at: selectedPreset)
    }
}
