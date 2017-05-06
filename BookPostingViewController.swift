//
//  BookPostingViewController.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-03-25.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit

class BookPostingViewController: UIViewController, UITextFieldDelegate {
    
    let userDefaults = Foundation.UserDefaults.standard
    let PROFILE_INDEX : Int = 3
    
    var imageHolder : UIImage?
    var tmbImageUrl : String?   // thumbnail image url
    var mainImageUrl : String?  // main image url (larger)
    var titleHolder : String?
    var authorHolder : String?
    var isbnHolder : String?
    var selectedCondition : String? // passed through from additional information view
    var additionalInfo : String?? // passed through from additional information view
    var bookDictionary : [String : AnyObject] = [:]
    var condition : String?
    var status : String = "AVAILABLE"
    var dataSource : String?
    let currencyFormatter = NumberFormatter()
    let categories : [String] = []
    
    @IBOutlet weak var priceField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        priceField.addTarget(self, action: #selector(textFieldDidChange(priceField:)), for: UIControlEvents.editingChanged)
        currencyFormatter.numberStyle = NumberFormatter.Style.currency
        currencyFormatter.internationalCurrencySymbol = NSLocale.current.localizedString(forCurrencyCode: Locale.current.currencyCode!)
        self.priceField.isHidden = true;
        self.hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setBookData(){
        if(authorHolder != nil){
            bookDictionary["author"] = authorHolder! as AnyObject
        }
        
        if(titleHolder != nil){
            bookDictionary["title"] = titleHolder! as AnyObject
        }
        
        if(isbnHolder != nil){
            bookDictionary["barcode"] = isbnHolder! as AnyObject
        }
        
//        if(imageHolder != nil){
//            coverImage.image = imageHolder!
//        }
    }
    
    
    func textFieldDidChange(priceField: UITextField) {
        let text = self.priceField.text!.replacingOccurrences(of:currencyFormatter.currencySymbol, with: "").replacingOccurrences(of: currencyFormatter.groupingSeparator, with: "").replacingOccurrences(of: currencyFormatter.decimalSeparator, with: "")
        print(text)
        let myDouble : Double? = Double(text)
        if(myDouble != nil){
            let myNumber = NSNumber(value: (myDouble!/100.0))
            self.priceField.text = currencyFormatter.string(from: myNumber)
        }
        
    }
    
    @IBAction func getTradeOrSellSelection(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            print("Free selected")
            self.priceField.isHidden = true
            break
        case 1:
            print("Sell selected")
            self.priceField.isHidden = false
            break
        default:
            break
        }
    }
    
    // Create a new book posting
    @IBAction func createNewBookPosting(_ sender: UIButton) {
        let token : String = self.userDefaults.string(forKey: "access_token")!
        BookService().createNewBookPosting(book: self.buildBookDictionary(), token: token) { (dictionary) in
            print(dictionary)
            self.tabBarController?.selectedIndex = self.PROFILE_INDEX   // go to profile page
        }
    }
    
    private func buildBookDictionary() -> [String: AnyObject]{
        self.setBookData()
        bookDictionary["thumbnailUrl"] = self.tmbImageUrl as AnyObject?
        bookDictionary["imageUrl"] = self.mainImageUrl as AnyObject?
        if(selectedCondition != nil){
            bookDictionary["condition"] = selectedCondition! as AnyObject?
        }
        bookDictionary["description"] = additionalInfo! as AnyObject?
        bookDictionary["status"] = status as AnyObject?
        bookDictionary["dataSource"] = self.dataSource! as AnyObject?
        if let price = priceField.text as String? {
            bookDictionary["price"] = (price.replacingOccurrences(of:currencyFormatter.currencySymbol, with: "")) as AnyObject?
        }
        return bookDictionary
    }
}
