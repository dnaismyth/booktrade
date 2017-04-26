//
//  UIImageViewExtension.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-04-25.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit

extension UIImageView {

    // Render the colour of the imageview's image
    func renderImageColor(color: UIColor){
        self.image = self.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        self.tintColor = color
    }
}
