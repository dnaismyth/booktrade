//
//  FilterSelectedCollectionViewCell.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-04-17.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit

// Delegate used to select the current user's profile that has been selected from cell
protocol FilterSelectCellDelegate{
    func removeFilterSelected(cell : FilterSelectedCollectionViewCell)
}
class FilterSelectedCollectionViewCell: UICollectionViewCell {
    
    var delegate : FilterSelectCellDelegate?
    
    @IBOutlet var removeButton: UIButton!
    @IBOutlet var filterLabel: UILabel!
    
    @IBAction func removeAction(_ sender: Any) {
        self.delegate?.removeFilterSelected(cell: self)
    }
    
}
