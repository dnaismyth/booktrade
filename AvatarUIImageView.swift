//
//  AvatarUIImageView.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-03-28.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit

@IBDesignable class AvatarUIImageView: UIImageView {
    
    @IBInspectable var borderWidth: CGFloat = 0.0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet{
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupImageView()
    }
    
    func setupImageView() {
        self.layer.cornerRadius = self.layer.frame.size.width/2
        self.clipsToBounds = true
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
