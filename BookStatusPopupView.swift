//
//  BookStatusPopupView.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-04-10.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit

protocol BookStatusPopupDelegate{
    func bookPopupIsDismissed(popup : BookStatusPopupView)
    func bookPopupDeletePressed(popup : BookStatusPopupView)
    func bookPopupUpdateStatusPressed(popup : BookStatusPopupView)
}
class BookStatusPopupView: UIView {
    
    let userDefaults = Foundation.UserDefaults.standard
    var contentView:UIView!
    var bookId : Int?
    var cellIndexPath : IndexPath?  // index path in which the cell been selected from to show popup
    var updatedStatus : String?
    var delegate : BookStatusPopupDelegate!
    @IBOutlet var dismissButton: UIButton!
    @IBOutlet var updateStatusButton: UIButton!
    @IBOutlet var deleteButton: UIButton!
    //MARK:
    func loadViewFromNib() {
        contentView = Bundle.main.loadNibNamed("BookStatusPopup", owner: self, options: nil)?[0] as! UIView
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
    
    @IBAction func deleteAction(_ sender: Any) {
        self.delegate?.bookPopupDeletePressed(popup: self)
    }
    
    @IBAction func updateStatusAction(_ sender: Any) {
       self.delegate?.bookPopupUpdateStatusPressed(popup: self)
    }
    @IBAction func dismissAction(_ sender: Any) {
        self.delegate?.bookPopupIsDismissed(popup: self)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */


}
