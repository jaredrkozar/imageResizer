//
//  ViewController.swift
//  imageResizer
//
//  Created by Jared Kozar on 5/26/21.
//

import UIKit

class ViewController: UIViewController & UINavigationControllerDelegate, UITableViewDelegate, UIDropInteractionDelegate {
    
    var imageArray = [UIImageView]()
    var dataSource = TableViewDataSource()
    
    var imageView: UIImageView = {
       let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(systemName: "photo")
        image.tintColor = .systemBlue
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    lazy var resizeImageButton: StandardButton = {
        var resizeButton = StandardButton()
        resizeButton.addTarget(self, action: #selector(resizeButtonTapped), for: .touchUpInside)
        resizeButton.setTitle("Resize Image", for: .normal)
        resizeButton.translatesAutoresizingMaskIntoConstraints = false
        
        if currentDevice == "Mac" {
            resizeButton.isHidden = true
        }
        return resizeButton
    }()
    
    lazy var presetsTableView: UITableView = {
        let tableView = UITableView()
        tableView.allowsMultipleSelection = true
        tableView.rowHeight = 63
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .systemBackground
    
        //sets the table view's delegate and data source methods
        tableView.delegate = self
        tableView.dataSource = dataSource
        return tableView
    }()
    
    lazy var addPresetButton: UIButton = {
        let addPresetbutton = UIButton()
        addPresetbutton.setTitleColor(.systemBlue, for: .normal)
        addPresetbutton.setTitle("Add Preset", for: .normal)
        addPresetbutton.addTarget(self, action: #selector(addPresetButtonTapped), for: .touchUpInside)
        addPresetbutton.translatesAutoresizingMaskIntoConstraints = false
        return addPresetbutton
    }()
    
    
    var aspectRatioLocked = UISwitch()
    
    var aspectRatioText: UILabel {
        var label = UILabel()
        label.textColor = .label
        label.text = "Lock Aspect Ratio"
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        return label
    }
    
    lazy var aspectRatiioStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [aspectRatioText, aspectRatioLocked])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .fillEqually
        return stack
    }()
    
    let nc = NotificationCenter.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    
        fetchPresets()
        dataSource.tablePresets = presets
        view.backgroundColor = .systemBackground
        title = "Image Resizer"
        notifications()
        presetsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(imageView)
        view.addSubview(presetsTableView)
        view.addSubview(addPresetButton)
        view.addSubview(dataSource.noPresetsLabel)
        view.addSubview(aspectRatiioStack)
        view.addSubview(resizeImageButton)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: -30),
            imageView.heightAnchor.constraint(equalToConstant: 540),
            imageView.widthAnchor.constraint(equalToConstant: 540),
            
            addPresetButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -30),
            addPresetButton.heightAnchor.constraint(equalToConstant: 30),
            addPresetButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            
            presetsTableView.trailingAnchor.constraint(equalTo: addPresetButton.trailingAnchor, constant: 0),
            presetsTableView.topAnchor.constraint(equalTo: addPresetButton.bottomAnchor, constant: 5),
            presetsTableView.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 20),
            presetsTableView.bottomAnchor.constraint(equalTo: aspectRatiioStack.topAnchor, constant: -15),
            
            aspectRatiioStack.trailingAnchor.constraint(equalTo: addPresetButton.trailingAnchor, constant: 0),
            aspectRatiioStack.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 15),
            aspectRatiioStack.heightAnchor.constraint(equalToConstant: 40),
            aspectRatiioStack.bottomAnchor.constraint(equalTo: resizeImageButton.topAnchor, constant: -15),
            
            resizeImageButton.trailingAnchor.constraint(equalTo: addPresetButton.trailingAnchor, constant: 0),
            resizeImageButton.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 15),
            resizeImageButton.heightAnchor.constraint(equalToConstant: 40),
            resizeImageButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            
            dataSource.noPresetsLabel.centerYAnchor.constraint(equalTo: presetsTableView.centerYAnchor, constant: 0),
            dataSource.noPresetsLabel.centerXAnchor.constraint(equalTo: presetsTableView.centerXAnchor, constant: 0),
            dataSource.noPresetsLabel.widthAnchor.constraint(equalTo: presetsTableView.widthAnchor, multiplier: 0.70),
            dataSource.noPresetsLabel.heightAnchor.constraint(equalTo: presetsTableView.heightAnchor, multiplier: 0.30),
        ])
        
        navigationItem.rightBarButtonItem =  UIBarButtonItem(title: nil, image: UIImage(systemName: "plus"), primaryAction: nil, menu: addImage())
    }
    
    func notifications() {
        
       //sends out notifications to other classes in this view controller
        
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

        fetchPresets()
        presetsTableView.dataSource = dataSource
        dataSource.tablePresets = presets
        presetsTableView.delegate = self
        presetsTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //when the user selects a row, give that row a checkmark accessory,append it to the selectedPresets array, and send a notification to the isImageSelected class, which checks if theres an image
        self.dataSource.tablePresets[indexPath.row].isSelected = true
    
        NotificationCenter.default.post(name: Notification.Name( "isImageSelected"), object: nil)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        //remove the cell from the selectedPresets array and its accessory.
        self.dataSource.tablePresets[indexPath.row].isSelected = false
        
        NotificationCenter.default.post(name: Notification.Name( "isImageSelected"), object: nil)

    }
    
    //Button code
    
    @objc func addImage() -> UIMenu {
        var listofsources = [UIAction]()
        
        for sort in Sources.allCases {
           
            listofsources.append( UIAction(title: "\(sort.title)", image: sort.icon, identifier: nil, attributes: []) { _ in
               
                selectedSource = sort.title
                NotificationCenter.default.post(name: Notification.Name( "sourceSelected"), object: nil)
           })
        }
        
        return UIMenu(title: "Import image from...", image: nil, identifier: nil, options: [], children: listofsources)
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
                print("Encountered an error while selecting a source")
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
    
    @objc func resizeButtonTapped(_ sender: UIButton) {
        //if the user turned the aspect ratio locked switch on, the resizeImageWithAspectRatio() function runs, and if the switch is off, then run the resizeImage() function, which doesn't keep the aspect ratio the same
        
        for dimension in dataSource.tablePresets.filter({ return $0.isSelected }).map({$0.dimension}) {
         
            let newImage = (imageView.image?.resizeImage(dimension: dimension!, maintainAspectRatio: aspectRatioLocked.isOn))!
            imageDetails.append(newImage)
        }
        
        //brings up the resizedImagesController() modal popover
        resizedImagesStoryboard()
    }
    
    @objc func addPresetButtonTapped(_ sender: UIButton) {
        //if the user taps the Add Preset button, a popover pops up allowing the user to enter a preset
        isEditingDimension = false
        
        showPopup()
    }
    
    func showPopup() {
        var dimension: (Int, Int)?
        
        if isEditingDimension == true {
            dimension = dataSource.tablePresets[UserDefaults.standard.integer(forKey: "row")].dimension?.getHeightWidth()
        }
        
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            let vc = AddPresetViewController()
            let navigationController = UINavigationController(rootViewController: vc)
            
            navigationController.modalPresentationStyle = UIModalPresentationStyle.popover
            navigationController.preferredContentSize = CGSize(width: 400, height: 200)

            if isEditingDimension == true {
                vc.index = UserDefaults.standard.integer(forKey: "row")
            }
            
            self.present(navigationController, animated: true, completion: nil)
            
            let popoverPresentationController = vc.popoverPresentationController
           popoverPresentationController?.sourceView = addPresetButton
           popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
            
        case .mac:
                
            let activity = NSUserActivity(activityType: "addPreset")
            activity.userInfo = ["index": UserDefaults.standard.integer(forKey: "row")]

            UIApplication.shared.requestSceneSessionActivation(nil, userActivity: activity, options: nil) { (error) in
                print(error)
            }

            default:
                break
        }

    }
    
    //Context Menu code
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
       
        //saves the row the user bought the context menu appear on in row
        
        UserDefaults.standard.set(indexPath.row, forKey: "row")
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
                    
                deletePreset(preset: dataSource.tablePresets[indexPath.row])
                
                self.dataSource.tablePresets.remove(at: indexPath.row)
        
                presetsTableView.reloadData()
                
            }
            return UIMenu(title: "", children: [editAction, deleteAction])
        }
    }
    
    func resizedImagesStoryboard() {
        #if targetEnvironment(macCatalyst)

            let activity = NSUserActivity(activityType: "resizeImages")
            UIApplication.shared.requestSceneSessionActivation(nil, userActivity: activity, options: nil) { (error) in
                print(error)
            }
        
        #else
            
            let vc = resizedImagesController()
            self.present(vc, animated: true, completion: nil)
        #endif
    }
    
    override func viewWillAppear(_ animated: Bool) {
        #if targetEnvironment(macCatalyst)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        #endif
    }
}
