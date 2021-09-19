//
//  ViewController.swift
//  imageResizer
//
//  Created by Jared Kozar on 5/26/21.
//

import UIKit
import VisionKit
import Vision
import PhotosUI
import MobileCoreServices
import UniformTypeIdentifiers

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

class ViewController: UIViewController, VNDocumentCameraViewControllerDelegate, UIImagePickerControllerDelegate, PHPickerViewControllerDelegate & UINavigationControllerDelegate, UIDocumentPickerDelegate, UITableViewDataSource, UITableViewDelegate, UIAdaptivePresentationControllerDelegate, UIDropInteractionDelegate {
    
    var sourcesArray = [UIImage]()
    var presets = UserDefaults.standard.stringArray(forKey: "presets") ?? [String]()
    var selectedPresets = [String]()
    var newImage = UIImage()
    var imageArray = [Images]()
    var dimensionArray = [String]()
    
    @IBOutlet var noPresetsLabel: UILabel!

    @IBOutlet var imageView: UIImageView!

    @IBOutlet var resizeImageButton: StandardButton!
    
    @IBOutlet var importButton: UIBarButtonItem!
    
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
        
        let addImageButton = addImage()
        
        navigationItem.rightBarButtonItems = [addImageButton]
    }

    func notifications() {
        
       //sends out notifications to other classes in this view controller
        NotificationCenter.default.addObserver(self, selector: #selector(isImageSelected(_:)), name: NSNotification.Name( "isImageSelected"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(addtoTable(_:)), name: NSNotification.Name( "addWidthHeighttoTable"), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(emptyImagesArray(_:)), name: NSNotification.Name( "emptyImagesArray"), object: nil)
        
        setUpImageViewDrop()
    }
    
    func setUpImageViewDrop() {
        imageView.isUserInteractionEnabled = true
        imageView.addInteraction(UIDropInteraction(delegate: self))
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        for dragItem in session.items {
            dragItem.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { (obj, err) in
                
                if let err = err {
                    print("Failed to load our dragged item:", err)
                    return
                }
                
                guard let draggedImage = obj as? UIImage else { return }
                
                DispatchQueue.main.async {
                    self.imageView.image = draggedImage
                }
                
            })
        }
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: UIImage.self)
    }
    
    
    //Table code
    
    @objc func addtoTable(_ notification: Notification) {
        //adds the dimension the user entednin the AddPresetViewController class to the table view.
        
        let dimension = UserDefaults.standard.string(forKey: "dimension")
        
        if isEditingDimension == true {
            
            let row = UserDefaults.standard.integer(forKey: "row")
            if(selectedPresets.contains(presets[row])) {
                selectedPresets[row] = dimension!
                presets[row] = dimension!
            } else {
                presets[row] = dimension!
            }
            
        } else {
            presets.append(dimension!)
            
            UserDefaults.standard.set(presets, forKey: "presets")
        }
        self.presetCellsView.reloadData()
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
    
    @objc func addImage() -> UIBarButtonItem {
        var sources: [UIAction] {
            return [
                UIAction(title: "Scan Document", image: UIImage(systemName: "doc.text.viewfinder"), handler: { (_) in
                self.presentDocumentScanner()
                }),
                
                UIAction(title: "Camera", image: UIImage(systemName: "camera"), handler: { (_) in
                self.presentCamera()
                }),
                
                UIAction(title: "Photo Library", image: UIImage(systemName: "photo"), handler: { (_) in
                self.presentPhotoPicker()
                }),
                
                UIAction(title: "Files", image: UIImage(systemName: "folder"), handler: { (_) in
                self.presentFilesPicker()
                }),
                
                UIAction(title: "URL", image: UIImage(systemName: "link"), handler: { (_) in
                self.presentURLPicker()
                }),
            ]
        }
        
        var sourcesMenu: UIMenu {
            return UIMenu(title: "Import image from...", image: nil, identifier: nil, options: [], children: sources)
        }
        
        let addImageButton = UIBarButtonItem(title: nil, image: UIImage(systemName: "plus"), primaryAction: nil, menu: sourcesMenu)
        
        return addImageButton
    }
    
    @objc func presentDocumentScanner() {
        self.sourcesArray.removeAll()

        let vc = VNDocumentCameraViewController()
        vc.delegate = self
        self.present(vc, animated: true)
    }
    
    @objc func presentCamera() {
        self.sourcesArray.removeAll()

        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.allowsEditing = true
        vc.delegate = self
        self.present(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
     
      let destinationIndexPath: IndexPath

      if let indexPath = coordinator.destinationIndexPath {
          destinationIndexPath = indexPath
      } else {
          let section = tableView.numberOfSections - 1
          let row = tableView.numberOfRows(inSection: section)
          destinationIndexPath = IndexPath(row: row, section: section)
      }
      
      // attempt to load strings from the drop coordinator
      coordinator.session.loadObjects(ofClass: UIImage.self) { items in
          // convert the item provider array to a string array or bail out
          guard let strings = items as? [UIImage] else { return }

          // create an empty array to track rows we've copied
          var indexPaths = [IndexPath]()

          // loop over all the strings we received
          for (index, image) in strings.enumerated() {
              // create an index path for this new row, moving it down depending on how many we've already inserted
              let indexPath = IndexPath(row: destinationIndexPath.row + index, section: destinationIndexPath.section)

              self.imageView.image = image

          }
      }
    }
                                 
    @objc func presentPhotoPicker() {
        self.sourcesArray.removeAll()
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        self.present(picker, animated: true)
    }
    
    @objc func presentFilesPicker() {
        self.sourcesArray.removeAll()
        let documentpicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.image])
        documentpicker.delegate = self
            self.present(documentpicker, animated: true, completion: nil)
    }
    
    @objc func presentURLPicker() {
        self.sourcesArray.removeAll()
        
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
                                self!.imageView.image = image.resizeImageWithAspectRatio(dimension: "773.5 x 284")
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
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        guard let myURL = urls.first else {
            return
        }
        
        myURL.startAccessingSecurityScopedResource()
        do {
            let imageData = try Data(contentsOf: myURL)
            let image = UIImage(data: imageData)!
            imageView.image = image.resizeImageWithAspectRatio(dimension: "773.5 x 284")
            NotificationCenter.default.post(name: Notification.Name( "isImageSelected"), object: nil)
        } catch {
            print("There was an error loading the image: \(error). Please try again.")
        }
        
        myURL.startAccessingSecurityScopedResource()
        
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

    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        let errorAlert = UIAlertController(title: "Failed to scan document", message: "The document couldn't be scanned right now. Please try again.", preferredStyle: .alert)
        
        errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        present(errorAlert, animated: true)
        
        controller.dismiss(animated: true)
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func documentCameraViewController(_ controller:            VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        // Process the scanned pages
        
        for pageNumber in 0..<scan.pageCount {
            let image = scan.imageOfPage(at: pageNumber)
            
            sourcesArray.append(image)
        }
        
        controller.dismiss(animated: true)
        print("Finished scanning document \(kCGPDFContextTitle)")
        imageView.image = sourcesArray[0].resizeImageWithAspectRatio(dimension: "773.5 x 284")
        NotificationCenter.default.post(name: Notification.Name( "isImageSelected"), object: nil)
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
        isEditingDimension = false
        showPopup()
    }
    
    func showPopup() {
        let vc : AddPresetViewController = storyboard!.instantiateViewController(withIdentifier: "addPreset") as! AddPresetViewController
        let navigationController = UINavigationController(rootViewController: vc)
            
        if isEditingDimension == true {
            let HeightWidthArr = presets[UserDefaults.standard.integer(forKey: "row")]
                .components(separatedBy: " x ")
            let height = Double(HeightWidthArr[0])!
            let width = Double(HeightWidthArr[1])!
            vc.height = String(Int(height))
            vc.width = String(Int(width))
        }
        
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
                    self.imageView.image = image.resizeImageWithAspectRatio(dimension: "773.5 x 284")
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
            let newImage = (imageView.image?.resizeImageWithoutAspectRatio(dimension: dimension))!
            let resizedImage = Images(dimensions: dimension, image: newImage)
            imageDetails.append(resizedImage)
        }
        
        //brings up the resizedImagesController() modal popover
        resizedImagesStoryboard()
    
    }
    
    func resizeImageWithAspectRatio() {
        //gets the current dimension and splits it up into 2 parts, heightNum and widthNum, and gets the image that was selected. The aspect ratio is found by dividing the width the user entered by the image's width (same thing for the height). The new size of the image is found by comparing the two ratios; if the widthRatio is greater than the heightRatio, it gets the images width and multiplies it by the heightRatio, and gets the images height, and multiplies that by the heightRatio. (Vice versa if the heightRatio is greater than the widthRatio).
        
        for dimension in selectedPresets {
            let newImage = (imageView.image?.resizeImageWithAspectRatio(dimension: dimension))!
            let resizedImage = Images(dimensions: dimension, image: newImage)
            imageDetails.append(resizedImage)
        }
        
        //brings up the resizedImagesController() modal popover
        resizedImagesStoryboard()
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
                
                  isEditingDimension = true
                  showPopup()
                
            }
            
            let deleteAction = UIAction(
                //deletes the current cell
              title: "Delete",
              image: UIImage(systemName: "trash"),
                attributes: .destructive) { [self] _ in
                self.presets.remove(at: indexPath.row)
                UserDefaults.standard.set(presets, forKey: "presets")
                self.presetCellsView.reloadData()
                if selectedPresets.contains(preset) {
                    removeSelectedPreset(indexPath: indexPath, tableView)
                }
                self.noPresets()
                
            }
            return UIMenu(title: "", children: [editAction, deleteAction])
        }
    }
    
    @objc func emptyImagesArray(_ notification: Notification) {
        //remove all images from the imageDetails array
        imageDetails.removeAll()
    }
    
    func removeSelectedPreset(indexPath: IndexPath, _ tableView: UITableView) {
        //removes currently selected row from the selectedPresets array
        if selectedPresets.count > 1 {
            let selectedpresettoRemove = selectedPresets[indexPath.row]
            let selectedPreset = selectedPresets.firstIndex(of: selectedpresettoRemove)!
            selectedPresets.remove(at: selectedPreset)
        } else {
            return
        }
    }
    
    func resizedImagesStoryboard() {
        #if targetEnvironment(macCatalyst)

            let activity = NSUserActivity(activityType: "resizeImages")
            UIApplication.shared.requestSceneSessionActivation(nil, userActivity: activity, options: nil) { (error) in
                print(error)
            }
        
        #else
            
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Detail")
            self.present(vc, animated: true, completion: nil)

        #endif
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        #if targetEnvironment(macCatalyst)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        #endif
        
    }
}
