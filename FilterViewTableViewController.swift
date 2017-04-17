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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        filterPrefs = userDefaults.dictionary(forKey: "filter_pref") as! [String : AnyObject]
        print(filterPrefs)
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

    @IBAction func textbookButton(_ sender: UIButton) {
        if(!sender.isSelected){
            sender.setBackgroundColor(color: UIColor.gray, forState: UIControlState.selected)
            sender.isSelected = true
            filterPrefs[Constants.FILTER.textbook] = true as AnyObject?
        } else {
            sender.setBackgroundColor(color: UIColor.white, forState: UIControlState.normal)
            sender.isSelected = false
            filterPrefs[Constants.FILTER.textbook] = false as AnyObject?
        }
    }
    
    @IBAction func freeButton(_ sender: UIButton) {
        if(!sender.isSelected){
            sender.setBackgroundColor(color: UIColor.gray, forState: UIControlState.selected)
            sender.isSelected = true
            filterPrefs[Constants.FILTER.free] = true as AnyObject?
        } else {
            sender.setBackgroundColor(color: UIColor.white, forState: UIControlState.normal)
            sender.isSelected = false
            filterPrefs[Constants.FILTER.free] = false as AnyObject?
        }
    }
    
    @IBAction func distanceSlider(_ sender: UISlider) {
    }
    
    @IBAction func priceButton(_ sender: UIButton) {
        if(!sender.isSelected){
            sender.setBackgroundColor(color: UIColor.gray, forState: UIControlState.selected)
            sender.isSelected = true
            filterPrefs[Constants.FILTER.price] = true as AnyObject?
            filterPrefs[Constants.FILTER.recent] = false as AnyObject?
            recentlyAddedFilter.isSelected = false
            recentlyAddedFilter.setBackgroundColor(color: UIColor.white, forState: UIControlState.normal)
        } else {
            sender.setBackgroundColor(color: UIColor.white, forState: UIControlState.normal)
            sender.isSelected = false
            filterPrefs[Constants.FILTER.price] = false as AnyObject?
        }
        
    }
    
    @IBAction func recentAddedButton(_ sender: UIButton) {
        if(!sender.isSelected){
            sender.setBackgroundColor(color: UIColor.gray, forState: UIControlState.selected)
            sender.isSelected = true
            filterPrefs[Constants.FILTER.recent] = true as AnyObject?
            filterPrefs[Constants.FILTER.price] = false as AnyObject?
            priceFilter.isSelected = false
            priceFilter.setBackgroundColor(color: UIColor.white, forState: UIControlState.normal)
        } else {
            sender.setBackgroundColor(color: UIColor.white, forState: UIControlState.normal)
            sender.isSelected = false
            filterPrefs[Constants.FILTER.recent] = false as AnyObject?
        }
    }

    @IBAction func saveFilter(_ sender: UIButton) {
        // Check if there are any changes from the default filter
        if(!NSDictionary(dictionary: Constants.FILTER.defaultFilter).isEqual(to: filterPrefs)){
            userDefaults.set( filterPrefs, forKey: "filter_pref")   // update the user preferences
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
