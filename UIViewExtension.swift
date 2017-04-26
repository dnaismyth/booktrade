//
//  UIViewExtension.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-04-17.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func dropShadow(){
        self.layer.shadowOpacity = 0.25
        self.layer.shadowRadius = 0.6
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowColor = UIColor.lightGray.cgColor
    }
    
    func cornerRadius(){
        self.layer.cornerRadius = CGFloat(Constants.DESIGN.cellRadius)
    }
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }

}
