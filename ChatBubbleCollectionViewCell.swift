//
//  ChatBubbleCollectionViewCell.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-04-22.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit

class ChatBubbleCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet var bubbleView: UIView!
    @IBOutlet var messageText: UITextView!
    
    override func awakeFromNib() {
        self.bubbleView.cornerRadius()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
