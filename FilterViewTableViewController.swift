//
//  FilterViewTableViewController.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-04-02.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit

class FilterViewTableViewController: UITableViewController {
    
    let userDefaults = Foundation.UserDefaults.standard

    var priceSelected : Bool = false
    var filterPrefs : [String : AnyObject] = [:]
    @IBOutlet var textbookFilter: UIButton!
    @IBOutlet var freeFilter: UIButton!
    @IBOutlet var priceFilter: UIButton!
    @IBOutlet var recentlyAddedFilter: UIButton!
    @IBOutlet var filterTableView: UITableView!
    @IBOutlet var fictionFilter: UIButton!
    @IBOutlet var nonFictionFilter: UIButton!
    @IBOutlet var childrensFilter: UIButton!
    @IBOutlet var distanceFilter: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.distanceFilter.isContinuous = false
        filterPrefs = userDefaults.dictionary(forKey: "filter_pref") as! [String : AnyObject]
        print(filterPrefs)
        self.setButtonStates()
        filterTableView.delegate = self
        filterTableView.dataSource = self
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(self.resetFilter))
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc private func resetFilter(){
        filterPrefs = Constants.FILTER.defaultFilter
        userDefaults.set( filterPrefs, forKey: "filter_pref")   // set preferences back to default
    }
    
    private func setButtonStates(){
        for(key, value) in filterPrefs {
            if(key != Constants.FILTER.distance && (value as! Bool == true)){
                switch(key){
                case Constants.FILTER.children:
                    self.setActiveButtonState(button: self.childrensFilter)
                case Constants.FILTER.fiction:
                    self.setActiveButtonState(button: self.fictionFilter)
                case Constants.FILTER.nonFiction:
                    self.setActiveButtonState(button: self.nonFictionFilter)
                case Constants.FILTER.price:
                    self.setActiveButtonState(button: self.priceFilter)
                case Constants.FILTER.recent:
                    self.setActiveButtonState(button: self.recentlyAddedFilter)
                case Constants.FILTER.free:
                    self.setActiveButtonState(button: self.freeFilter)
                case Constants.FILTER.textbook:
                    self.setActiveButtonState(button: self.textbookFilter)
                default:
                    break
                }
            } else if (key == Constants.FILTER.distance){
                self.distanceFilter.setValue(value as! Float, animated: true)
            }
        }
    }
    
    private func setActiveButtonState(button: UIButton){
        button.setBackgroundColor(color: Constants.COLOR.appColor, forState: UIControlState.selected)
        button.titleLabel?.textColor = UIColor.white
        button.isSelected = true
    }
    
    private func setNormalButtonState(button: UIButton){
        button.setBackgroundColor(color: UIColor.white, forState: .normal)
        button.titleLabel?.textColor = Constants.COLOR.appColor
        button.isSelected = false
    }

    @IBAction func textbookButton(_ sender: UIButton) {
        if(!sender.isSelected){
            self.setActiveButtonState(button: sender)
            filterPrefs[Constants.FILTER.textbook] = true as AnyObject?
        } else {
            sender.setBackgroundColor(color: UIColor.white, forState: UIControlState.normal)
            sender.isSelected = false
            filterPrefs[Constants.FILTER.textbook] = false as AnyObject?
        }
    }
    
    @IBAction func freeButton(_ sender: UIButton) {
        if(!sender.isSelected){
            self.setActiveButtonState(button: sender)
            filterPrefs[Constants.FILTER.free] = true as AnyObject?
        } else {
            self.setNormalButtonState(button: sender)
            filterPrefs[Constants.FILTER.free] = false as AnyObject?
        }
    }
    
    @IBAction func fictionButtonAction(_ sender: UIButton) {
        if(!sender.isSelected){
            self.setActiveButtonState(button: sender)
            filterPrefs[Constants.FILTER.fiction] = true as AnyObject?
        } else {
            self.setNormalButtonState(button: sender)
            filterPrefs[Constants.FILTER.fiction] = false as AnyObject?
        }
    }
    
    @IBAction func distanceSlider(_ sender: UISlider) {
        print("Sender value: \(sender.value)")
        let distance : Float = Utilities.kilometersToMiles(km: sender.value)
        print("Calculated distance in miles: \(distance)")
        if(distance != 0){
            filterPrefs[Constants.FILTER.distance] = distance as AnyObject?
        }
    }
    
    @IBAction func nonFictionButtonAction(_ sender: UIButton) {
        if(!sender.isSelected){
            self.setActiveButtonState(button: sender)
            filterPrefs[Constants.FILTER.nonFiction] = true as AnyObject?
        } else {
            self.setNormalButtonState(button: sender)
            filterPrefs[Constants.FILTER.nonFiction] = false as AnyObject?
        }
    }
    
    @IBAction func childrensButtonAction(_ sender: UIButton) {
        if(!sender.isSelected){
            self.setActiveButtonState(button: sender)
            filterPrefs[Constants.FILTER.children] = true as AnyObject?
        } else {
            self.setNormalButtonState(button: sender)
            filterPrefs[Constants.FILTER.children] = false as AnyObject?
        }
    }
    
    @IBAction func priceButton(_ sender: UIButton) {
        if(!sender.isSelected){
            self.setActiveButtonState(button: sender)
            filterPrefs[Constants.FILTER.price] = true as AnyObject?
            filterPrefs[Constants.FILTER.recent] = false as AnyObject?
            recentlyAddedFilter.isSelected = false
            recentlyAddedFilter.setBackgroundColor(color: UIColor.white, forState: UIControlState.normal)
        } else {
            self.setNormalButtonState(button: sender)
            filterPrefs[Constants.FILTER.price] = false as AnyObject?
        }
        
    }
    
    @IBAction func recentAddedButton(_ sender: UIButton) {
        if(!sender.isSelected){
            self.setActiveButtonState(button: sender)
            filterPrefs[Constants.FILTER.recent] = true as AnyObject?
            filterPrefs[Constants.FILTER.price] = false as AnyObject?
            priceFilter.isSelected = false
            priceFilter.setBackgroundColor(color: UIColor.white, forState: UIControlState.normal)
        } else {
            self.setNormalButtonState(button: sender)
            filterPrefs[Constants.FILTER.recent] = false as AnyObject?
        }
    }

    @IBAction func saveFilter(_ sender: UIButton) {
        // Check if there are any changes from the default filter
        if(!NSDictionary(dictionary: Constants.FILTER.defaultFilter).isEqual(to: filterPrefs)){
            userDefaults.set( filterPrefs, forKey: Constants.USER_DEFAULTS.filterPrefs)   // update the user preferences
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NOTIFICATION.refreshFilter), object: nil) // notify to update filter prefs.
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
