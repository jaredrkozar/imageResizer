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
    var height = String()
    var width = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.preferredContentSize = CGSize(width: 400, height: 250)
        self.savePresetButton.isEnabled = false
        savePresetButton.alpha = 0.5;
        
        widthField.text = width
        heightField.text = height
    }
    
    override func viewWillLayoutSubviews() {
       let width = self.view.frame.width
       let navigationBar: UINavigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: width, height: 60))
       self.view.addSubview(navigationBar);
       let navigationItem = UINavigationItem(title: "Add Preset")

       navigationBar.setItems([navigationItem], animated: false)
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
        
        UserDefaults.standard.set(width, forKey: "width")
        UserDefaults.standard.set(height, forKey: "height")
        
        NotificationCenter.default.post(name: Notification.Name( "widthHeightEntered"), object: nil)
        
        NotificationCenter.default.post(name: Notification.Name( "addWidthHeighttoTable"), object: nil)
    
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
