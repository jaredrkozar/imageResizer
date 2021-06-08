//
//  TestViewController.swift
//  imageResizer
//
//  Created by Jared Kozar on 6/7/21.
//

import UIKit

class TestViewController: UIViewController {

    @IBOutlet var testImg: UIImageView!
    var cellImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if cellImage != nil {
            testImg.image  = cellImage
        } else {
            print("WWWW")
        }
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
