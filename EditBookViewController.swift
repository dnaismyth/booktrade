//
//  EditBookViewController.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-05-07.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit

class EditBookViewController: UITableViewController {
    
    var book: [String: AnyObject]?

    @IBOutlet var bookTitle: UITextField!
    @IBOutlet var barcode: UITextField!
    @IBOutlet var author: UITextField!
    @IBOutlet var price: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(updateBook))
        self.setBookFields()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setBookFields(){
        if (book != nil) {
            bookTitle.text = book!["title"] as? String
            author.text = book!["author"] as? String
            price.text = book!["price"] as? String
            barcode.text = book!["barcode"] as? String
        }
    }
    
    func updateBook(){
        print("Updating book!")
        // TODO: Update Book api call
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
