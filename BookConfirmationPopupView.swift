//
//  BookConfirmationPopupView.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-04-13.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit

protocol BookConfirmationPopupViewDelegate {
    func continueIsSelected(popup : BookConfirmationPopupView)
    func tryAgainIsSelected(popup : BookConfirmationPopupView)
}
class BookConfirmationPopupView: UIView {
    
    @IBOutlet var popupTitleLabel: UILabel!
    @IBOutlet var coverImage: UIImageView!
    @IBOutlet var bookTitle: UILabel!
    @IBOutlet var authorLabel: UILabel!
    @IBOutlet var continueButton: UIButton!
    @IBOutlet var tryAgainButton: UIButton!
    
    var contentView:UIView!
    var delegate : BookConfirmationPopupViewDelegate!
    
    //MARK:
    func loadViewFromNib() {
        contentView = Bundle.main.loadNibNamed("BookConfirmationPopup", owner: self, options: nil)?[0] as! UIView
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.frame = bounds
        addSubview(contentView)
    }
    
    
    //MARK:
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        loadViewFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        loadViewFromNib()
    }
    
    @IBAction func continueAction(_ sender: Any) {
        self.delegate?.continueIsSelected(popup: self)
    }
    
    @IBAction func tryAgainAction(_ sender: Any) {
        self.delegate?.tryAgainIsSelected(popup: self)
    }
    

}
