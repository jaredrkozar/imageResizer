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
        // Do any additional setup after loading the view.

        self.savePresetButton.isEnabled = false
        savePresetButton.alpha = 0.5;
        
        title = "Add Preset"
    }
    
    @IBAction func checkText(_ sender: Any) {
        
        if heightField.text!.isEmpty || widthField.text!.isEmpty {
            self.savePresetButton.isEnabled = false
            savePresetButton.alpha = 0.5;
        } else {
            self.savePresetButton.isEnabled = true
            savePresetButton.alpha = 1.0;
        }
    }
    
    @IBAction func savePresetButtonTapped(_ sender: StandardButton) {
        
        let width = widthField.text
        let height = heightField.text
        
        let dimension = "\(height!) x \(width!)"
        UserDefaults.standard.set(dimension, forKey: "dimension")
        
        NotificationCenter.default.post(name: Notification.Name( "addWidthHeighttoTable"), object: nil)
        dismiss(animated: true, completion: nil)
        
    }
}
