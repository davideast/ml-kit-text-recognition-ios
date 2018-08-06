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
  @IBOutlet weak var textView: UITextView!
  @IBOutlet weak var cameraButton: UIButton!
  
  var frameSublayer = CALayer()
  var scannedText: String = "Detected text can be edited here." {
    didSet {
      textView.text = scannedText
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Notifications to slide the keyboard up
    NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    
    // Disable camera button if no camera exists
    if !UIImagePickerController.isSourceTypeAvailable(.camera) {
      cameraButton.isHidden = true
    }
    
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
  
  // Mark: Keyboard slide up
  @objc func keyboardWillShow(notification: NSNotification) {
    if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
      if self.view.frame.origin.y == 0{
        self.view.frame.origin.y -= keyboardSize.height
      }
    }
  }
  
  @objc func keyboardWillHide(notification: NSNotification) {
    if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
      if self.view.frame.origin.y != 0{
        self.view.frame.origin.y += keyboardSize.height
      }
    }
  }
}

extension ViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate {
  
  // MARK: UIImagePickerController
  
  private func presentImagePickerController(withSourceType sourceType: UIImagePickerController.SourceType) {
    let controller = UIImagePickerController()
    controller.delegate = self
    controller.sourceType = sourceType
    controller.mediaTypes = [String(kUTTypeImage), String(kUTTypeMovie)]
    present(controller, animated: true, completion: nil)
  }
  
  // MARK: UIImagePickerController Delegate
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

    if let pickedImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
      imageView.contentMode = .scaleAspectFit
      imageView.image = pickedImage
    }
    dismiss(animated: true, completion: nil)
  }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
