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

    @IBOutlet weak var messageTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.messageTableView.delegate = self
        self.messageTableView.dataSource = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadMessages(){
    
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return convoContent.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //conversationCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "conversationCell") as! ConversationTableViewCell
        return cell
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
            break
        case 1:
            self.loadInitiatorConversations()
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
            }
        })
    }
    
    func loadInitiatorConversations(){
        self.conversations = [:]
        let access_token : String = userDefaults.string(forKey: "access_token")!
        ConversationService().getInitiatorConversations(page: String(0), size: String(5), token: access_token, completed: { (dictionary) in
            print(dictionary)
            self.conversations = dictionary as! [String : AnyObject]
        })
    }

}
