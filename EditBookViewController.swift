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

    @IBOutlet var bookTitle: UITextField!
    @IBOutlet var barcode: UITextField!
    @IBOutlet var author: UITextField!
    @IBOutlet var price: UITextField!
    @IBOutlet var childrenCell: UITableViewCell!
    @IBOutlet var nonFictionCell: UITableViewCell!
    @IBOutlet var fictionCell: UITableViewCell!
    @IBOutlet var textbookCell: UITableViewCell!
    
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
