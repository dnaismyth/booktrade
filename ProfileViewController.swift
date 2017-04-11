//
//  ProfileViewController.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-03-25.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIPopoverPresentationControllerDelegate,  UIGestureRecognizerDelegate, BookStatusPopupDelegate {
    
    let userDefaults = Foundation.UserDefaults.standard
    
    var userId : String?    // id of the user's profile in view
    var bookStatusPopup : BookStatusPopupView!
    
    /**
     Properties belonging to user's other than the current user, these will be loaded to display into the view
    **/
    var userAvatar : UIImage?
    var userName : String?
    var userBio : String?
    var userLocation : String?
    var popupShowing : Bool = false
    
    @IBOutlet weak var bookCollectionView: UICollectionView!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    
    var ownersBooks : [String : AnyObject] = [:]
    var bookContent : NSMutableArray = []
    var cellToPass : BookCollectionViewCell?
    var isCurrentUsersProfile : Bool?
    var longTapGesture : UILongPressGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
           NotificationCenter.default.addObserver(self, selector: #selector(self.profileUpdated(notification:)), name: NSNotification.Name(rawValue: Constants.NOTIFICATION.profileUpdated), object: nil)
        self.bookCollectionView.delegate = self
        self.bookCollectionView.dataSource = self
        if(isCurrentUsersProfile!){
           self.loadCurrentUsersProfile()   // load the current user's profile information
        } else if(!(isCurrentUsersProfile)!){
            print("Not the current user's profile") // otherwise, load another user's information
            self.loadSelectedUserProfile()
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadSelectedUserProfile(){
        avatarImage.image = self.userAvatar
        locationLabel.text = self.userLocation
        bioLabel.text = self.userBio
        userNameLabel.text = self.userName
        locationLabel.text = self.userLocation
    }
    
    func loadCurrentUsersProfile(){
        let avatarUrl : String = userDefaults.string(forKey: Constants.USER_DEFAULTS.userAvatar)!
        self.setAvatarImage(imageUrl: avatarUrl, imageView: self.avatarImage)
        locationLabel.text = Utilities.buildLocationLabel(location: userDefaults.dictionary(forKey: Constants.USER_DEFAULTS.locationKey) as! [String : AnyObject])
        bioLabel.text = userDefaults.string(forKey: Constants.USER_DEFAULTS.bioKey)
        userNameLabel.text = userDefaults.string(forKey: Constants.USER_DEFAULTS.nameKey)
        //TODO: Hide/show settings depending on if the current user.id = user.profile.id
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(self.viewUserSettings))
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(avatarTapped(tapGestureRecognizer:)))
        longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.longTapGestureRecognizer(tapGestureRecognizer:)))
        self.setupLongGestureRecognizer(gestureRecognizer: longTapGesture!)
        self.bookCollectionView.addGestureRecognizer(longTapGesture!)
        avatarImage.isUserInteractionEnabled = true
        avatarImage.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func avatarTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        //let avatar = tapGestureRecognizer.view as! UIImageView
        self.performSegue(withIdentifier: "changeAvatarSegue", sender: self)
        // Your action
    }
    
    func setupLongGestureRecognizer(gestureRecognizer : UILongPressGestureRecognizer){
        gestureRecognizer.minimumPressDuration = 1.0
        gestureRecognizer.delaysTouchesBegan = true
        gestureRecognizer.delegate = self
    }
    
    func viewUserSettings(){
        performSegue(withIdentifier: "settingsViewSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "changeAvatarSegue" {
            let popupMenu = segue.destination as! ChangeAvatarViewController
            popupMenu.segueFromController = "ProfileController"
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
        
        if segue.identifier == "bookInfoSegue" {
            let destination = segue.destination as! BookPopupViewController
            destination.segueFromController = "ProfileViewController"
            let bookInfoView = segue.destination as! BookPopupViewController
            if(cellToPass != nil){
                self.setPopupInfo(bookPopupInfo: bookInfoView, cell: cellToPass!)
            }
        }
    }
    
    private func setPopupInfo (bookPopupInfo : BookPopupViewController, cell : BookCollectionViewCell){
        bookPopupInfo.authorToPass = cell.author
        bookPopupInfo.titleToPass = cell.title
        bookPopupInfo.coverImageToPass = cell.coverImage.image
        bookPopupInfo.ownerIdToPass = cell.ownerId
        bookPopupInfo.currentBookId = cell.bookId
        bookPopupInfo.ownerLocation = cell.location
        bookPopupInfo.bookInformation = cell.itemDescription
        bookPopupInfo.bookCondition = cell.condition
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
        cell.bookId = book["id"] as? Int
        cell.author = book["author"] as? String
        cell.title = book["title"] as? String
        cell.status = book["status"] as? String
        cell.barcode = book["barcode"] as? String
        cell.condition = book["condition"] as? String
        cell.itemDescription = book["description"] as? String
        cell.ownerName = owner["name"] as? String
        cell.ownerAvatar = owner["avatar"] as? String
        cell.ownerId = owner["id"] as? Int
        if let location : [String : AnyObject] = owner["location"] as? [String : AnyObject]{
            cell.location = location["city"] as? String
        }
        
        if let imageUrl : String = book ["imageUrl"] as? String {
            self.setBookImage(imageUrl: imageUrl, cell: cell)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected!")
        cellToPass = collectionView.cellForItem(at: indexPath) as? BookCollectionViewCell
        performSegue(withIdentifier: "bookInfoSegue", sender: self)
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
    
    // Load all of the books that are currently available by the user
    func loadUserAvailableBooks(userId : String){
        self.bookContent = []
        let token : String = userDefaults.string(forKey: "access_token")!
        BookService().findAvailableBooksByUserId(token: token, userId: userId, page: String(0), size: String(5)) { (dictionary) in
            OperationQueue.main.addOperation{
                if let content : NSArray = dictionary.value(forKey: "content") as? NSArray{
                    self.bookContent = content.mutableCopy() as! NSMutableArray
                    self.bookCollectionView.reloadData()
                } else {
                    print("Error getting content")
                }
  
            }
        }
    }
    
    // Load all of the books that are no longer available by the user
    func loadUserUnavailableBooks(userId: String){
        self.bookContent = []
        let token : String = userDefaults.string(forKey: "access_token")!
        BookService().findUnavailableBooksByUserId(token: token, userId: userId, page: String(0), size: String(5)) { (dictionary) in
            OperationQueue.main.addOperation {
                let responseContent = dictionary.value(forKey: "content") as! NSArray
                self.bookContent = responseContent.mutableCopy() as! NSMutableArray
                self.bookCollectionView.reloadData()
            }
        }
    }
    
    @IBAction func bookStatusView(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            // Load books that are available
            self.loadUserAvailableBooks(userId: self.userId!)
            break
        case 1:
            // Load unavailable books
            self.loadUserUnavailableBooks(userId: self.userId!)
            break
        default:
            break
        }
    }
    
    @IBAction func unwindToProfile(segue: UIStoryboardSegue) {
        if let changeAvatarView = segue.source as? ChangeAvatarViewController {
            self.avatarImage.image = changeAvatarView.imageView.image
        }
    }
    
    func profileUpdated(notification : NSNotification){
        self.userNameLabel.text = userDefaults.string(forKey: Constants.USER_DEFAULTS.nameKey)
        if let bio : String = userDefaults.string(forKey: Constants.USER_DEFAULTS.bioKey){
            self.bioLabel.text = bio
        } else {
            self.bioLabel.isHidden = true
        }
        
        if let avatar : String = userDefaults.string(forKey: Constants.USER_DEFAULTS.userAvatar){
            self.setAvatarImage(imageUrl: avatar, imageView: self.avatarImage)
        }
        
        if let location : [String : AnyObject] = userDefaults.dictionary(forKey: Constants.USER_DEFAULTS.locationKey) as [String : AnyObject]?{
            let city : String = location ["city"] as! String
            self.locationLabel.text = city
        }
    }
    
    
    func setAvatarImage(imageUrl: String, imageView : UIImageView){
        if let url = NSURL(string: imageUrl) {
            if let data = NSData(contentsOf: url as URL){
                if let imageUrl = UIImage(data: data as Data) {
                    imageView.image = imageUrl
                }
            }
        }
    }
    
    // Gesture recognizer to show a popup to mark books as available/unavailable
    func longTapGestureRecognizer(tapGestureRecognizer: UITapGestureRecognizer){
        let pointInCollectionView: CGPoint = tapGestureRecognizer.location(in: self.bookCollectionView)
        if let selectedIndexPath : IndexPath = self.bookCollectionView.indexPathForItem(at: pointInCollectionView) {
            let selectedCell: BookCollectionViewCell = self.bookCollectionView.cellForItem(at: selectedIndexPath as IndexPath) as! BookCollectionViewCell
            let status : String = selectedCell.status!
            if(status == "AVAILABLE" && popupShowing == false){
                print("I am available.")
                self.showStatusPopup(status: "AVAILABLE", updatedStatus: "NOT_AVAILABLE", bookId: selectedCell.bookId!, indexPath : selectedIndexPath)
                // toggle popup mark as unavailable
            } else if (popupShowing == false){
                print("I am not available.")
                self.showStatusPopup(status: status, updatedStatus: "AVAILABLE", bookId: selectedCell.bookId!, indexPath : selectedIndexPath)
                // toggle popup mark as available
            }
        }
        
    }
    
    func showStatusPopup(status : String, updatedStatus : String, bookId : Int, indexPath : IndexPath){
        self.bookStatusPopup = BookStatusPopupView(frame: CGRect(x: 10, y: 200, width: 300, height: 200))
        self.bookStatusPopup.delegate = self
        self.bookStatusPopup.bookId = bookId
        self.bookStatusPopup.updatedStatus = updatedStatus
        self.bookStatusPopup.cellIndexPath = indexPath
        self.popupShowing = true
        self.view.addSubview(bookStatusPopup)
    }
    
    func bookPopupIsDismissed(popup: BookStatusPopupView) {
        self.popupShowing = false
        popup.removeFromSuperview()
    }
    
    func bookPopupDeletePressed(popup: BookStatusPopupView) {
        let accessToken : String = userDefaults.string(forKey: "access_token")!
        let bookId : String = String(describing: popup.bookId!)
        BookService().deleteBook(token: accessToken, bookId: bookId) { (dictionary) in
            OperationQueue.main.addOperation {
                print(dictionary)
                popup.removeFromSuperview()
                // show alert
            }
        }
    }
    
    func bookPopupUpdateStatusPressed(popup: BookStatusPopupView) {
        let accessToken : String = userDefaults.string(forKey: "access_token")!
        let data : [String : AnyObject] = ["id" : popup.bookId as AnyObject,
                                           "status" : popup.updatedStatus as AnyObject]
        BookService().updateBookStatus(token: accessToken, data: data) { (dictionary) in
            OperationQueue.main.addOperation {
                print(dictionary)
                popup.removeFromSuperview()
                self.bookContent.removeObject(at: (popup.cellIndexPath?.item)!)
                self.bookCollectionView.deleteItems(at: [popup.cellIndexPath!])
                // show alert
            }
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
