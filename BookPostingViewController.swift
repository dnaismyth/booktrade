//
//  BookPostingViewController.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-03-25.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit

class BookPostingViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var imageHolder : UIImage?
    var titleHolder : String?
    var authorHolder : String?
    var isbnHolder : String?
    
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
        print(pickerData[row])
        selectedCondition = pickerData[row]
        return pickerData[row]
    }
    
    @IBAction func getTradeOrSellSelection(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            print("Trade selected")
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
}
