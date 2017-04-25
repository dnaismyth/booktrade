//
//  ResponseBubbleCollectionViewCell.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-04-23.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit

class ResponseBubbleCollectionViewCell: UICollectionViewCell {
    @IBOutlet var avatarImageView: AvatarUIImageView!
    @IBOutlet var messageText: UITextView!
    @IBOutlet var bubbleView: UIView!
    
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
