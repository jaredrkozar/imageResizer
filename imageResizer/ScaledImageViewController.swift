//
//  ScaledImageViewController.swift
//  imageResizer
//
//  Created by Jared Kozar on 5/29/21.
//

import UIKit

class ScaledImageViewController: UIViewController {

    var selectedImage = UIImage()
    
    @IBOutlet var scaledImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scaledImageView.image = selectedImage
        
        // Do any additional setup after loading the view.
    }
    

    @IBAction func doneButonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func bringupShareSheet(_ sender: UIBarButtonItem) {
        
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
