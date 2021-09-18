//
//  EditPresetViewController.swift
//  imageResizer
//
//  Created by Jared Kozar on 6/20/21.
//

import UIKit

class EditPresetViewController: UIViewController {


    @IBOutlet var editedHeightField: UITextField!
    
    @IBOutlet var editedWidthField: UITextField!
    
    @IBOutlet var savePresetButton: StandardButton!
    let nc = NotificationCenter.default
    var height = String()
    var width = String()
    let editedDimension = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //disables the save preset button, and gets the width and height, and fills those values in in their respective text fields

       
        
    }
    
    @IBAction func checkText(_ sender: Any) {
        //if the edited height field or edited width fields are empty, the save preset button is disabled, but if both fields have text, they are enabled
        
        if editedHeightField.text!.isEmpty || editedWidthField.text!.isEmpty {
            self.savePresetButton.isEnabled = false
            savePresetButton.alpha = 0.5;
        } else {
            self.savePresetButton.isEnabled = true
            savePresetButton.alpha = 1.0;
        }
    }
    
    @IBAction func saveEditPresetButtonTapped(_ sender: Any) {
        //gets the text in the edited height and width field's UITextField, and  concatenate them together to get the edited  dimension. This dimension is saved, where itreplaces the dimension that was at the cell the user wanted to edit
        
        let editedWidth = editedWidthField.text
        let editedHeight = editedHeightField.text
        
        let editedDimension = "\(editedHeight!) x \(editedWidth!)"
        UserDefaults.standard.set(editedDimension, forKey: "editedDimension")
        dismiss(animated: true, completion: nil)
        
        NotificationCenter.default.post(name: Notification.Name( "editedPreset"), object: nil)
    }
}
