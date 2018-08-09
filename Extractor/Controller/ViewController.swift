//
//  ViewController.swift
//  Extractor
//
//  Created by David East on 6/10/18.
//  Copyright © 2018 David East. All rights reserved.
//

import UIKit
import MobileCoreServices
import Firebase

class ViewController: UIViewController {
  
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var textView: UITextView!
  @IBOutlet weak var cameraButton: UIButton!
  
  let processor = ScaledElementProcessor()
  var frameSublayer = CALayer()
  var scannedText: String = "Detected text can be edited here." {
    didSet {
      textView.text = scannedText
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Notifications to slide the keyboard up
    NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    
    imageView.layer.addSublayer(frameSublayer)
    
    drawFeatures(in: imageView)
  }
  
  private func removeFrames() {
    guard let sublayers = frameSublayer.sublayers else { return }
    for sublayer in sublayers {
      sublayer.removeFromSuperlayer()
    }
  }
  
  private func drawFeatures(in imageView: UIImageView, completion: (() -> Void)? = nil) {
    removeFrames()
    processor.process(in: imageView) { text, elements in
      elements.forEach() { element in
        self.frameSublayer.addSublayer(element.shapeLayer)
      }
      self.scannedText = text
      completion?()
    }
  }
  
  // MARK: Actions
  
  @IBAction func cameraDidTouch(_ sender: UIButton) {
    presentImagePickerController(withSourceType: .camera)
  }
  
  @IBAction func libraryDidTouch(_ sender: UIButton) {
    presentImagePickerController(withSourceType: .photoLibrary)
  }
  
  @IBAction func shareDidTouch(_ sender: UIBarButtonItem) {
    let vc = UIActivityViewController(activityItems: [textView.text, imageView.image!], applicationActivities: [])
    present(vc, animated: true, completion: nil)
  }
  
  // MARK: Keyboard slide up
  @objc func keyboardWillShow(notification: NSNotification) {
    if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
      if self.view.frame.origin.y == 0{
        self.view.frame.origin.y -= keyboardSize.height
      }
    }
  }
  
  @objc func keyboardWillHide(notification: NSNotification) {
    if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
      if self.view.frame.origin.y != 0{
        self.view.frame.origin.y += keyboardSize.height
      }
    }
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
      let fixedImage = pickedImage.fixOrientation()
      imageView.image = fixedImage
      drawFeatures(in: imageView)
    }
    dismiss(animated: true, completion: nil)
  }
}

