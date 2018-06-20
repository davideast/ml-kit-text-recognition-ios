//
//  TextFrameController.swift
//  Extractor
//
//  Created by David East on 6/18/18.
//  Copyright © 2018 David East. All rights reserved.
//

import Foundation
import Firebase
import UIKit

struct DetectedFeature {
  let frame: CGRect
  let text: String
}

protocol VisionFeatureControllerDelegate {
  func detectFrames(in image: UIImage)
}

class VisionFeatureController {
  
  var delegate: UIViewController?
  
  func detectFeature(in image: UIImage) {
    
  }
  
}
