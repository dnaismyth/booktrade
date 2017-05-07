//
//  BookPopupViewController.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-03-30.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class BookPopupViewController: UIViewController, UITextViewDelegate, UIPopoverPresentationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    // MARK: - Properties
    let userDefaults = Foundation.UserDefaults.standard
    let notAvailable : String = "NOT_AVAILABLE"
    var segueFromController : String?

    // Passed through from previous view controller
    var categoriesToPass: [String]?
    var barcodeToPass: String?
    var authorToPass : String?
    var titleToPass : String?
    var coverImageToPass : UIImage?
    var priceToPass : String?
    var ownerIdToPass : Int?
    var ownerNameToPass : String?
    var ownerLocation : String?
    var bookInformation : String?
    var bookCondition : String?
    var postingCreatedDate: String?
    var ownerAvatarToPass : String?
    var currentBookId : Int?
    var bookCategories: [String] = []
    var bookIsFree: Bool = false
    let commentTextPlaceholder : String = "Interested?  Send a message..."
    
    @IBOutlet weak var bookCoverImage: UIImageView!
    @IBOutlet weak var bookTitle: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var createdDateLabel: UILabel!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var sendCommentButton: UIButton!
    @IBOutlet var bookCategoryCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setBookInfoData()  // set book data
        self.bookCategoryCollectionView.delegate = self
        self.bookCategoryCollectionView.dataSource = self
        self.bookCategoryCollectionView.emptyDataSetSource = self
        self.bookCategoryCollectionView.emptyDataSetDelegate = self
        self.hideKeyboardWhenTappedAround()
        commentTextView.delegate = self
        commentTextView.text = self.commentTextPlaceholder
        commentTextView.textColor = UIColor.lightGray
        let currUserId : String = userDefaults.string(forKey: Constants.USER_DEFAULTS.userIdKey)!
        if(ownerIdToPass == Int(currUserId)){
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editBookPosting))
        }
        // Do any additional setup after loading the view.
        // Move views up when keyboard is showing.
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func editBookPosting(){
        print("Edit book posting!")
        performSegue(withIdentifier: "editBookSegue", sender: self)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= (keyboardSize.height)
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += (keyboardSize.height)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(self.bookCategories.contains("FREE")){
            return self.bookCategories.count - 1
        }
        return self.bookCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryTagCell", for: indexPath) as! TagCollectionViewCell
        let tag: String = self.bookCategories[indexPath.item]
        print(tag)
        if(tag != "FREE"){
            cell.tagLabel.text = "#".appending(tag)
            cell.tagLabel.sizeToFit()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            var width: CGFloat = CGFloat(75)
            let text = self.bookCategories[indexPath.item]
            width = estimatedFrameForText(text: text).width + 22
            print(width)
            return CGSize(width: width, height : 35)
    }
    
    private func estimatedFrameForText(text: String) -> CGRect{
        let size = CGSize(width: 1000, height: 35)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        // Change the font here to Helvetica
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: Constants.FONT.helvetica14], context: nil)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = self.commentTextPlaceholder
            textView.textColor = UIColor.lightGray
        }
    }
    
    private func showInvalidAlert(alertTitle: String, alertMessage: String){
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func verifyCommentText() -> String? {
        if(commentTextView.text.isEmpty || commentTextView.text == self.commentTextPlaceholder){
            self.showInvalidAlert(alertTitle: "Invalid Message", alertMessage: "Oops!  Looks like you've forgotten to add a message.")
        } else {
            return commentTextView.text
        }
        return nil
    }
    
    private func setBookInfoData(){
        if(authorToPass != nil){
            self.authorLabel.text = authorToPass!
        }
        
        if(titleToPass != nil){
            self.bookTitle.text = titleToPass!
        }
        
        if(coverImageToPass != nil){
            self.bookCoverImage.image = coverImageToPass!
        }
        
        
        if(categoriesToPass != nil){
            if categoriesToPass!.contains("FREE"){
                bookIsFree = true
            }
            self.bookCategories = categoriesToPass!
        }
        
        if(postingCreatedDate != nil){
            self.createdDateLabel.text = postingCreatedDate
        }
        
        if(priceToPass != nil){
            priceLabel.text = priceToPass
        } else if (bookIsFree){
            priceLabel.createFreeLabel()
        }
    }
    
    @IBAction func getMoreBookInfo(_ sender: UIButton) {
        
    }
    
    @IBAction func sendCommentAction(_ sender: UIButton) {
        let token : String = userDefaults.string(forKey: "access_token")! as String
        let commentToSend : String? = self.verifyCommentText()
        if(commentToSend != nil){
            let comment = buildCommentData(commentText: commentToSend!)
            print(comment)
            BookService().createBookComment(token: token, bookId: String(self.currentBookId!), comment: comment, completed: { (dictionary) in
                OperationQueue.main.addOperation {
                    if let id = dictionary["id"] {
                        print(id)
                        self.commentTextView.text = self.commentTextPlaceholder
                        self.commentTextView.textColor = UIColor.lightGray
                    } else {
                        // TODO: Show error alert
                    }
                }
            })
        }
    }
    
    @IBAction func unwindToBookView(segue: UIStoryboardSegue) {}
    
    private func buildCommentData(commentText : String) -> [String : AnyObject] {
        var comment : [String : AnyObject] = [:]
        comment["text"] = commentText as AnyObject
        return comment
    }
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "moreBookInfoSegue"){
            let bookInfoPopup = segue.destination as! MoreBookInfoViewController
            self.passBookInformation(vc: bookInfoPopup)
            let controller = bookInfoPopup.popoverPresentationController
            if controller != nil {
                controller?.delegate = self
                controller?.sourceView = self.view
                controller?.sourceRect = CGRect(x: self.view.layer.bounds.midX, y: self.view.layer.bounds.midY, width: 0, height: 0)
                controller?.backgroundColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:0.5)
                controller?.permittedArrowDirections = UIPopoverArrowDirection.init(rawValue: 0)
            }
        }
        
        if(segue.identifier == "editBookSegue"){
            let controller = segue.destination as! BookPostingTableViewController
            controller.segueFromController = "BookPopupViewController"
            self.setEditInformation(controller: controller)
        }
    }
    
    private func setEditInformation(controller: BookPostingTableViewController){
        controller.authorHolder = self.authorLabel.text
        controller.titleHolder = self.bookTitle.text
        controller.categoriesToPass = self.bookCategories
        controller.condition = self.bookCondition
        controller.priceToPass = self.priceLabel.text
        controller.informationToPass = self.bookInformation
        if(self.barcodeToPass != nil){
            controller.isbnHolder = self.barcodeToPass!
        }
    }
    
    private func passBookInformation(vc : MoreBookInfoViewController){
        if(ownerLocation != nil){
            vc.locationHolder = ownerLocation!
        }
        
        if(bookCondition != nil){
            vc.conditionHolder = bookCondition!
        }
        
        if(bookInformation != nil){
            vc.informationHolder = bookInformation!
        }
        
        if(barcodeToPass != nil){
            //TODO: pass through barcode to label
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle
    {
        return UIModalPresentationStyle.none
    }
    
    func updateBookStatus(){
        let access_token = userDefaults.string(forKey: "access_token")
        let data : [String : AnyObject] = [
            "id" : self.currentBookId! as AnyObject,
            "status" : self.notAvailable as AnyObject
        ]
        
        BookService().updateBookStatus(token: access_token!, data: data) { (dictionary) in
            OperationQueue.main.addOperation {
                print(dictionary)
            }
        }
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "No categories have been selected for this item."
        self.bookCategoryCollectionView.backgroundColor = UIColor.lightGray
        let attribs = [
            NSFontAttributeName: Constants.FONT.helvetica14,
            NSForegroundColorAttributeName: UIColor.white
        ]
        
        return NSAttributedString(string: text, attributes: attribs)
    }
    
//    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
//        let text = "Must be a rare one."
//        
//        let para = NSMutableParagraphStyle()
//        para.lineBreakMode = NSLineBreakMode.byWordWrapping
//        para.alignment = NSTextAlignment.center
//        
//        let attribs = [
//            NSFontAttributeName: Constants.FONT.helvetica14,
//            NSForegroundColorAttributeName: UIColor.lightGray,
//            NSParagraphStyleAttributeName: para
//        ]
//        
//        return NSAttributedString(string: text, attributes: attribs)
//    }
 

}
