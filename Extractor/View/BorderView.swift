//
//  BorderView.swift
//  Extractor
//
//  Created by David East on 6/10/18.
//  Copyright © 2018 David East. All rights reserved.
//

import UIKit

@IBDesignable
class BorderView : UIView {
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    applyBorder()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    applyBorder()
  }
  
  func applyBorder() {
    self.layer.borderColor = UIColor.black.cgColor
    self.layer.borderWidth = 2.0
  }
  
}
