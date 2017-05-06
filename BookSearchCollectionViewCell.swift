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
    @IBOutlet var labelView: UIView!
    @IBOutlet var textbookView: UIView!
    @IBOutlet var bookBannerImage: UIImageView!
    @IBOutlet var textbookImage: UIImageView!
    
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
    
    // Book Categories
    var categories: [String] = []
    
    // Id of the book owner
    var ownerId : Int?
    
    // Owner's location
    var location : String?
    
    // Owner's bio
    var ownersBio : String?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
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
        self.textbookView.isHidden = false
        self.bookBannerImage.tintColor = Constants.COLOR.foxOrange
        self.textbookImage.tintColor = UIColor.white
        self.labelView.dropShadow()
        //self.coverImage.dropShadow()
        //self.labelView.dropShadow()
        //self.labelView.roundCorners([.bottomLeft, .bottomRight], radius: CGFloat(Constants.DESIGN.cellRadius))
        //self.coverImage.cornerRadius()
        //self.textbookView.roundCorners([.topRight], radius: CGFloat(Constants.DESIGN.cellRadius))
    }

}
