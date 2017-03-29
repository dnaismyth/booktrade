//
//  ProfileViewController.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-03-25.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIPopoverPresentationControllerDelegate {
    
    let userDefaults = Foundation.UserDefaults.standard
    
    var userId : String?
    
    @IBOutlet weak var bookCollectionView: UICollectionView!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    
    var ownersBooks : [String : AnyObject] = [:]
    var bookContent : NSArray = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.bookCollectionView.delegate = self
        self.bookCollectionView.dataSource = self
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(avatarTapped(tapGestureRecognizer:)))
        avatarImage.isUserInteractionEnabled = true
        avatarImage.addGestureRecognizer(tapGestureRecognizer)
        //self.loadUserBooks(userId: userId!) // change this to dynamically set user id
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func avatarTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let avatar = tapGestureRecognizer.view as! UIImageView
        self.performSegue(withIdentifier: "changeAvatarSegue", sender: self)
        // Your action
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeAvatarSegue" {
            let popupMenu = segue.destination
            popupMenu.modalPresentationStyle = UIModalPresentationStyle.popover
            let controller = popupMenu.popoverPresentationController
            if controller != nil {
                controller?.delegate = self
                controller?.sourceView = self.view
                controller?.sourceRect = CGRect(x: self.view.layer.bounds.midX, y: self.view.layer.bounds.maxY, width: 0, height: 0)
                controller?.backgroundColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:0.5)
                //controller?.permittedArrowDirections = UIPopoverArrowDirection.init(rawValue: 0)
           }
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle
    {
        return UIModalPresentationStyle.none
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.bookContent.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = bookCollectionView.dequeueReusableCell(withReuseIdentifier: "bookCell", for: indexPath) as! BookCollectionViewCell
        let book = self.bookContent[indexPath.item] as! [String : AnyObject]
        let owner = book["owner"] as! [String : AnyObject]
        cell.author = book["author"] as? String
        cell.title = book["title"] as? String
        cell.status = book["status"] as? String
        cell.barcode = book["barcode"] as? String
        cell.condition = book["condition"] as? String
        cell.itemDescription = book["description"] as? String
        cell.ownerName = owner["name"] as? String
        cell.ownerAvatar = owner["avatar"] as? String
        if let location : [String : AnyObject] = owner["location"] as? [String : AnyObject]{
            cell.location = location["city"] as? String
        }
        
        if let imageUrl : String = book ["imageUrl"] as? String {
            print("image url is: \(imageUrl)")
            self.setBookImage(imageUrl: imageUrl, cell: cell)
        }
        
        return cell
    }
    
    func setBookImage(imageUrl: String, cell : BookCollectionViewCell){
        print(cell)
        if let url = NSURL(string: imageUrl) {
            if let data = NSData(contentsOf: url as URL){
                if let imageUrl = UIImage(data: data as Data) {
                    cell.coverImage.image = imageUrl
                }
            }
        }
    }
    
    func loadUserBooks(userId : String){
        let token : String = userDefaults.string(forKey: "access_token")!
        BookService().findBooksByUserId(token: token, userId: userId, page: String(0), size: String(5)) { (dictionary) in
            OperationQueue.main.addOperation{
                self.bookCollectionView.reloadData()
                self.bookContent = dictionary.value(forKey: "content") as! NSArray
                print("Book content count is...\(self.bookContent.count)")
                print(self.bookContent)
            }
        }
    }
    
    @IBAction func bookStatusView(_ sender: UISegmentedControl) {
        
    }
    
    @IBAction func unwindToProfile(segue: UIStoryboardSegue) {
        if let changeAvatarView = segue.source as? ChangeAvatarViewController {
            self.avatarImage.image = changeAvatarView.imageView.image
        }
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
