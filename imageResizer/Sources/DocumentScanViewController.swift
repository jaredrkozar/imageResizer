//
//  DocumentScanViewController.swift
//  DocumentScanViewController
//
//  Created by Jared Kozar on 9/21/21.
//

import UIKit
import VisionKit
import Vision

extension ViewController: VNDocumentCameraViewControllerDelegate {

    @objc func presentDocumentScanner() {
        let vc = VNDocumentCameraViewController()
        vc.delegate = self
        self.present(vc, animated: true)
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        let errorAlert = UIAlertController(title: "Failed to scan document", message: "The document couldn't be scanned right now. Please try again.", preferredStyle: .alert)
        
        errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        present(errorAlert, animated: true)
        
        controller.dismiss(animated: true)
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func documentCameraViewController(_ controller:            VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        // Process the scanned pages
        
        let scannedDocImage = scan.imageOfPage(at: 0)
        
        imageView.image = scannedDocImage
        
        controller.dismiss(animated: true)
        print("Finished scanning document \(kCGPDFContextTitle)")

        NotificationCenter.default.post(name: Notification.Name( "isImageSelected"), object: nil)
    }
    
}
