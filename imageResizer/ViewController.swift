//
//  ViewController.swift
//  imageResizer
//
//  Created by Jared Kozar on 5/26/21.
//

import UIKit

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

class ViewController: UIViewController & UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate, UIDropInteractionDelegate {
    
    var presets = UserDefaults.standard.stringArray(forKey: "presets") ?? [String]()
    var selectedPresets = [String]()
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(sourceSelected(_:)), name: NSNotification.Name( "sourceSelected"), object: nil)

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
        noPresetsLabel.isHidden = true
        self.presetCellsView.reloadData()
    }
    
    func noPresets() {
        //checks of there are any presets in the table view; if there no presets, display a message telling the user to add a preset, and if there are presets, don;t display the message

        if presets.count == 0 {
            noPresetsLabel.isHidden = false
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
        var listofsources = [UIAction]()
        
        for sort in Sources.allCases {
           
            listofsources.append( UIAction(title: "\(sort.title)", image: sort.icon, identifier: nil, attributes: []) { _ in
               
                selectedSource = sort.title
                NotificationCenter.default.post(name: Notification.Name( "sourceSelected"), object: nil)
           })
        }
        
        var sourcesMenu: UIMenu {
            return UIMenu(title: "Import image from...", image: nil, identifier: nil, options: [], children: listofsources)
        }
        
        let addImageButton = UIBarButtonItem(title: nil, image: UIImage(systemName: "plus"), primaryAction: nil, menu: sourcesMenu)
        
        return addImageButton
    }
    
    @objc func sourceSelected(_ notification: Notification) {
        
        switch selectedSource {
            case "Scan Document":
                self.presentDocumentScanner()
            case "Camera":
                self.presentCamera()
            case "Photo Library":
                self.presentPhotoPicker()
            case "Files":
                self.presentFilesPicker()
            case "URL":
                self.presentURLPicker()
            default:
                print("Enjoy your day!")
        }
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
        
        if isEditingDimension == true {
            let HeightWidthArr = presets[UserDefaults.standard.integer(forKey: "row")]
                .components(separatedBy: " x ")
            var heightNum = Double(HeightWidthArr[0])!
            let widthNum = Double(HeightWidthArr[1])!
            dimensionheight = String(Int(heightNum))
            dimensionwidth = String(Int(widthNum))
        }
        
        switch UIDevice.current.userInterfaceIdiom {
        case .phone, .phone:
            let vc : AddPresetViewController = storyboard!.instantiateViewController(withIdentifier: "addPreset") as! AddPresetViewController
            let navigationController = UINavigationController(rootViewController: vc)
            
            navigationController.modalPresentationStyle = UIModalPresentationStyle.popover
            navigationController.preferredContentSize = CGSize(width: 400, height: 200)
               
            self.present(navigationController, animated: true, completion: nil)
            
            let popoverPresentationController = vc.popoverPresentationController
           popoverPresentationController?.sourceView = addPresetButton
           popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
            
        case .mac:
                
            let activity = NSUserActivity(activityType: "addPreset")
            UIApplication.shared.requestSceneSessionActivation(nil, userActivity: activity, options: nil) { (error) in
                print(error)
            }

            default:
                break
        }

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
                noPresets()
                
            }
            return UIMenu(title: "", children: [editAction, deleteAction])
        }
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
