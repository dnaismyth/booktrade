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
    
    var conversationId : Int?   // id of the conversation
    var unseenMessages : Int?   // # of messages that are unseen
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
