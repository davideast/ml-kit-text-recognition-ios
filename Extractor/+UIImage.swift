/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit

extension UIImage {
  
  // Thx to: https://stackoverflow.com/questions/8915630/ios-uiimageview-how-to-handle-uiimage-image-orientation
  func fixOrientation() -> UIImage? {
    
    guard let cgImage = self.cgImage else {
      return nil
    }
    
    if self.imageOrientation == UIImage.Orientation.up {
      return self
    }
    
    let width  = self.size.width
    let height = self.size.height
    
    var transform = CGAffineTransform.identity
    
    switch self.imageOrientation {
    case .down, .downMirrored:
      transform = transform.translatedBy(x: width, y: height)
      transform = transform.rotated(by: CGFloat.pi)
      
    case .left, .leftMirrored:
      transform = transform.translatedBy(x: width, y: 0)
      transform = transform.rotated(by: 0.5*CGFloat.pi)
      
    case .right, .rightMirrored:
      transform = transform.translatedBy(x: 0, y: height)
      transform = transform.rotated(by: -0.5*CGFloat.pi)
      
    case .up, .upMirrored:
      break
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    guard let colorSpace = cgImage.colorSpace else {
      return nil
    }
    
    guard let context = CGContext(
      data: nil,
      width: Int(width),
      height: Int(height),
      bitsPerComponent: cgImage.bitsPerComponent,
      bytesPerRow: 0,
      space: colorSpace,
      bitmapInfo: UInt32(cgImage.bitmapInfo.rawValue)
      ) else {
        return nil
    }
    
    context.concatenate(transform);
    
    switch self.imageOrientation {
      
    case .left, .leftMirrored, .right, .rightMirrored:
      // Grr...
      context.draw(cgImage, in: CGRect(x: 0, y: 0, width: height, height: width))
      
    default:
      context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
    }
    
    // And now we just create a new UIImage from the drawing context
    guard let newCGImg = context.makeImage() else {
      return nil
    }
    
    let img = UIImage(cgImage: newCGImg)
    
    return img;
  }
  
}
