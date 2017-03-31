//
//  BookPopupViewController.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-03-30.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit

class BookPopupViewController: UIViewController, UITextViewDelegate {
    
    // MARK: - Properties
    let userDefaults = Foundation.UserDefaults.standard

    // Passed through from previous view controller
    var authorToPass : String?
    var titleToPass : String?
    var coverImageToPass : UIImage?
    var priceToPass : String?
    var ownerIdToPass : Int?
    var ownerNameToPass : String?
    var ownerAvatarToPass : String?
    var currentBookId : Int?
    let commentTextPlaceholder : String = "Interested? Send a message..."
    
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
        let currUserId : String = userDefaults.string(forKey: "user_id")!
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
                print(dictionary)
            })
        }
    }
    
    private func buildCommentData(commentText : String) -> [String : AnyObject] {
        var comment : [String : AnyObject] = [:]
        comment["text"] = commentText as AnyObject
        return comment
    }
    

    /*
    

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
