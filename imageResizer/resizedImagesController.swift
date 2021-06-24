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
    var imageArray = [UIImage]()
    var dimensionArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Resized Images"
        
        // Do any additional setup after loading the view.


        collectionView.reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        let width = self.view.frame.width
        let navigationBar: UINavigationBar = UINavigationBar(frame: CGRect(x: 0, y: 4, width: width, height: 60))
        self.view.addSubview(navigationBar);
        let navigationItem = UINavigationItem(title: "Resized Images")
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: nil, action: #selector(doneButtonTapped(_:)))
        navigationItem.rightBarButtonItem = doneButton
        navigationBar.setItems([navigationItem], animated: false)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageDetails.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "image", for: indexPath) as? ImageCell else {
            fatalError("Unable to dequeue the image cell.")
        }
        
        let image = imageDetails[indexPath.item]

        cell.dimensions.text = image.dimensions

        cell.imageView.image = image.image

        return cell
    }
    
    
    @objc func doneButtonTapped(_ sender: Any) {
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
