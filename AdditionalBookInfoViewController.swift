//
//  AdditionalBookInfoViewController.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-04-15.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit

class AdditionalBookInfoViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet var informationTextView: UITextView!
    @IBOutlet var conditionTextField: UITextField!
    
    // Picker properties
    var pickerData: [String] = [String]()
    var conditionPicker = UIPickerView()
    var selectedCondition : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.conditionPicker.delegate = self
        self.conditionPicker.dataSource = self
        self.conditionTextField.inputView = self.conditionPicker
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(self.resetFields))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Ready", style: .plain, target: self, action: #selector(self.backToBookPosting))

        pickerData = ["New", "Very Good", "Good", "Fair", "Poor"]

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc private func resetFields(){
        conditionTextField.text = "Condition"
        self.selectedCondition = nil
        informationTextView.text = "Additional Information"
    }
    
    @objc private func backToBookPosting(){
        self.performSegue(withIdentifier: "backToBookPostingSegue", sender: self)
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
        case "New" :
            return "NEW"
        case "Very Good":
            return "VERY_GOOD"
        case "Good":
            return "GOOD"
        case "Fair" :
            return "FAIR"
        case "Poor" :
            return "POOR"
        default:
            return "N/A"
        }
    }
    

    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "backToBookPostingSegue"){
            let postController = segue.destination as! BookPostingViewController
            postController.additionalInfo = self.informationTextView.text
            if(selectedCondition != nil){
                postController.selectedCondition = self.getSelectedCondition(condition: self.selectedCondition!)
            }
        }
    }

}
