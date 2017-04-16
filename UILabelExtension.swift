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
        self.layer.cornerRadius = CGFloat(Constants.DESIGN.cellRadius)
        self.textAlignment = NSTextAlignment.center
        self.textColor = UIColor.white
    }
}
