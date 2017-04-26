//
//  UITextViewExtension.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-04-25.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit

extension UITextField {
    
    func designTextField(iconName : String, tintColor : UIColor, placeholder : String){
        let textFieldIcon = UIImageView(image: UIImage(named: iconName)?.withRenderingMode(UIImageRenderingMode.alwaysTemplate))
        textFieldIcon.tintColor = tintColor
        textFieldIcon.frame = CGRect(x: 8, y: 0, width: 20, height: 20)
        let textFieldPadding: UIView = UIView(frame: CGRect(x:0, y:0, width: 30, height: 20))
        textFieldPadding.addSubview(textFieldIcon)
        self.leftView = textFieldPadding
        self.leftViewMode = UITextFieldViewMode.always
        self.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSForegroundColorAttributeName: Constants.COLOR.placeholder])
        
    }
}
