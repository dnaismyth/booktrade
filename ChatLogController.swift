//
//  ChatLogController.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-04-21.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController : UICollectionViewController, UITextFieldDelegate {
    
    // Properties passed through from MessagesViewController
    var conversationId : Int?
    var initiatorId : Int?
    var recipientId : Int?
    
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
        collectionView?.delegate = self
        collectionView?.dataSource = self
        tabBarController?.hidesBottomBarWhenPushed = true
        fetchConversationUsers()
        setupChatInputComponents()
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
            FirebaseService().fetchConversation(convoId: String(describing: conversationId!), completed: { (messages) in
                self.conversationMessages = messages
                self.collectionView?.reloadData()
            })
        }
    }
    
    func setupChatInputComponents(){
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
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
    }
    
    @objc private func sendButtonAction(){
        let ref = FIRDatabase.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let values = ["text" : inputTextField.text!]
        childRef.updateChildValues(values)
    }
    
    // Allow enter/return button to submit
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendButtonAction()
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return conversationMessages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "messageCell", for: indexPath) as! ChatBubbleCollectionViewCell
        let message = conversationMessages[indexPath.item]
        cell.messageText.text = message.text
        return cell
    }
    
    
}
