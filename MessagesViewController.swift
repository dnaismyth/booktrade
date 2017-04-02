//
//  MessagesViewController.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-03-31.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit

class MessagesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let userDefaults = Foundation.UserDefaults.standard
    
    var conversations : [String : AnyObject] = [:]
    var convoContent : NSArray = []
    var isRecipientView : Bool = true

    @IBOutlet weak var messageTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.messageTableView.delegate = self
        self.messageTableView.dataSource = self
        self.automaticallyAdjustsScrollViewInsets = false
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return convoContent.count
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "conversationCell") as! ConversationTableViewCell
        let convo : [String : AnyObject] = convoContent[indexPath.row] as! [String : AnyObject]
        let book : [String : AnyObject]  = convo["book"] as! [String : AnyObject]
        if(isRecipientView){
            self.setRecipientData(cell: cell, convo : convo)
        } else {
            self.setInitiatorData(cell: cell, convo: convo)
        }
        
        
        cell.bookTitle.text = book["title"] as! String?
        cell.conversationId = convo["id"] as! Int?
        
        return cell
    }
    
    func setRecipientData(cell : ConversationTableViewCell, convo : [String : AnyObject]){
        let initiator : [String : AnyObject]  = convo["initiator"] as! [String : AnyObject]
        self.setAvatarImage(imageUrl: initiator["avatar"] as! String, cell: cell)
        cell.receivedFrom.text = initiator["name"] as! String?
    
    }
    
    func setInitiatorData(cell : ConversationTableViewCell, convo : [String : AnyObject]){
        let recipient : [String : AnyObject] = convo["recipient"] as! [String : AnyObject]
        self.setAvatarImage(imageUrl: recipient ["avatar"] as! String, cell: cell)
        cell.receivedFrom.text = recipient["name"] as! String?
    }
    
    func setAvatarImage(imageUrl: String, cell : ConversationTableViewCell){
        print(cell)
        if let url = NSURL(string: imageUrl) {
            if let data = NSData(contentsOf: url as URL){
                if let imageUrl = UIImage(data: data as Data) {
                    cell.avatarImage.image = imageUrl
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func messageSelection(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            self.loadRecipientConversations()
            self.isRecipientView = true
            break
        case 1:
            self.loadInitiatorConversations()
            self.isRecipientView = false
            break
        default:
            break
        }
    }
    
    func loadRecipientConversations(){
        self.conversations = [:]
        let access_token : String = userDefaults.string(forKey: "access_token")!
        ConversationService().getRecipientConversations(page: String(0), size: String(5), token: access_token, completed: { (dictionary) in
            OperationQueue.main.addOperation {
                print(dictionary)
                self.conversations = dictionary as! [String : AnyObject]
                if let content = self.conversations["content"]{
                    self.convoContent = content as! NSArray
                    self.messageTableView.reloadData()
                }
            }
        })
    }
    
    func loadInitiatorConversations(){
        self.conversations = [:]
        let access_token : String = userDefaults.string(forKey: "access_token")!
        ConversationService().getInitiatorConversations(page: String(0), size: String(5), token: access_token, completed: { (dictionary) in
            print(dictionary)
            self.conversations = dictionary as! [String : AnyObject]
            if let content = self.conversations["content"]{
                self.convoContent = content as! NSArray
                self.messageTableView.reloadData()
            }
        })
    }

}