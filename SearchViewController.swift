    //
//  SearchViewController.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-03-25.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate, ProfileSelectDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet var searchCollectionView: UICollectionView!
    @IBOutlet var searchBar: UISearchBar!
    
    let userDefaults = Foundation.UserDefaults.standard
    var filterPrefs : [String : AnyObject] = [:]
    var bookContent : NSArray = []
    var searchActivated : Bool = false
    var cellToPass : BookSearchCollectionViewCell?
    
    var cellTappedForProfileView : BookSearchCollectionViewCell?
    let avatarGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(avatarTapped(tapGestureRecognizer:)))
    let ownerNameGestureRecognizer = UITapGestureRecognizer(target : self, action: #selector(ownerNameTapped(tapGestureRecognizer:)))

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        self.searchCollectionView.delegate = self
        self.searchCollectionView.dataSource = self
        avatarGestureRecognizer.delegate = self
        ownerNameGestureRecognizer.delegate = self
        //self.hideKeyboardWhenTappedAround()
        filterPrefs = userDefaults.dictionary(forKey: "filter_pref") as! [String : AnyObject]
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateFilterPreferences(notification:)), name: NSNotification.Name(rawValue: Constants.NOTIFICATION.refreshFilter), object: nil)
        // Do any additional setup after loading the view.s
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func updateFilterPreferences(notification: NSNotification){
        filterPrefs = userDefaults.dictionary(forKey: "filter_pref") as! [String : AnyObject]
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("Cancelled")
        if(searchActivated){
            self.getMostRecentBooks()   // only reload original result set if search had previously been activated
            searchActivated = false
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let searchValue : String = searchBar.text!
        let useFilter : Bool = self.shouldUseFilterPreferences()
        if(!useFilter){
            self.searchBooksWithoutFilter(searchValue: searchValue)
        } else {
            let filterURL : String = self.buildFilteredSearchURL(searchValue: searchValue)
            self.searchBooksWithFilter(filter: filterURL)
        }
        searchActivated = true;
    }
    
    func buildFilteredSearchURL(searchValue : String) -> String{
        var filterURL : String = "&author=".appending(searchValue).appending("&title=").appending(searchValue)
        var firstCategory : Bool = true
        let price : Bool = filterPrefs[Constants.FILTER.price] as! Bool  // order by price
        let recent : Bool = filterPrefs[Constants.FILTER.recent] as! Bool    // order by recent
        let distance : Int = filterPrefs[Constants.FILTER.distance] as! Int
        let textbook : Bool = filterPrefs[Constants.FILTER.textbook] as! Bool
        let free : Bool = filterPrefs[Constants.FILTER.free] as! Bool
        if(price){
            filterURL = filterURL.appending("&sort=price")
        } else if (recent){
            filterURL = filterURL.appending("&sort=createdDate")
        }
        
        if(distance > 0){
            filterURL = filterURL.appending("&distance=").appending(String(distance))
        }
        
        if(textbook){
            filterURL = filterURL.appending("&category=TEXTBOOK")
            firstCategory = false
        }
        
        if(free && !firstCategory){
            filterURL = filterURL.appending(",FREE")
        } else if (free){
            filterURL = filterURL.appending("&category=FREE")
        }
        
        print(filterURL)
        return filterURL
        
    }
        
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bookContent.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = searchCollectionView.dequeueReusableCell(withReuseIdentifier: "searchBookCell", for: indexPath) as! BookSearchCollectionViewCell
        cell.delegate = self
        let book = self.bookContent[indexPath.item] as! [String : AnyObject]
        let owner = book["owner"] as! [String : AnyObject]
        cell.layer.cornerRadius = CGFloat(Constants.DESIGN.cellRadius)
        cell.bookId = book["id"] as? Int
        cell.author = book["author"] as? String
        cell.titleLabel.text = book["title"] as? String
        cell.status = book["status"] as? String
        cell.barcode = book["barcode"] as? String
        cell.condition = book["condition"] as? String
        cell.itemDescription = book["description"] as? String
        cell.ownerName.setTitle(owner["name"] as? String, for: .normal)
        cell.ownerId = owner["id"] as? Int
        cell.uploadedTime.text = (book["uploadedTime"] as? String)! + " ago. "
        cell.ownerName.isUserInteractionEnabled = true
        cell.ownerName.addGestureRecognizer(ownerNameGestureRecognizer)
        if let location : [String : AnyObject] = owner["location"] as? [String : AnyObject]{
            cell.location = Utilities.buildLocationLabel(location: location)
        }
        
        if let imageUrl : String = book ["imageUrl"] as? String {
            self.setCellImage(imageUrl: imageUrl, cell: cell, isOwnerAvatar: false)
        }
        
        if let avatarImage : String = owner["avatar"] as? String {
            self.setCellImage(imageUrl: avatarImage, cell: cell, isOwnerAvatar: true)
        }
        
        if let bio : String = owner["bio"] as? String {
            cell.ownersBio = bio
        }
        
        cell.ownerAvatar.layer.cornerRadius = (0.5 * cell.ownerAvatar.bounds.size.width)
        cell.ownerAvatar.clipsToBounds = true
        cell.addGestureRecognizer(avatarGestureRecognizer)
        
        if let bookCategory : String = book["category"] as? String {
            if(bookCategory == "FREE"){
                cell.priceLabel.text = "Free"
                cell.priceLabel.backgroundColor = Constants.COLOR.freeGreen
                cell.priceLabel.layer.cornerRadius = CGFloat(Constants.DESIGN.cellRadius)
                cell.priceLabel.textAlignment = NSTextAlignment.center
                cell.priceLabel.textColor = UIColor.white
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected!")
        cellToPass = collectionView.cellForItem(at: indexPath) as? BookSearchCollectionViewCell
        performSegue(withIdentifier: "searchBookPopupSegue", sender: self)
    }
    
    func setCellImage(imageUrl: String, cell : BookSearchCollectionViewCell, isOwnerAvatar : Bool){
        print(cell)
        if let url = NSURL(string: imageUrl) {
            if let data = NSData(contentsOf: url as URL){
                if let imageUrl = UIImage(data: data as Data) {
                    if(!isOwnerAvatar){
                        cell.coverImage.image = imageUrl
                    } else {
                        cell.ownerAvatar.setImage(imageUrl.withRenderingMode(.alwaysOriginal), for: .normal)
                    }
                }
            }
        }
    }
    
    func ownerAvatarTapped(cell: BookSearchCollectionViewCell) {
        cellTappedForProfileView = cell
        performSegue(withIdentifier: "profileSegueFromSearch", sender: self)
    }
    
    func ownerNameTapped(cell: BookSearchCollectionViewCell) {
        cellTappedForProfileView = cell
        performSegue(withIdentifier: "profileSegueFromSearch", sender: self)
    }
    
    // Search books by title & author
    func searchBooksWithoutFilter(searchValue : String){
        let token : String = userDefaults.string(forKey: "access_token")!
        BookService().searchBooks(token: token, value: searchValue, page: String(0), size: String(50)) { (dictionary) in
            OperationQueue.main.addOperation {
                self.bookContent = dictionary.value(forKey: "content") as! NSArray
                self.searchCollectionView.reloadData()
            }
        }
    }
    
    // Filtered book search
    func searchBooksWithFilter(filter : String){
        let token : String = userDefaults.string(forKey: "access_token")!
        BookService().filterSearchBooks(token: token, filter: filter, page: String(0), size: String(50)) { (dictionary) in
            OperationQueue.main.addOperation {
                self.bookContent = dictionary.value(forKey: "content") as! NSArray
                self.searchCollectionView.reloadData()
            }
        }
    }
    
    // Initially display most recent, nearby books
    func getMostRecentBooks(){
        let token : String = userDefaults.string(forKey: "access_token")!
        BookService().getMostRecentBooks(token: token, page: String(0), size: String(50)) { (dictionary) in
            OperationQueue.main.addOperation {
                self.bookContent = dictionary.value(forKey: "content") as! NSArray
                self.searchCollectionView.reloadData()
            }
        }
    }
    
    func shouldUseFilterPreferences() -> Bool {
        let useFilterPrefs : Bool = filterPrefs[Constants.FILTER.useFilter] as! Bool
        return useFilterPrefs
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "searchBookPopupSegue"){
            let destination = segue.destination as! BookPopupViewController
            destination.segueFromController = "SearchViewController"
            let bookInfoView = segue.destination as! BookPopupViewController
            if(cellToPass != nil){
                self.setPopupInfo(bookPopupInfo: bookInfoView, cell: cellToPass!)
            }
        }
        
        if(segue.identifier == "profileSegueFromSearch"){
            let destination = segue.destination as! ProfileViewController
            let currentUserId = userDefaults.string(forKey: Constants.USER_DEFAULTS.userIdKey)
            destination.userId = currentUserId
            let cellTappedOwnerId : String = String(describing: cellTappedForProfileView!.ownerId!)
            print("The current owner id is: \(cellTappedOwnerId)")
            destination.loadUserAvailableBooks(userId: cellTappedOwnerId)
            if(currentUserId != cellTappedOwnerId){
                destination.isCurrentUsersProfile = false
                destination.userName = cellTappedForProfileView?.ownerName.titleLabel?.text
                destination.userBio = cellTappedForProfileView?.ownersBio
                destination.userAvatar = cellTappedForProfileView?.ownerAvatar.imageView?.image
                destination.userLocation = cellTappedForProfileView?.location
            } else {
                print("This is the current user's profile")
                destination.isCurrentUsersProfile = true
            }
            
        }
    }
    
    func avatarTapped(tapGestureRecognizer: UITapGestureRecognizer){
        print("Hello?")
    }
    
    func ownerNameTapped(tapGestureRecognizer: UITapGestureRecognizer){
        print("HI!")
    }
    
    
    private func setPopupInfo (bookPopupInfo : BookPopupViewController, cell : BookSearchCollectionViewCell){
        bookPopupInfo.authorToPass = cell.author
        bookPopupInfo.titleToPass = cell.titleLabel.text
        bookPopupInfo.coverImageToPass = cell.coverImage.image
        bookPopupInfo.ownerIdToPass = cell.ownerId
        bookPopupInfo.currentBookId = cell.bookId
        bookPopupInfo.ownerLocation = cell.location
        bookPopupInfo.bookInformation = cell.itemDescription
        bookPopupInfo.bookCondition = cell.condition
    }
    
    @IBAction func unwindToSearch(segue: UIStoryboardSegue) {}
}
