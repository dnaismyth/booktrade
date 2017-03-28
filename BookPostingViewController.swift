//
//  BookPostingViewController.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-03-25.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit

class BookPostingViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let userDefaults = Foundation.UserDefaults.standard

    
    var imageHolder : UIImage?
    var tmbImageUrl : String?   // thumbnail image url
    var mainImageUrl : String?  // main image url (larger)
    var titleHolder : String?
    var authorHolder : String?
    var isbnHolder : String?
    var bookDictionary : [String : AnyObject] = [:]
    var condition : String?
    var status : String = "TRADE"
    
    @IBOutlet weak var conditionTextField: UITextField!
    @IBOutlet weak var priceField: UITextField!
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var bookTitle: UITextField!
    @IBOutlet weak var authorLabel: UITextField!
    @IBOutlet weak var ISBNLabel: UILabel!
    @IBOutlet weak var descriptionTextField: UITextField!
    
    var pickerData: [String] = [String]()
    var conditionPicker = UIPickerView()
    var selectedCondition : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.setBookData()  // load book data from previous view
        self.conditionPicker.delegate = self
        self.conditionPicker.dataSource = self
        self.conditionTextField.inputView = self.conditionPicker
        pickerData = ["Good", "Very Good"]
        self.priceField.isHidden = true;
        self.hideKeyboardWhenTappedAround()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setBookData(){
        if(authorHolder != nil){
            authorLabel.text = authorHolder!
        }
        
        if(titleHolder != nil){
            bookTitle.text = titleHolder!
        }
        
        if(isbnHolder != nil){
            ISBNLabel.text = isbnHolder!
        }
        
        if(imageHolder != nil){
            coverImage.image = imageHolder!
        }
    }
    
    // The number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count;
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        selectedCondition = self.getSelectedCondition(condition: pickerData[row])
        return pickerData[row]
    }
    
    private func getSelectedCondition(condition : String) -> String{
        switch(condition){
            case "Very Good":
                return "VERY_GOOD"
            case "Good":
                return "GOOD"
            default:
                return "N/A"
        }
    }
    
    @IBAction func getTradeOrSellSelection(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            print("Trade selected")
            self.status = "TRADE"
            self.priceField.isHidden = true
            break
        case 1:
            print("Sell selected")
            self.status = "SELL"
            self.priceField.isHidden = false
            break
        default:
            break
        }
    }
    
    // Create a new book posting
    @IBAction func createNewBookPosting(_ sender: UIButton) {
        let token : String = self.userDefaults.string(forKey: "access_token")!
        let dictionary = BookService().createNewBookPosting(book: self.buildBookDictionary(), token: token)
        if(dictionary["id"] != nil){
            print(dictionary)
        }
    }
    
    private func buildBookDictionary() -> [String: AnyObject]{
        bookDictionary["title"] = bookTitle.text as AnyObject?
        bookDictionary["author"] = authorLabel.text as AnyObject?
        bookDictionary["thumbnailUrl"] = self.tmbImageUrl as AnyObject?
        bookDictionary["imageUrl"] = self.mainImageUrl as AnyObject?
        if(selectedCondition != nil){
            bookDictionary["condition"] = selectedCondition! as AnyObject?
        }
        bookDictionary["description"] = descriptionTextField.text as AnyObject?
        bookDictionary["status"] = status as AnyObject?
        return bookDictionary
    }
}
