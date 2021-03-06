//
//  ProfileViewController.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-03-25.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class ProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIPopoverPresentationControllerDelegate,  UIGestureRecognizerDelegate, BookStatusPopupDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    let userDefaults = Foundation.UserDefaults.standard
    
    /**********************************************/
    // ***Variables for empty collection views*** //
    /**********************************************/
    // Current user titles
    var currentUserSoldTitle: String = "You have not yet sold any books."
    var currentUserSoldSubTitle: String = "Press and hold down on one of your available books to update it's status."
    var currentUserAvailableTitle: String = "You currently have no books available."
    var currentUserAvailableSubTitle: String = "We got you.  Tap below to add a new one."
    
    // Alternate user titles
    var userSoldTitle: String = "This user has not yet sold any books."
    var userSoldSubTitle: String = "That's okay.  We know they are hard to give away."
    var userAvailableTitle: String = "This user does not have any books for sale."
    var userAvailableSubTitle: String = "Hoarder."
    
    // Titles that will be used to display in the empty data set view
    var emptySubTitle: String?
    var emptyTitle: String?
    var showAddNewBookButton: Bool = false
    
    
    var userId : String?    // id of the user's profile in view
    var bookStatusPopup : BookStatusPopupView!
    
    // Pagination variables
    var pageNum : Int = 0
    var numCells : Int = 0
    var numBooksInResults : Int?
    var reachedEndOfBookResults : Bool = false
    
    /**
     Properties belonging to user's other than the current user, these will be loaded to display into the view
    **/
    var userAvatar : UIImage?
    var userName : String?
    var userBio : String?
    var userLocation : String?
    var popupShowing : Bool = false
    
    @IBOutlet var bookStatusSegmentControl: UISegmentedControl!
    @IBOutlet weak var bookCollectionView: UICollectionView!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    
    var ownersBooks : [String : AnyObject] = [:]
    var bookContent : [[String : AnyObject]] = [[:]]
    var cellToPass : BookCollectionViewCell?
    var isCurrentUsersProfile : Bool?
    var longTapGesture : UILongPressGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bookCollectionView.emptyDataSetSource = self
        self.bookCollectionView.emptyDataSetDelegate = self
        self.setupSegmentedControl(index: 0)
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
    
    func setupSegmentedControl(index: Int){
        self.bookStatusSegmentControl.addUnderlineForSelectedSegment()
        self.bookStatusSegmentControl.selectedSegmentIndex = index
    }
    
    func loadSelectedUserProfile(){
        avatarImage.image = self.userAvatar
        locationLabel.text = self.userLocation
        bioLabel.text = self.userBio
        bioLabel.sizeToFit()
        userNameLabel.text = self.userName
        locationLabel.text = self.userLocation
        self.emptySubTitle = self.userAvailableSubTitle
        self.emptyTitle = self.userAvailableTitle
    }
    
    func loadCurrentUsersProfile(){
        self.emptySubTitle = self.currentUserAvailableSubTitle
        self.emptyTitle = self.currentUserAvailableTitle
        if let avatarUrl : String = userDefaults.string(forKey: Constants.USER_DEFAULTS.userAvatar){
            self.setAvatarImage(imageUrl: avatarUrl, imageView: self.avatarImage)
        }
        
        if let location = userDefaults.dictionary(forKey: Constants.USER_DEFAULTS.locationKey) as? [String : AnyObject]{
            locationLabel.text = Utilities.buildLocationLabel(location: location)
        }
        bioLabel.text = userDefaults.string(forKey: Constants.USER_DEFAULTS.bioKey)
        bioLabel.sizeToFit()
        userNameLabel.text = userDefaults.string(forKey: Constants.USER_DEFAULTS.nameKey)
        //TODO: Hide/show settings depending on if the current user.id = user.profile.id
        self.navigationItem.rightBarButtonItem = self.createSettingsButton()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(avatarTapped(tapGestureRecognizer:)))
        longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.longTapGestureRecognizer(tapGestureRecognizer:)))
        self.setupLongGestureRecognizer(gestureRecognizer: longTapGesture!)
        self.bookCollectionView.addGestureRecognizer(longTapGesture!)
        avatarImage.isUserInteractionEnabled = true
        avatarImage.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func createSettingsButton() -> UIBarButtonItem {
        let button: UIButton = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(#imageLiteral(resourceName: "settings").withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: .normal)
        button.setImage(#imageLiteral(resourceName: "settings").withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: .selected)
        button.setImage(#imageLiteral(resourceName: "settings").withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: .highlighted)
        
        button.addTarget(self, action: #selector(self.viewUserSettings), for: .touchUpInside)
        button.tintColor = UIColor.black
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        return UIBarButtonItem(customView: button)
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
        bookPopupInfo.titleToPass = cell.bookTitleLabel.text
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
        return numCells
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = bookCollectionView.dequeueReusableCell(withReuseIdentifier: "bookProfileCell", for: indexPath) as! BookCollectionViewCell
        cell.textbookView.isHidden = true
        let book = self.bookContent[indexPath.item]
        let owner = book["owner"] as! [String : AnyObject]
        //cell.layer.cornerRadius = CGFloat(Constants.DESIGN.cellRadius)
        cell.bookId = book["id"] as? Int
        cell.author = book["author"] as? String
        cell.bookTitleLabel.text = book["title"] as? String
        cell.status = book["status"] as? String
        cell.barcode = book["barcode"] as? String
        cell.condition = book["condition"] as? String
        cell.itemDescription = book["description"] as? String
        cell.ownerName = owner["name"] as? String
        cell.ownerAvatar = owner["avatar"] as? String
        cell.ownerId = owner["id"] as? Int
        cell.uploadedLabel.text = (book["uploadedTime"] as? String)! + " ago. "
        if let location : [String : AnyObject] = owner["location"] as? [String : AnyObject]{
            cell.location = location["city"] as? String
        }
        
        if let imageUrl : String = book ["imageUrl"] as? String {
            self.setBookImage(imageUrl: imageUrl, cell: cell)
        }
        
        if let bookCategory = book["category"] as? [String]{
            if bookCategory.contains("FREE"){
                cell.priceLabel.createFreeLabel()
            }
            
            if bookCategory.contains("TEXTBOOK"){
                cell.textbookView.isHidden = false
            }
        } else if let price = book["price"] as? Int {
            cell.priceLabel.text = "$".appending(String(describing: price)) // todo: in future update to use ISO codes
        } else {
            cell.priceLabel.text = "Price not provided."
        }
        
        // Check if the last row number is the same as the last current data element
        if indexPath.row == self.bookContent.count - 1 {
            self.pageNum = (pageNum + 1)
            if(self.bookStatusSegmentControl.selectedSegmentIndex == 0){
                self.loadUserAvailableBooks(userId: self.userId!)
            } else {
                self.loadUserUnavailableBooks(userId: self.userId!)
            }
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
        guard !self.reachedEndOfBookResults else {
            return
        }
        let token : String = userDefaults.string(forKey: "access_token")!
        BookService().findAvailableBooksByUserId(token: token, userId: userId, page: String(self.pageNum), size: Constants.SCROLL.pageSize) { (dictionary) in
            OperationQueue.main.addOperation{
                if let content = dictionary.value(forKey: "content") as? [[String : AnyObject]] {
                    self.numBooksInResults = dictionary.value(forKey: "totalElements") as! Int?
                    self.numCells = self.numCells + (dictionary.value(forKey: "numberOfElements") as! Int)
                    if(self.bookContent.count <= 1){
                        self.bookContent = content
                    } else {
                        let additionalContent : [[String : AnyObject]] = dictionary.value(forKey: "content") as! [[String : AnyObject]]
                        for content in additionalContent {
                            self.bookContent.append(content)
                        }
                    }
                    
                    self.flagReachedEndOfBookResultContent()
                    self.bookCollectionView.reloadData()
                }
            }
        }
    }
    
    // Load all of the books that are no longer available by the user
    func loadUserUnavailableBooks(userId: String){
        guard !self.reachedEndOfBookResults else {
            return
        }
        let token : String = userDefaults.string(forKey: "access_token")!
        BookService().findUnavailableBooksByUserId(token: token, userId: userId, page: String(self.pageNum), size: Constants.SCROLL.pageSize) { (dictionary) in
            OperationQueue.main.addOperation {
                if let content = dictionary.value(forKey: "content") as? [[String : AnyObject]]{
                    self.numBooksInResults = dictionary.value(forKey: "totalElements") as! Int?
                    self.numCells = self.numCells + (dictionary.value(forKey: "numberOfElements") as! Int)
                    if(self.bookContent.count <= 1){
                        self.bookContent = content
                    } else {
                        let additionalContent : [[String : AnyObject]] = dictionary.value(forKey: "content") as! [[String : AnyObject]]
                        for content in additionalContent {
                            self.bookContent.append(content)
                        }
                    }
                    
                    self.flagReachedEndOfBookResultContent()
                    self.bookCollectionView.reloadData()
                }
            }
        }
    }
    
    @IBAction func bookStatusView(_ sender: UISegmentedControl) {
        bookStatusSegmentControl.changeUnderlinePosition()
        self.bookContent = []
        self.resetPaginationValues()
        switch sender.selectedSegmentIndex {
        case 0:
            self.loadUserAvailableBooks(userId: self.userId!)
            self.setEmptyDataSetTitlesForAvailableBooks()
            break
        case 1:
            // Load unavailable books
            self.loadUserUnavailableBooks(userId: self.userId!)
            self.setEmptyDataSetTitlesForBooksSold()
            break
        default:
            break
        }
    }
    
    // Set the titles to be displayed in the empty dataset
    func setEmptyDataSetTitlesForAvailableBooks(){
        if(isCurrentUsersProfile)!{
            self.showAddNewBookButton = true
            self.emptyTitle = self.currentUserAvailableTitle
            self.emptySubTitle = self.currentUserAvailableSubTitle
        } else {
            self.emptyTitle = self.userAvailableTitle
            self.emptySubTitle = self.userAvailableSubTitle
        }
    }
    
    func setEmptyDataSetTitlesForBooksSold(){
        if(isCurrentUsersProfile)!{
            self.emptyTitle = self.currentUserSoldTitle
            self.emptySubTitle = self.currentUserSoldSubTitle
        } else {
            self.emptyTitle = self.userSoldTitle
            self.emptyTitle = self.userSoldSubTitle
        }
    }
    
    @IBAction func unwindToProfile(segue: UIStoryboardSegue) {
        if let changeAvatarView = segue.source as? ChangeAvatarViewController {
            if(changeAvatarView.imageView.image != nil){
                self.avatarImage.image = changeAvatarView.imageView.image
            }
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
            self.locationLabel.text = Utilities.buildLocationLabel(location: location)
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
                self.bookPopupIsDismissed(popup: popup)
                self.numCells = self.numCells - 1
                self.bookContent.remove(at: (popup.cellIndexPath?.item)!)
                self.bookCollectionView.deleteItems(at: [popup.cellIndexPath!])
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
                self.bookPopupIsDismissed(popup: popup)
                self.numCells = self.numCells - 1
                self.bookContent.remove(at: (popup.cellIndexPath?.item)!)
                self.bookCollectionView.deleteItems(at: [popup.cellIndexPath!])
                // show alert
            }
        }
    }
    
    func flagReachedEndOfBookResultContent(){
        print("Number of books in the results \(self.numBooksInResults)")
        if(self.bookContent.count >= self.numBooksInResults!){
            self.reachedEndOfBookResults = true
        }
    }
    
    func resetPaginationValues(){
        self.pageNum = 0
        self.numCells = 0
        self.numBooksInResults = 0
        self.reachedEndOfBookResults = false
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "textbook")
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = self.emptyTitle
        let attribs = [
            NSFontAttributeName: Constants.FONT.helvetica18,
            NSForegroundColorAttributeName: UIColor.darkGray
        ]
        
        return NSAttributedString(string: text!, attributes: attribs)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = self.emptySubTitle
        
        let para = NSMutableParagraphStyle()
        para.lineBreakMode = NSLineBreakMode.byWordWrapping
        para.alignment = NSTextAlignment.center
        
        let attribs = [
            NSFontAttributeName: Constants.FONT.helvetica14,
            NSForegroundColorAttributeName: UIColor.lightGray,
            NSParagraphStyleAttributeName: para
        ]
        
        return NSAttributedString(string: text!, attributes: attribs)
    }
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> NSAttributedString! {
        if(self.showAddNewBookButton){
            let text = "Tap here to add a new one."
            let attribs = [
                NSFontAttributeName: UIFont.boldSystemFont(ofSize: 16),
                NSForegroundColorAttributeName: view.tintColor
                ] as [String : Any]
            
            return NSAttributedString(string: text, attributes: attribs)
        }
        
        return NSAttributedString()
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
