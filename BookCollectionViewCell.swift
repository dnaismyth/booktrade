//
//  BookCollectionViewCell.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-03-28.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit

// Custom class for a book collection cell
class BookCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet var bookTitleLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var uploadedLabel: UILabel!
    @IBOutlet var textbookView: TextbookUIView!
    
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
    
    // Owner name of the book posting
    var ownerName : String?
   
    // Owner avatar of the book posting
    var ownerAvatar : String?
    
    // Id of the book owner
    var ownerId : Int?
    
    // Owner's location
    var location : String?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.layer.masksToBounds = false
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.textbookView.isHidden = true
        self.coverImage.dropShadow()
        self.coverImage.cornerRadius()
        self.textbookView.roundCorners([.topRight], radius: CGFloat(Constants.DESIGN.cellRadius))
    }
    
    
}
