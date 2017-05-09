//
//  EditBookViewController.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-05-07.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit

class EditBookViewController: UITableViewController {
    
    let userDefaults = Foundation.UserDefaults.standard
    
    var book: [String: AnyObject]?
    var bookId: String?
    var bookDescription: String?
    var condition: String?
    var category: [String] = []
    var freeIsSelected: Bool = false
    var indexPathOfPreviouslySelectedRow: IndexPath?

    @IBOutlet var bookTitle: UITextField!
    @IBOutlet var barcode: UITextField!
    @IBOutlet var author: UITextField!
    @IBOutlet var price: UITextField!
    @IBOutlet var childrenCell: UITableViewCell!
    @IBOutlet var nonFictionCell: UITableViewCell!
    @IBOutlet var fictionCell: UITableViewCell!
    @IBOutlet var textbookCell: UITableViewCell!
    @IBOutlet var freeBookCell: UITableViewCell!
    
    let categoriesAvail : [String] = ["CHILDREN", "FICTION", "NON_FICTION", "TEXTBOOK"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(updateBook))
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.setBookFields()
        self.updateCategoryDisplay()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = self.tableView.cellForRow(at: indexPath)
        
        switch(indexPath.section){
        case 1:
            if(isCategory(identifier: (cell?.restorationIdentifier)!)){
                self.buildCategories(cell: cell)
            }
        case 2:
            if let previousIndexPath = self.indexPathOfPreviouslySelectedRow {
                self.tableView.deselectRow(at: previousIndexPath, animated: false)
                let previousCell = tableView.cellForRow(at: previousIndexPath)
                previousCell?.accessoryType = .none
                previousCell?.tintColor = UIColor.white
                previousCell?.textLabel?.textColor = Constants.COLOR.iron
                previousCell?.backgroundColor = UIColor.white
            }
            self.indexPathOfPreviouslySelectedRow = indexPath
            if(cell?.restorationIdentifier == "freeBookCell"){
                self.freeBookCell.backgroundColor = Constants.COLOR.freeGreen
                self.freeBookCell.accessoryType = .none
                self.freeBookCell.textLabel?.textColor = UIColor.white
                self.freeIsSelected = true
            } else {
                // design price cell here if necessary
                self.freeIsSelected = false
            }
            //self.tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
        default:
            break
        }
        
        if(cell?.restorationIdentifier == "additionalInfo"){
            performSegue(withIdentifier: "editAdditionalInfoSegue", sender: self)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = self.tableView.cellForRow(at: indexPath)
        if(isCategory(identifier: (cell?.restorationIdentifier)!)){
            if let indexToRemove = category.index(of: (cell?.restorationIdentifier)!){
                category.remove(at: indexToRemove)
                cell!.backgroundColor = UIColor.white
                cell!.accessoryType = .none
                cell!.textLabel?.textColor = Constants.COLOR.iron
            }
        }
    }
    
    func buildCategories(cell: UITableViewCell?){
        if(cell != nil && cell?.restorationIdentifier != nil){
            cell!.isSelected = true
            self.setCategoryDisplay(cell: cell!)
            category.append(cell!.restorationIdentifier!)
        }
    }
    
    func isCategory(identifier : String) -> Bool {
        if(self.categoriesAvail.contains(identifier)){
            return true
        }
        
        return false
    }
    
    func setBookFields(){
        if (book != nil) {
            bookId = book!["id"] as? String
            bookTitle.text = book!["title"] as? String
            author.text = book!["author"] as? String
            price.text = book!["price"] as? String
            barcode.text = book!["barcode"] as? String
            if let categories = book!["categories"] as? [String] {
                self.category = categories
            }
            
            if let bookCondition = book!["condition"] as? String {
                self.condition = bookCondition
            }
            
            if let bookInfo = book!["description"] as? String {
                self.bookDescription = bookInfo
            }
        }
    }
    
    func updateCategoryDisplay(){
        for c in category {
            switch(c){
                case "FICTION":
                    setCategoryDisplay(cell: self.fictionCell)
                case "NON_FICTION":
                    setCategoryDisplay(cell: self.nonFictionCell)
                case "TEXTBOOK":
                    setCategoryDisplay(cell: self.textbookCell)
                case "CHILDREN":
                    setCategoryDisplay(cell: self.childrenCell)
                default:
                    break
            }
        }
    }
    
    func setCategoryDisplay(cell: UITableViewCell){
        cell.tintColor = UIColor.white
        cell.backgroundColor = Constants.COLOR.filterLightBlue
        cell.accessoryType = .checkmark
        cell.textLabel?.textColor = UIColor.white
    }
    
    func updateBook(){
        print("Updating book!")
        let bookDictionary = self.buildBookFromTextFields()
        if(!NSDictionary(dictionary: book!).isEqual(to: bookDictionary) && self.bookId != nil){
            let token: String = self.userDefaults.string(forKey: "access_token")!
            BookService().updateBook(token: token, bookId: self.bookId!, book: bookDictionary, completed: { (dictionary) in
                OperationQueue.main.addOperation {
                    print(dictionary)
                }
            })
        }
    }
    
    func buildBookFromTextFields() -> [String: AnyObject]{
        var updatedBook: [String: AnyObject] = [
            "title": bookTitle.text as AnyObject,
            "author": author.text as AnyObject,
            "barcode": barcode.text as AnyObject,
            "category": self.category as AnyObject,
            "price": price.text as AnyObject
        ]
        
        if(self.condition != nil){
            updatedBook["condition"] = self.condition! as AnyObject
        }
        
        return updatedBook
        
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
