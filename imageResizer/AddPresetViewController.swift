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
        title = "Add Preset"
        // Do any additional setup after loading the view.
        
        savePresetButton.isEnabled = false
        savePresetButton.alpha = 0.5;
    }
    
    @IBAction func checkText(_ sender: Any) {
        
        if widthField.text != "" && heightField.text != "" {
            savePresetButton.isEnabled = true;
            savePresetButton.alpha = 1.0;
        }
    }
    @IBAction func savePresetButtonTapped(_ sender: StandardButton) {
        let width = widthField.text
        let height = heightField.text
        NotificationCenter.default.post(name: Notification.Name( "widthHeightEntered"), object: nil)
        
        NotificationCenter.default.post(name: Notification.Name( "addWidthHeighttoTable"), object: nil)
        
        
        UserDefaults.standard.set(width, forKey: "width")
        UserDefaults.standard.set(height, forKey: "height")
        dismiss(animated: true, completion: nil)
        
    }
        
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
