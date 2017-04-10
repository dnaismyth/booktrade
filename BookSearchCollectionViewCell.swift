//
//  BookSearchCollectionViewCell.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-04-04.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit

// Delegate used to select the current user's profile that has been selected from cell
protocol ProfileSelectDelegate{
    func ownerAvatarTapped(cell : BookSearchCollectionViewCell)
    func ownerNameTapped(cell : BookSearchCollectionViewCell)
}
class BookSearchCollectionViewCell: UICollectionViewCell, UIGestureRecognizerDelegate {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var coverImage: UIImageView!
    @IBOutlet var ownerName: UIButton!
    @IBOutlet var ownerAvatar: UIButton!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var uploadedTime: UILabel!
    
    var delegate:ProfileSelectDelegate!

    // Book Author
    var author : String?
    
    // Book id
    var bookId : Int?
    
    // Book barcode
    var barcode : String?
    
    // Condition of the book
    var condition: String?
    
    // Status of the book (trade/sell/sold/traded)
    var status : String?
    
    // Description or information about the sell/trade
    var itemDescription : String?
    
    // Id of the book owner
    var ownerId : Int?
    
    // Owner's location
    var location : String?
    
    // Owner's bio
    var ownersBio : String?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.layer.shadowOpacity = 0.25
        self.layer.shadowRadius = 0.6
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.masksToBounds = false
    }
    
    @IBAction func ownerAvatarButton(_ sender: AnyObject) {
        delegate?.ownerAvatarTapped(cell: self)
    }
    
    @IBAction func ownerNameButton(_ sender: AnyObject) {
        delegate?.ownerNameTapped(cell: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
