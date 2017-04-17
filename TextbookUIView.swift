//
//  TextbookUIView.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-04-16.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit

class TextbookUIView : UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.beginPath()
        context.move(to: CGPoint(x: rect.maxX, y: rect.maxY))
        context.addLine(to: CGPoint(x: (rect.maxX), y: rect.minY))
        context.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        context.closePath()
        
        context.setFillColor(UIColor(red:0.82, green:0.30, blue:0.30, alpha:0.7).cgColor)
        context.fillPath()
    }
}
