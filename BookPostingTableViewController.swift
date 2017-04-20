//
//  BookPostingTableViewController.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-04-18.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit

class BookPostingTableViewController: UITableViewController {

    @IBOutlet var categoryTableView: UITableView!
    @IBOutlet var priceField: UITextField!
    
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
    let categoriesAvail : [String] = ["CHILDREN", "FICTION", "NON_FICTION", "TEXTBOOK"]
    var categories : [String] = []
    
    // Properties for the case where the image has been selected from camera or library
    var isFromCamera : Bool?
    var isFromLibrary : Bool?
    var selectedImageUrl : NSURL?
    
    var indexPathOfPreviouslySelectedRow: IndexPath?
    
    var freeIsSelected : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.categoryTableView.delegate = self
        self.categoryTableView.dataSource = self
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return categoryTableView.numberOfSections
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return categoryTableView.numberOfRows(inSection: section)
//    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = categoryTableView.cellForRow(at: indexPath)
        
        switch(indexPath.section){
        case 0:
            if(isCategory(identifier: (cell?.restorationIdentifier)!)){
                self.categories.append((cell?.restorationIdentifier)!)
                cell?.accessoryType = .checkmark
            }
        case 1:
            if let previousIndexPath = self.indexPathOfPreviouslySelectedRow {
                categoryTableView.deselectRow(at: previousIndexPath, animated: false)
                categoryTableView.cellForRow(at: previousIndexPath)?.accessoryType = UITableViewCellAccessoryType.none
            }
            self.indexPathOfPreviouslySelectedRow = indexPath
            if(cell?.restorationIdentifier == "FreeBook"){
                cell?.backgroundColor = Constants.COLOR.freeGreen
                self.freeIsSelected = true
            } else {
                self.freeIsSelected = false
            }
            categoryTableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
        default:
            break
        }
        
        if(cell?.restorationIdentifier! == "PostBook"){
            self.createNewBookPosting()
        }
    
    }
    
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = categoryTableView.cellForRow(at: indexPath)
        if(isCategory(identifier: (cell?.restorationIdentifier)!)){
            if let indexToRemove = categories.index(of: (cell?.restorationIdentifier)!){
                cell?.accessoryType = .none
                categories.remove(at: indexToRemove)
            }
        }
    }
    
    func isCategory(identifier : String) -> Bool {
        if(self.categoriesAvail.contains(identifier)){
            return true
        }
        
        return false
    }
    
    // Create a new book posting
    func createNewBookPosting() {
        if(self.isFromCamera)!{
            let tempFileName : String = "camera"
            self.s3UploadFromCamera(image: imageHolder!, fileName: tempFileName)
        } else if (self.isFromLibrary)!{
            self.s3UploadFromLibrary(image: imageHolder!, selectedImageUrl : selectedImageUrl!)
        }
        let token : String = self.userDefaults.string(forKey: "access_token")!
        BookService().createNewBookPosting(book: self.buildBookDictionary(), token: token) { (dictionary) in
            print(dictionary)
            OperationQueue.main.addOperation {
                let profileNavController : UINavigationController = self.tabBarController?.viewControllers![self.PROFILE_INDEX] as! UINavigationController
                let profileView : ProfileViewController = profileNavController.viewControllers[0] as! ProfileViewController
                profileView.isCurrentUsersProfile = true
                self.tabBarController?.selectedIndex = self.PROFILE_INDEX   // go to profile page
            }
         
            // change this to use a segue
        }
    }
    
    func s3UploadFromLibrary(image : UIImage?, selectedImageUrl : NSURL){
        if(image != nil){
            let resizedImage : UIImage = (image?.resized(withPercentage: 0.1))!
            let s3KeyPrefix : String = userDefaults.string(forKey: Constants.USER_DEFAULTS.userIdKey)!.appending("/BOOK")
            let key : String = s3KeyPrefix.appending("_").appending(UUID().uuidString)
            self.mainImageUrl = key
            self.tmbImageUrl = key
            S3Service().uploadImageFromLibrary(selectedImageUrl: selectedImageUrl, image: resizedImage, key: key) { (cover) in
                OperationQueue.main.addOperation {}
            }
        }
    }
    
    func s3UploadFromCamera(image: UIImage?, fileName : String){
        if(image != nil){
            let resizedImage : UIImage = (image?.resized(withPercentage: 0.1))!
            let s3KeyPrefix : String = userDefaults.string(forKey: Constants.USER_DEFAULTS.userIdKey)!.appending("/BOOK")
            let key : String = s3KeyPrefix.appending("_").appending(UUID().uuidString)
            self.mainImageUrl = key
            self.tmbImageUrl = key
            S3Service().uploadImageFromCamera(fileName: fileName, image: resizedImage, key: key) { (avatar) in
                OperationQueue.main.addOperation {}
            }
        }
    }
    
    private func buildBookDictionary() -> [String: AnyObject]{
        self.setBookData()
        bookDictionary["thumbnailUrl"] = self.tmbImageUrl as AnyObject?
        bookDictionary["imageUrl"] = self.mainImageUrl as AnyObject?
        if(selectedCondition != nil){
            bookDictionary["condition"] = selectedCondition! as AnyObject?
        }
        if(freeIsSelected){
            self.categories.append("FREE")
        }
        bookDictionary["category"] = self.categories as AnyObject?
        if let info : AnyObject? = additionalInfo as AnyObject?? {
          bookDictionary["description"] = info
        }
        bookDictionary["status"] = status as AnyObject?
        bookDictionary["dataSource"] = self.dataSource! as AnyObject?
        if let price = priceField?.text as String? {
            bookDictionary["price"] = (price.replacingOccurrences(of:currencyFormatter.currencySymbol, with: "")) as AnyObject?
        }
        return bookDictionary
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
    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
