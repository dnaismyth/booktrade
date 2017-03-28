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
    
    // Book title
    var title : String?
    
    // Book Author
    var author : String?
    
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
    
    // Owner's location
    var location : String?
    
}
