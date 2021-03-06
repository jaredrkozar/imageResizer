//
//  AddPresetViewController.swift
//  imageResizer
//
//  Created by Jared Kozar on 6/1/21.
//

import UIKit


class AddPresetViewController: UIViewController {

    @IBOutlet var heightField: UITextField!
    
    @IBOutlet var widthField: UITextField!
    
    @IBOutlet var savePresetButton: StandardButton!
    
    let nc = NotificationCenter.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            savePresetButton.isHidden = false
        case .mac:
            savePresetButton.isHidden = true
        default:
            break
        }
        
       
        if isEditingDimension == false {
            //disables the save preset button
            self.savePresetButton.isEnabled = false
            savePresetButton.alpha = 0.5;
            
            title = "Add Preset"
        } else {
            self.savePresetButton.isEnabled = true
            savePresetButton.alpha = 1.0;
            widthField.text = dimensionwidth
            heightField.text = dimensionheight
            
            title = "Edit Preset"
        }
    }
    
    @IBAction func checkText(_ sender: Any) {
        //if the height field or width fields are empty, the save preset button is disabled, but if both fields have text, they are enabled
        
        if heightField.text!.isEmpty || widthField.text!.isEmpty {
            self.savePresetButton.isEnabled = false
            savePresetButton.alpha = 0.5;
        } else {
            self.savePresetButton.isEnabled = true
            savePresetButton.alpha = 1.0;
        }
    }
    
    @IBAction func savePresetButtonTapped(_ sender: StandardButton) {
        //gets the text in the height and width field's UITextField, and  concatenate them together to get the dimension. This dimension is saved, where it's added to the table
        
        let width = widthField.text
        let height = heightField.text
        
        let dimension = "\(height!) x \(width!)"
        UserDefaults.standard.set(dimension, forKey: "dimension")
        
        NotificationCenter.default.post(name: Notification.Name( "addWidthHeighttoTable"), object: nil)
        
        switch UIDevice.current.userInterfaceIdiom {
        case .mac:
            
            if let session = self.view.window?.windowScene?.session {
              let options = UIWindowSceneDestructionRequestOptions()
              options.windowDismissalAnimation = .commit
              UIApplication.shared.requestSceneSessionDestruction(session, options: options, errorHandler: nil)
            }

            default:
                break
        }
        
        dismiss(animated: true, completion: nil)
        
    }
}
