//
//  UILabelExtension.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-04-16.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit

extension UILabel {
    
    // Free label for book if book category = free
    func createFreeLabel(){
        self.text = "Free"
        self.backgroundColor = Constants.COLOR.freeGreen
        //self.layer.cornerRadius = CGFloat(Constants.DESIGN.cellRadius)
        self.textAlignment = NSTextAlignment.center
        self.textColor = UIColor.white
        let frameSize: CGSize = self.frame.size
        self.frame.size = CGSize(width: 34, height: frameSize.height)
    }
    
    func diagonalLabel(){
        let frame : CGRect = self.frame;
        self.layer.anchorPoint = CGPoint( x: (frame.size.height / (frame.size.width * 0.5)), y: 0.5)
        self.frame = frame;
        let rotate : CGAffineTransform = CGAffineTransform(rotationAngle: CGFloat(CGFloat.pi/4))
        self.transform = rotate
    }
}
