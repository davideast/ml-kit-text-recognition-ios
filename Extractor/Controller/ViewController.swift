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
  
  var featureDetector: ScaledFeatureDetector!
  var frameSublayer = CALayer()
  var scannedText: String = "Detected text can be edited here." {
    didSet {
      textView.text = scannedText
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    featureDetector = ScaledFeatureDetector()
    
    imageView.layer.addSublayer(frameSublayer)
    
    // Disable camera button if no camera exists
    if !UIImagePickerController.isSourceTypeAvailable(.camera) {
      cameraButton.isHidden = true
    }
    
    drawFeatures(in: imageView) {
      UIView.animate(withDuration: 0.8) {
        self.imageView.alpha = 1
      }
    }
  }
  
  // MARK: Drawing
  
  private func drawFeatures(in imageView: UIImageView, completion: (() -> Void)? = nil) {
    removeFeatures()
    featureDetector.detect(in: imageView) { text, features in
      features.forEach(self.addLayers)
      self.scannedText = text
      completion?()
    }
  }
  
  private func removeFeatures() {
    guard let sublayers = frameSublayer.sublayers else { return }
    for sublayer in sublayers {
      sublayer.removeFromSuperlayer()
    }
  }
  
  private func addLayers(from feature: DetectedFeature) {
    frameSublayer.addSublayer(feature.shapeLayer)
    frameSublayer.addSublayer(feature.textLayer)
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
      let fixedImage = pickedImage.fixOrientation()
      imageView.image = fixedImage
      drawFeatures(in: imageView)
    }
    dismiss(animated: true, completion: nil)
  }
}
