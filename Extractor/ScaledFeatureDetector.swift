
//  ScaledFeatureDetector.swift
//  Extractor
//
//  Created by David East on 6/11/18.
//  Copyright © 2018 David East. All rights reserved.
//

import Firebase

struct DetectedFeature {
  let frame: CGRect
  let text: String
  let shapeLayer: CAShapeLayer
  let textLayer: CATextLayer
}

class ScaledFeatureDetector {
  
  lazy var vision = Vision.vision()
  var textDetector: VisionTextDetector!
  
  init() {
    textDetector = vision.textDetector()
  }
  
  func detect(in imageView: UIImageView, callback: @escaping (_ text: String, _ scaledFeatures: [DetectedFeature]) -> Void) {
    guard let image = imageView.image else { return }
    let visionImage = VisionImage(image: image)
    var scaledFeatures: [DetectedFeature] = []
    textDetector.detect(in: visionImage) { features, error in
      guard error == nil, let features = features, !features.isEmpty else {
        // Add question mark layer
        scaledFeatures = [self.createQuestionLayer(frame: imageView.frame, image: image, view: imageView)]
        callback("", scaledFeatures)
        return
      }
      let result = self.processDetectedFeatures(features: features, image: image, view: imageView)
      callback(result.text, result.features)
    }
  }
  
  private func processDetectedFeatures(features: [VisionText], image: UIImage, view: UIView) -> (text: String, features: [DetectedFeature]) {
    var scaledFeatures: [DetectedFeature] = []
    var scannedText = ""
    for feature in features {
      scannedText = "\(scannedText) \(feature.text)"
      if let block = feature as? VisionTextBlock {
        for line in block.lines {
          for element in line.elements {
            let detectedFrame = self.createDetectedFeature(
              frame: element.frame,
              text: element.text,
              image: image,
              view: view
            )
            scaledFeatures.append(detectedFrame)
          }
        }
      }
    }
    return (text: scannedText, features: scaledFeatures)
  }
  
  private func createScaledFrame(featureFrame: CGRect, imageSize: CGSize, viewFrame: CGRect) -> CGRect {
    let viewSize = viewFrame.size
    
    // Find resolution for the view and image
    let rView = viewSize.width / viewSize.height
    let rImage = imageSize.width / imageSize.height
    
    // Define scale based on comparing resolutions
    var scale: CGFloat
    if rView > rImage {
      scale = viewSize.height / imageSize.height
    } else {
      scale = viewSize.width / imageSize.width
    }
    
    // Calculate scaled feature frame size
    let featureWidthScaled = featureFrame.size.width * scale
    let featureHeightScaled = featureFrame.size.height * scale
    
    // Calculate scaled feature frame top-left point
    let imageWidthScaled = imageSize.width * scale
    let imageHeightScaled = imageSize.height * scale
    
    let imagePointXScaled = (viewSize.width - imageWidthScaled) / 2
    let imagePointYScaled = (viewSize.height - imageHeightScaled) / 2
    
    let featurePointXScaled = imagePointXScaled + featureFrame.origin.x * scale
    let featurePointYScaled = imagePointYScaled + featureFrame.origin.y * scale
    
    // Define a rect for scaled feature frame
    return CGRect(x: featurePointXScaled,
                  y: featurePointYScaled,
                  width: featureWidthScaled,
                  height: featureHeightScaled)
  }
  
  private func createLayers(frame: CGRect, text: String? = nil, fontSize: CGFloat) -> (shape: CAShapeLayer, text: CATextLayer) {
    let shapeLayer = createShapeLayer(frame: frame)
    let textLayer = createTextLayer(frame: frame, text: text, fontSize: fontSize)
    return (shape: shapeLayer, text: textLayer);
  }
  
  private func createShapeLayer(frame: CGRect) -> CAShapeLayer {
    let bpath: UIBezierPath = UIBezierPath(rect: frame)
    let shapeLayer = CAShapeLayer()
    shapeLayer.path = bpath.cgPath
    shapeLayer.strokeColor = Constants.lineColor
    shapeLayer.fillColor = Constants.fillColor
    shapeLayer.lineWidth = Constants.lineWidth
    return shapeLayer
  }

  private func createTextLayer(frame: CGRect, text: String?, fontSize: CGFloat) -> CATextLayer {
    let textLayer = CATextLayer()
    if let text = text {
      textLayer.string = text
      textLayer.fontSize = fontSize
      textLayer.foregroundColor = Constants.lineColor
      let center = CGPoint(x: frame.midX, y: frame.midY)
      textLayer.position = center
      textLayer.frame = frame
      textLayer.alignmentMode = kCAAlignmentCenter
      textLayer.contentsScale = UIScreen.main.scale
    }
    return textLayer
  }
  
  private func createDetectedFeature(frame: CGRect, text: String, image: UIImage, view: UIView, fontSize: CGFloat = 12.0) -> DetectedFeature {
    let frame = self.createScaledFrame(featureFrame: frame, imageSize: image.size, viewFrame: view.frame)
    let layers = self.createLayers(frame: frame, text: text, fontSize: fontSize)
    return DetectedFeature(frame: frame, text: text, shapeLayer: layers.shape, textLayer: layers.text)
  }
  
  private func createQuestionLayer(frame: CGRect, image: UIImage, view: UIView) -> DetectedFeature {
    return createDetectedFeature(frame: frame, text: "?", image: image, view: view, fontSize: 34.0)
  }
  
  // MARK: - Fileprivate
  
  fileprivate enum Constants {
    static let lineWidth: CGFloat = 3.0
    static let lineColor = UIColor.yellow.cgColor
    static let fillColor = UIColor.clear.cgColor
  }
}
