//
//  ChatLogController.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-04-21.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController : UICollectionViewController, UICollectionViewDelegateFlowLayout, UITextFieldDelegate {
    
    // User Defaults
    let userDefaults = Foundation.UserDefaults.standard
    
    // Properties passed through from MessagesViewController
    var conversationId : Int?
    var conversationBookId : Int?
    var initiatorId : Int?
    var recipientId : Int?
    var currentUserIsRecipient : Bool?
    var currentUserId : Int?
    var recipientName : String?
    
    var conversationMessages : [FirebaseMessage] = []
    
    var recipient : FirebaseUser?
    var initiator : FirebaseUser?
    // lazy var gives access to 'self'
    lazy var inputTextField : UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Enter message..."
        textField.delegate = self
        return textField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigationTitleView()
        self.currentUserId = userDefaults.integer(forKey: Constants.USER_DEFAULTS.userIdKey)
        collectionView?.delegate = self
        collectionView?.dataSource = self
        
        tabBarController?.hidesBottomBarWhenPushed = true
        fetchConversationUsers()
        setupChatInputComponents()
    }
    
    func scrollToBottom(){
        let item = self.collectionView(self.collectionView!, numberOfItemsInSection: 0) - 1
        let lastItemIndex = NSIndexPath(item: item, section: 0)
        self.collectionView?.scrollToItem(at: lastItemIndex as IndexPath, at: UICollectionViewScrollPosition.bottom, animated: false)
    }
    
    func setupNavigationTitleView(){
        if let headerTitle = self.recipientName {
            navigationItem.title = headerTitle
        }
    }
    
    // Fetch users belonging to the current conversation from Firebase
    func fetchConversationUsers(){
        
        if(initiatorId != nil){
            FirebaseService().fetchFirebaseUser(userId: String(describing: initiatorId!), completed: { (user) in
                print(user)
                self.initiator = user
            })
        }
        
        if(recipientId != nil){
            FirebaseService().fetchFirebaseUser(userId: String(describing: recipientId!), completed: { (user) in
                print(user)
                self.recipient = user
            })
        }
        
        if(conversationId != nil){
            FirebaseService().fetchConversation(convoId: String(describing: conversationId!), completed: { (message) in
                self.conversationMessages.append(message)
                self.collectionView?.reloadData()
                self.scrollToBottom()
            })
        }
    }
    
    func setupChatInputComponents(){
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor.white
        view.addSubview(containerView)
        
        // Container Constraint anchors
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(sendButtonAction), for: .touchUpInside)
        containerView.addSubview(sendButton)
        
        // Button Constraint anchors
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true

        containerView.addSubview(inputTextField)
        
        // Textfield Constraints
        inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        inputTextField.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        let separatorLineView = UIView()
        separatorLineView.backgroundColor = UIColor.lightGray
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorLineView)
        
        // Separator constraints
        separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        view.bringSubview(toFront: containerView)
    }
    
    @objc private func sendButtonAction(){
        let accessToken = userDefaults.string(forKey: "access_token")
        
        guard let message = inputTextField.text else {
            print("Message is empty!")
            return
        }
        
        let comment : [String : AnyObject] = ["text" : message as AnyObject]
        if self.conversationBookId != nil {
            ConversationService().postCommentToConversation(token: accessToken!, convoId: String(describing: self.conversationId!), comment: comment, completed: { (dictionary) in
                OperationQueue.main.addOperation {
                    print("Message sent!")
                    self.inputTextField.text = ""
                }
            })
        }
    }
    
    
    // Allow enter/return button to submit
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendButtonAction()
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = CGFloat(80)
        if let text = conversationMessages[indexPath.item].text {
            height = estimatedFrameForText(text: text).height + 15
        }
        return CGSize(width: view.frame.width, height : height)
    }
    
    private func estimatedFrameForText(text: String) -> CGRect{
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        // Change the font here to Helvetica
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return conversationMessages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let message = conversationMessages[indexPath.item]
        if(message.comment_from_id!.intValue == currentUserId){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "messageCell", for: indexPath) as! ChatBubbleCollectionViewCell
            self.setCellDesign(message: message, cell: cell)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "messageResponseCell", for: indexPath) as! ResponseBubbleCollectionViewCell
            self.setCellResponseDesign(message: message, cell: cell)
            return cell
        }
    }
    
    func setCellDesign(message : FirebaseMessage, cell : ChatBubbleCollectionViewCell){
        cell.messageText.text = message.text
        cell.messageText.isScrollEnabled = false
    }
    
    func setCellResponseDesign(message : FirebaseMessage, cell : ResponseBubbleCollectionViewCell){
        cell.messageText.text = message.text
        cell.messageText.isScrollEnabled = false
        if(recipient != nil && recipient!.id == String(describing: message.comment_from_id)){
            Utilities.setImage(imageUrl: recipient!.avatar!, imageView: cell.avatarImageView)
        } else if (initiator != nil && initiator!.avatar != nil){
            Utilities.setImage(imageUrl: initiator!.avatar!, imageView: cell.avatarImageView)
        }
        
    }
    
}
