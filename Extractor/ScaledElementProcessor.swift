
//  ScaledFeatureDetector.swift
//  Extractor
//
//  Created by David East on 6/11/18.
//  Copyright © 2018 David East. All rights reserved.
//

import Firebase

struct ScaledElement {
  let frame: CGRect
  let shapeLayer: CALayer
}

class ScaledElementProcessor {
  let vision = Vision.vision()
  var textRecognizer: VisionTextRecognizer!
  
  init() {
    textRecognizer = vision.onDeviceTextRecognizer()
  }
  
  // 1
  func process(in imageView: UIImageView, callback: @escaping (_ text: String, _ scaledElements: [ScaledElement]) -> Void) {
    guard let image = imageView.image else { return }
    let visionImage = VisionImage(image: image)
    
    textRecognizer.process(visionImage) { result, error in
      guard error == nil, let result = result, !result.text.isEmpty else {
        callback("", [])
        return
      }
      
      // 2
      var scaledElements: [ScaledElement] = []
      // 3
      for block in result.blocks {
        for line in block.lines {
          for element in line.elements {
            // 1
            let frame = self.createScaledFrame(featureFrame: element.frame, imageSize: image.size, viewFrame: imageView.frame)
            let shapeLayer = self.createShapeLayer(frame: frame)
            let scaledElement = ScaledElement(frame: frame, shapeLayer: shapeLayer)
            scaledElements.append(scaledElement)
          }
        }
      }
      
      callback(result.text, scaledElements)
    }
  }
  
  private func createShapeLayer(frame: CGRect) -> CAShapeLayer {
    // 1
    let bpath: UIBezierPath = UIBezierPath(rect: frame)
    let shapeLayer = CAShapeLayer()
    shapeLayer.path = bpath.cgPath
    // 2
    shapeLayer.strokeColor = Constants.lineColor
    shapeLayer.fillColor = Constants.fillColor
    shapeLayer.lineWidth = Constants.lineWidth
    return shapeLayer
  }
  
  // 1
  private func createScaledFrame(featureFrame: CGRect, imageSize: CGSize, viewFrame: CGRect) -> CGRect {
    let viewSize = viewFrame.size
    
    // 2
    let resolutionView = viewSize.width / viewSize.height
    let resolutionImage = imageSize.width / imageSize.height
    
    // 3
    var scale: CGFloat
    if resolutionView > resolutionImage {
      scale = viewSize.height / imageSize.height
    } else {
      scale = viewSize.width / imageSize.width
    }
    
    // 4
    let featureWidthScaled = featureFrame.size.width * scale
    let featureHeightScaled = featureFrame.size.height * scale
    
    // 5
    let imageWidthScaled = imageSize.width * scale
    let imageHeightScaled = imageSize.height * scale
    let imagePointXScaled = (viewSize.width - imageWidthScaled) / 2
    let imagePointYScaled = (viewSize.height - imageHeightScaled) / 2
    
    // 6
    let featurePointXScaled = imagePointXScaled + featureFrame.origin.x * scale
    let featurePointYScaled = imagePointYScaled + featureFrame.origin.y * scale
    
    // 7
    return CGRect(x: featurePointXScaled,
                  y: featurePointYScaled,
                  width: featureWidthScaled,
                  height: featureHeightScaled)
  }
  
  // MARK: - Fileprivate
  
  // 3
  fileprivate enum Constants {
    static let lineWidth: CGFloat = 3.0
    static let lineColor = UIColor.yellow.cgColor
    static let fillColor = UIColor.clear.cgColor
  }
}
