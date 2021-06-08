//
//  resizedImagesController.swift
//  imageResizer
//
//  Created by Jared Kozar on 6/6/21.
//

import UIKit

class resizedImagesController: UICollectionViewController {

    var imageDetails = [Images]()
    var cellImage: UIImage!
    var dimension: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Resized Images"
        
        // Do any additional setup after loading the view.
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPhoto))
        
        let cell = Images(dimensions: dimension, image: cellImage)
        imageDetails.append(cell)
        collectionView.reloadData()
    }
    
    @objc func addNewPhoto() {
        print("Hell")
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageDetails.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "image", for: indexPath) as? ImageCell else {
            fatalError("Unable to dequeue PersonCell.")
        }

        
        let image = imageDetails[indexPath.item]

        cell.dimensions.text = image.dimensions

        cell.imageView.image = image.image
        
        // if we're still here it means we got a PersonCell, so we can return it
        return cell
    }
    
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    //

}
