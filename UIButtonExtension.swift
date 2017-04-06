//
//  UIButtonExtension.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-04-05.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    
    func setBackgroundColor(color: UIColor, forState: UIControlState) {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()!.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.setBackgroundImage(colorImage, for: forState)
    }
}
