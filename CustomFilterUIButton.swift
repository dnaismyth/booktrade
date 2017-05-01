//
//  CustomFilterUIButton.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-04-30.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit

@IBDesignable final class CustomFilterUIButton: UIButton {
    
     @IBInspectable var image: UIImage = UIImage()
     @IBInspectable var iconTint: UIColor = UIColor.clear
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        self.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
        self.imageView?.tintColor = iconTint
        self.contentMode = .scaleAspectFit
    }
}
