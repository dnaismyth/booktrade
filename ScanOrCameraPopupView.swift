//
//  ScanOrCameraPopupView.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-04-13.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit

protocol ScanOrCameraPopupViewDelegate{
    func useCameraIsSelected(popup : ScanOrCameraPopupView)
    func scanBarcodeIsSelected(popup : ScanOrCameraPopupView)
    func useCameraLibraryIsSelected(popup : ScanOrCameraPopupView)
}
class ScanOrCameraPopupView: UIView {
    
    var contentView:UIView!
    var delegate : ScanOrCameraPopupViewDelegate!
    
    @IBOutlet var scanBarcodeButton: UIButton!
    @IBOutlet var useCameraButton: UIButton!
    @IBOutlet var useLibraryButton: UIButton!
    
    //MARK:
    func loadViewFromNib() {
        contentView = Bundle.main.loadNibNamed("ScanOrCameraPopup", owner: self, options: nil)?[0] as! UIView
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
    
    @IBAction func scanBarcodeAction(_ sender: Any) {
        self.delegate?.scanBarcodeIsSelected(popup: self)
    }
    
    @IBAction func useCameraAction(_ sender: Any) {
        self.delegate?.useCameraIsSelected(popup: self)
    }
    
    @IBAction func useLibraryAction(_ sender: Any) {
        self.delegate?.useCameraLibraryIsSelected(popup: self)
    }
    

}
