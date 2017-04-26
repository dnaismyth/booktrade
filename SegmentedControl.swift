//
//  SegmentedControl.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-03-23.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit

@IBDesignable class SegmentedControl: UISegmentedControl {
    
    @IBInspectable var background: UIColor = UIColor.clear {
        didSet {
            backgroundColor = background
        }
    }
    
    @IBInspectable var tint: UIColor = UIColor.clear {
        didSet {
            tintColor = tint
        }
    }
    
    @IBInspectable var height : CGFloat = 0.0 {
        didSet {
            layer.frame = CGRect(x: layer.frame.minX, y: layer.frame.minY, width: layer.frame.width, height: height)
        }
    }
    
    @IBInspectable var fontSize : CGFloat = 0.0 {
        didSet {
            self.setFontSize(fontSize: fontSize)
        }
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
    }
    
    func setFontSize(fontSize: CGFloat) {
        
        let normalTextAttributes: [NSObject : AnyObject] = [
            NSForegroundColorAttributeName as NSObject: Constants.COLOR.appColor,
            NSFontAttributeName as NSObject: UIFont.systemFont(ofSize: fontSize, weight: UIFontWeightRegular)
        ]
        
        let boldTextAttributes: [NSObject : AnyObject] = [
            NSForegroundColorAttributeName as NSObject : Constants.COLOR.appColor,
            NSFontAttributeName as NSObject : UIFont.systemFont(ofSize: fontSize, weight: UIFontWeightMedium),
            ]
        
        self.setTitleTextAttributes(normalTextAttributes, for: .normal)
        self.setTitleTextAttributes(normalTextAttributes, for: .highlighted)
        self.setTitleTextAttributes(boldTextAttributes, for: .selected)
    }
}
