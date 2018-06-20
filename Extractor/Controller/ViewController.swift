//
//  ViewController.swift
//  Extractor
//
//  Created by David East on 6/10/18.
//  Copyright © 2018 David East. All rights reserved.
//

import UIKit
import MobileCoreServices

class ViewController: UIViewController {
  
  @IBOutlet weak var imageView: UIImageView!
  
  var frameSublayer = CALayer()
  var scannedText = ""
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    imageView.layer.addSublayer(frameSublayer)
  }
  
  // MARK: Actions
  
  @IBAction func cameraDidTouch(_ sender: UIButton) {
    presentImagePickerController(withSourceType: .camera)
  }
  
  @IBAction func libraryDidTouch(_ sender: UIButton) {
    presentImagePickerController(withSourceType: .photoLibrary)
  }
  
  @IBAction func shareDidTouch(_ sender: UIBarButtonItem) {
    let vc = UIActivityViewController(activityItems: [scannedText, imageView.image!], applicationActivities: [])
    present(vc, animated: true, completion: nil)
  }
}

extension ViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate {
  
  // MARK: UIImagePickerController
  
  private func presentImagePickerController(withSourceType sourceType: UIImagePickerControllerSourceType) {
    let controller = UIImagePickerController()
    controller.delegate = self
    controller.sourceType = sourceType
    controller.mediaTypes = [String(kUTTypeImage), String(kUTTypeMovie)]
    present(controller, animated: true, completion: nil)
  }
  
  // MARK: UIImagePickerController Delegate
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
      imageView.contentMode = .scaleAspectFit
      imageView.image = pickedImage
    }
    dismiss(animated: true, completion: nil)
  }
}
