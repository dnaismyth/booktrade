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
    var filterButtons: [CustomFilterUIButton] = []
    @IBOutlet var filterTableView: UITableView!
    @IBOutlet var distanceFilter: UISlider!
    
    @IBOutlet var fictionFilter: CustomFilterUIButton!
    @IBOutlet var freeFilter: CustomFilterUIButton!
    @IBOutlet var childrensFilter: CustomFilterUIButton!
    @IBOutlet var textbookFilter: CustomFilterUIButton!
    @IBOutlet var nonFictionFilter: CustomFilterUIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addButtonsToList() // add all the filters to list
        self.distanceFilter.isContinuous = false
        filterPrefs = userDefaults.dictionary(forKey: "filter_pref") as! [String : AnyObject]
        print(filterPrefs)
        self.setButtonStates()
        filterTableView.delegate = self
        filterTableView.dataSource = self
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(self.resetFilter))
        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addButtonsToList(){
        filterButtons.append(fictionFilter)
        filterButtons.append(freeFilter)
        filterButtons.append(childrensFilter)
        filterButtons.append(textbookFilter)
        filterButtons.append(nonFictionFilter)
    }
    
    // Reset Filters back to their normal state.  This will remove the previous filter preferences and replace them
    // With the default filter set in Constants.
    @objc private func resetFilter(){
        filterPrefs = Constants.FILTER.defaultFilter
        userDefaults.set( filterPrefs, forKey: "filter_pref")   // set preferences back to default
        for button in filterButtons {
            if button.isSelected {
                button.isSelected = false
                button.setBackgroundColor(color: Constants.COLOR.filterLightBlue, forState: .normal)
            }
        }
        if let selectedRows = (self.filterTableView.indexPathsForSelectedRows){
            for selectedIndex in selectedRows {
                print(selectedIndex)
                let cell = filterTableView.cellForRow(at: selectedIndex)
                cell?.textLabel?.textColor = UIColor.black
                cell?.detailTextLabel?.textColor = UIColor.darkGray
                cell?.backgroundColor = UIColor.white
                filterTableView.deselectRow(at: selectedIndex, animated: true)
            }
        }
        
        distanceFilter.value = 0.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.textLabel?.textColor = UIColor.white
            cell.detailTextLabel?.textColor = UIColor.white
            cell.backgroundColor = Constants.COLOR.appColor
            if(cell.reuseIdentifier != nil){
                switch(cell.reuseIdentifier!){
                case "sortPrice" :
                    self.handlePriceCellOnSelect(cell: cell)
                case "sortRecentlyAdded" :
                    self.handleRecentlyAddedCellOnSelect(cell: cell)
                default:
                    break
                }
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        let cell = tableView.cellForRow(at: indexPath)
        if(cell?.restorationIdentifier != nil && (cell?.restorationIdentifier == "sortPrice" || cell?.restorationIdentifier == "sortRecentlyAdded")){
            return true
        } else {
            return false
        }
    }
    
    override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if(cell?.restorationIdentifier != nil && (cell?.restorationIdentifier == "sortPrice" || cell?.restorationIdentifier == "sortRecentlyAdded")){
            cell?.textLabel?.textColor = UIColor.white
            cell?.detailTextLabel?.textColor = UIColor.white
            cell?.backgroundColor = Constants.COLOR.appColor
        } else {
            cell?.backgroundColor = UIColor.white
        }
    }
    
    override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if(cell?.restorationIdentifier != nil && (cell?.restorationIdentifier == "sortPrice" || cell?.restorationIdentifier == "sortRecentlyAdded")){
            cell?.textLabel?.textColor = UIColor.black
            cell?.detailTextLabel?.textColor = UIColor.darkGray
            cell?.backgroundColor = UIColor.white
        } else {
            cell?.backgroundColor = UIColor.white
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if(cell?.restorationIdentifier != nil && (cell?.restorationIdentifier == "sortPrice" || cell?.restorationIdentifier == "sortRecentlyAdded")){
            cell?.textLabel?.textColor = UIColor.black
            cell?.detailTextLabel?.textColor = UIColor.darkGray
            cell?.backgroundColor = UIColor.white
        } else {
            cell?.backgroundColor = UIColor.white
        }
    }
    
    private func handlePriceCellOnSelect(cell: UITableViewCell){
        filterPrefs[Constants.FILTER.price] = true as AnyObject?
        filterPrefs[Constants.FILTER.recent] = false as AnyObject?
    }
    
    private func handleRecentlyAddedCellOnSelect(cell: UITableViewCell){
        filterPrefs[Constants.FILTER.recent] = true as AnyObject?
        filterPrefs[Constants.FILTER.price] = false as AnyObject?
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
                    let cell = tableView.dequeueReusableCell(withIdentifier: "sortPrice")
                    cell?.isSelected = true
                case Constants.FILTER.recent:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "sortRecentlyAdded")
                    cell?.isSelected = true
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
    
    private func setActiveButtonState(button: CustomFilterUIButton){
        button.setBackgroundColor(color: Constants.COLOR.appColor, forState: UIControlState.selected)
        button.titleLabel?.textColor = UIColor.white
        button.isSelected = true
    }
    
    private func setNormalButtonState(button: CustomFilterUIButton){
        button.setBackgroundColor(color: Constants.COLOR.filterLightBlue, forState: .normal)
        button.titleLabel?.textColor = UIColor.white
        button.isSelected = false
    }

    @IBAction func textbookButton(_ sender: CustomFilterUIButton) {
        if(!sender.isSelected){
            self.setActiveButtonState(button: sender)
            filterPrefs[Constants.FILTER.textbook] = true as AnyObject?
        } else {
            self.setNormalButtonState(button: sender)
            filterPrefs[Constants.FILTER.textbook] = false as AnyObject?
        }
    }
    
    @IBAction func freeButton(_ sender: CustomFilterUIButton) {
        if(!sender.isSelected){
            self.setActiveButtonState(button: sender)
            filterPrefs[Constants.FILTER.free] = true as AnyObject?
        } else {
            self.setNormalButtonState(button: sender)
            filterPrefs[Constants.FILTER.free] = false as AnyObject?
        }
    }
    
    @IBAction func fictionButtonAction(_ sender: CustomFilterUIButton) {
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
    
    @IBAction func nonFictionButtonAction(_ sender: CustomFilterUIButton) {
        if(!sender.isSelected){
            self.setActiveButtonState(button: sender)
            filterPrefs[Constants.FILTER.nonFiction] = true as AnyObject?
        } else {
            self.setNormalButtonState(button: sender)
            filterPrefs[Constants.FILTER.nonFiction] = false as AnyObject?
        }
    }
    
    @IBAction func childrensButtonAction(_ sender: CustomFilterUIButton) {
        if(!sender.isSelected){
            self.setActiveButtonState(button: sender)
            filterPrefs[Constants.FILTER.children] = true as AnyObject?
        } else {
            self.setNormalButtonState(button: sender)
            filterPrefs[Constants.FILTER.children] = false as AnyObject?
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
