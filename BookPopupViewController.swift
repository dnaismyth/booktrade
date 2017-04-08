//
//  BookPopupViewController.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-03-30.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit

class BookPopupViewController: UIViewController, UITextViewDelegate, UIPopoverPresentationControllerDelegate {
    
    // MARK: - Properties
    let userDefaults = Foundation.UserDefaults.standard
    
    var segueFromController : String?

    // Passed through from previous view controller
    var authorToPass : String?
    var titleToPass : String?
    var coverImageToPass : UIImage?
    var priceToPass : String?
    var ownerIdToPass : Int?
    var ownerNameToPass : String?
    var ownerLocation : String?
    var bookInformation : String?
    var bookCondition : String?
    var ownerAvatarToPass : String?
    var currentBookId : Int?
    let commentTextPlaceholder : String = "Interested?  Send a message..."
    
    @IBOutlet weak var bookCoverImage: UIImageView!
    @IBOutlet weak var bookTitle: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var createdDateLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var sendCommentButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        commentTextView.delegate = self
        commentTextView.text = self.commentTextPlaceholder
        commentTextView.textColor = UIColor.lightGray
        let currUserId : String = userDefaults.string(forKey: Constants.USER_DEFAULTS.userIdKey)!
        if(ownerIdToPass != Int(currUserId)){
            editButton.isHidden = true      // hide the edit button if book does not belong to current user
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.setBookInfoData()  // set book data
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    }
    // MARK: - Navigation
    
    @IBAction func exitBookPopup(_ sender: UIButton) {
        if segueFromController! == "SearchViewController"{
            
            self.performSegue(withIdentifier: "unwindToSearch", sender: nil)
            
        }
        else if segueFromController! == "ProfileViewController"{
            self.performSegue(withIdentifier: "unwindToProfile", sender: nil)
            
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
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle
    {
        return UIModalPresentationStyle.none
    }
 

}
