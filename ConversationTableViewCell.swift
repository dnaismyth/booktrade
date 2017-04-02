//
//  ConversationTableViewCell.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-04-01.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit

class ConversationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var receivedFrom: UILabel!
    @IBOutlet weak var lastReceived: UILabel!
    @IBOutlet weak var bookTitle: UILabel!
    @IBOutlet weak var unreadMessage: UILabel!
    
    var conversationId : Int?   // id of the conversation
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.unreadMessage.isHidden = true
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
