//
//  resizedImagesController.swift
//  imageResizer
//
//  Created by Jared Kozar on 6/6/21.
//

import UIKit

class resizedImagesController: UICollectionViewController {

    var imageDetails = [Images]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Resized Images"
        // Do any additional setup after loading the view.
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "person", for: indexPath) as? ImageCell else {
            fatalError("Unable to dequeue PersonCell.")
        }


        // if we're still here it means we got a PersonCell, so we can return it
        return cell
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
