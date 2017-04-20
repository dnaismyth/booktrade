    //
//  SearchViewController.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-03-25.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate, ProfileSelectDelegate, UIGestureRecognizerDelegate, FilterSelectCellDelegate {
    
    @IBOutlet var filterCollectionView: UICollectionView!
    @IBOutlet var searchCollectionView: UICollectionView!
    @IBOutlet var searchBar: UISearchBar!
    
    // User defaults
    let userDefaults = Foundation.UserDefaults.standard
    
    // Alert loading properties
    let alert : UIAlertController = UIAlertController(title: nil, message: "Fetching books...", preferredStyle: UIAlertControllerStyle.actionSheet)
    let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))

    var filterPrefs : [String : AnyObject] = [:]
    var bookContent : [[String : AnyObject]] = [[:]]
    var filterContent : [String] = []
    var searchActivated : Bool = false
    var cellToPass : BookSearchCollectionViewCell?
    var pageNum : Int = 0
    var numCells : Int = 0
    var numBooksInResults : Int?
    var reachedEndOfBookResults : Bool = false
    
    var cellTappedForProfileView : BookSearchCollectionViewCell?
    let avatarGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(avatarTapped(tapGestureRecognizer:)))
    let ownerNameGestureRecognizer = UITapGestureRecognizer(target : self, action: #selector(ownerNameTapped(tapGestureRecognizer:)))

    override func viewDidLoad() {
        super.viewDidLoad()
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.white
        loadingIndicator.startAnimating()
        alert.view.addSubview(loadingIndicator)
        self.searchBar.delegate = self
        self.searchCollectionView.delegate = self
        self.searchCollectionView.dataSource = self
        self.filterCollectionView.delegate = self
        self.filterCollectionView.dataSource = self
        avatarGestureRecognizer.delegate = self
        ownerNameGestureRecognizer.delegate = self
        //self.hideKeyboardWhenTappedAround()
        filterPrefs = userDefaults.dictionary(forKey: Constants.USER_DEFAULTS.filterPrefs) as! [String : AnyObject]
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateFilterPreferences(notification:)), name: NSNotification.Name(rawValue: Constants.NOTIFICATION.refreshFilter), object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(self.refreshTableData(notification:)), name: NSNotification.Name(rawValue: Constants.NOTIFICATION.refreshSearchTableData), object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
//    func refreshTableData(notification : NSNotification){
//        self.getMostRecentBooks()
//    }
    
    func updateFilterPreferences(notification: NSNotification){
        self.filterContent = []
        filterPrefs = userDefaults.dictionary(forKey: Constants.USER_DEFAULTS.filterPrefs) as! [String : AnyObject]
        print(filterPrefs)
        for (filter, value) in filterPrefs {
            if value as! Bool == true && filter != Constants.FILTER.distance && !filterContent.contains(filter as String) {
                self.filterContent.append(filter as String)
            } else if (filter == Constants.FILTER.distance && value as! Int > 0 && !filterContent.contains(filter as String)){
                self.filterContent.append(filter as String)
            }
        }
        self.filterCollectionView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("Cancelled")
        if(searchActivated){
            self.resetPaginationValues()
            self.getMostRecentBooks()   // only reload original result set if search had previously been activated
            searchActivated = false
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let searchValue : String = searchBar.text!
        let useFilter : Bool = self.shouldUseFilterPreferences()
        self.bookContent = []
        self.resetPaginationValues()
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
        if(collectionView == searchCollectionView){
            return numCells
        } else if (collectionView == filterCollectionView) {
            let cellCount = filterContent.count
            return cellCount
        } else {
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell : UICollectionViewCell?
        if(collectionView == searchCollectionView){
            cell = searchCollectionView.dequeueReusableCell(withReuseIdentifier: "searchBookCell", for: indexPath) as! BookSearchCollectionViewCell
            self.setUpSearchCollectionViewCells(cell: cell as! BookSearchCollectionViewCell, indexPath: indexPath)

        } else if (collectionView == filterCollectionView){
            cell = filterCollectionView.dequeueReusableCell(withReuseIdentifier: "selectedFilterCell", for: indexPath) as! FilterSelectedCollectionViewCell
            self.setUpSelectedFilterCells(cell: cell as! FilterSelectedCollectionViewCell, indexPath: indexPath)
        }
        
        return cell!
    }
    
    func setUpSelectedFilterCells(cell : FilterSelectedCollectionViewCell, indexPath : IndexPath){
        cell.delegate = self
        cell.filterLabel.text = self.filterContent[indexPath.item]
    }
    
    func setUpSearchCollectionViewCells(cell : BookSearchCollectionViewCell, indexPath : IndexPath){
        cell.textbookView.isHidden = true
        let book = self.bookContent[indexPath.item]
        let owner = book["owner"] as! [String : AnyObject]
        cell.delegate = self
        cell.layer.cornerRadius = CGFloat(Constants.DESIGN.cellRadius)
        cell.bookId = book["id"] as? Int
        cell.author = book["author"] as? String
        cell.titleLabel.text = book["title"] as? String
        cell.status = book["status"] as? String
        cell.barcode = book["barcode"] as? String
        cell.condition = book["condition"] as? String
        cell.itemDescription = book["description"] as? String
        cell.ownerName.setTitle(owner["name"] as? String, for: .normal)
        cell.ownerName.contentHorizontalAlignment = .left
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
        if let bookCategory = book["category"] as? [String]{
            if bookCategory.contains("FREE"){
                cell.priceLabel.createFreeLabel()
            }
            if bookCategory.contains("TEXTBOOK"){
                cell.textbookView.isHidden = false
                let textbookLabel = cell.textbookView.subviews.first as? UILabel
                textbookLabel!.diagonalLabel()
                textbookLabel?.isHidden = false
            } 
        } else if let price = book["price"] as? Int {
            cell.priceLabel.text = "$".appending(String(describing: price)) // todo: in future update to use ISO codes
        } else {
            cell.priceLabel.text = "Price not provided."
        }
        
        // Check if the last row number is the same as the last current data element
        if indexPath.row == self.bookContent.count - 1 {
            self.pageNum = (pageNum + 1)
            self.getMostRecentBooks()
        }

    }
    
    func removeFilterSelected(cell: FilterSelectedCollectionViewCell) {
        let indexPath : IndexPath = self.filterCollectionView.indexPath(for: cell)!
        if(self.filterContent.count > 0){
            self.filterContent.remove(at: indexPath.item)
        }
        self.filterCollectionView.deleteItems(at: [indexPath])
        self.updateFilterPrefsOnRemoval(filterKey: cell.filterLabel.text!)
    }
    
    func updateFilterPrefsOnRemoval(filterKey : String){
        if(filterKey != Constants.FILTER.distance){
            self.filterPrefs[filterKey] = false as AnyObject
        } else if (filterKey == Constants.FILTER.distance){
            self.filterPrefs[filterKey] = 0 as AnyObject
        }
        
        userDefaults.set( filterPrefs, forKey: Constants.USER_DEFAULTS.filterPrefs)   // update the user preferences
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
        guard !self.reachedEndOfBookResults else {
            return
        }
        present(alert, animated: true, completion: nil)
        let token : String = userDefaults.string(forKey: "access_token")!
        BookService().searchBooks(token: token, value: searchValue, page: String(self.pageNum), size: Constants.SCROLL.pageSize) { (dictionary) in
            OperationQueue.main.addOperation {
                if let numBooks = dictionary.value(forKey: "totalElements") as? Int {
                    self.numBooksInResults = numBooks
                    if(self.numBooksInResults! > 0){
                        //self.numCells = self.numCells + (dictionary.value(forKey: "numberOfElements") as! Int)
                        if(self.bookContent.count <= 1){
                            self.bookContent = dictionary.value(forKey: "content") as! [[String : AnyObject]]
                        } else {
                            let additionalContent : [[String : AnyObject]] = dictionary.value(forKey: "content") as! [[String : AnyObject]]
                            for content in additionalContent {
                                self.bookContent.append(content)
                            }
                        }
                        
                        self.numCells = self.bookContent.count
                        print(self.numCells)
                    }
                } else {
                    //TODO: show an empty screen as no results have been found
                }
                
                self.flagReachedEndOfBookResultContent()
                self.searchCollectionView.reloadData()
                self.alert.dismiss(animated: false, completion: nil)
            }
        }
    }
    
    // Filtered book search
    func searchBooksWithFilter(filter : String){
        guard !self.reachedEndOfBookResults else {
            return
        }
        present(alert, animated: true, completion: nil)
        let token : String = userDefaults.string(forKey: "access_token")!
        BookService().filterSearchBooks(token: token, filter: filter, page: String(self.pageNum), size: Constants.SCROLL.pageSize) { (dictionary) in
            OperationQueue.main.addOperation {
                if let numBooks = dictionary.value(forKey: "totalElements") as? Int {
                    self.numBooksInResults = numBooks
                    if(self.numBooksInResults! > 0){
                        //self.numCells = self.numCells + (dictionary.value(forKey: "numberOfElements") as! Int)
                        if(self.bookContent.count <= 1){
                            self.bookContent = dictionary.value(forKey: "content") as! [[String : AnyObject]]
                        } else {
                            let additionalContent : [[String : AnyObject]] = dictionary.value(forKey: "content") as! [[String : AnyObject]]
                            for content in additionalContent {
                                self.bookContent.append(content)
                            }
                        }
                        self.numCells = self.bookContent.count
                        print(self.numCells)
                    }
                } else {
                    //TODO: Show an empty screen as no results have been found
                }
                
                self.flagReachedEndOfBookResultContent()
                self.searchCollectionView.reloadData()
                self.alert.dismiss(animated: false, completion: nil)
            }
        }
    }
    
    // Initially display most recent, nearby books
    func getMostRecentBooks(){
        guard !self.reachedEndOfBookResults else {
            return
        }
        let token : String = userDefaults.string(forKey: "access_token")!
        BookService().getMostRecentBooks(token: token, page: String(self.pageNum), size: Constants.SCROLL.pageSize) { (dictionary) in
            OperationQueue.main.addOperation {
                //self.numCells = self.numCells + (dictionary.value(forKey: "numberOfElements") as! Int)
                self.numBooksInResults = dictionary.value(forKey: "totalElements") as! Int?
                print("Current book content count is: \(self.bookContent.count)")
                if(self.bookContent.count <= 1){    // might have to change this back to <= 1
                    self.bookContent = dictionary.value(forKey: "content") as! [[String : AnyObject]]
                } else {
                    let additionalContent : [[String : AnyObject]] = dictionary.value(forKey: "content") as! [[String : AnyObject]]
                    for content in additionalContent {
                        self.bookContent.append(content)
                    }
                }
                self.numCells = self.bookContent.count
                print(self.numCells)
                print("After book content count is: \(self.bookContent.count)")
                self.flagReachedEndOfBookResultContent()
                self.searchCollectionView.reloadData()
            }
        }
    }
    
    func shouldUseFilterPreferences() -> Bool {
        if(self.filterContent.count > 0){
            return true
        }
        return false
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
    
    func flagReachedEndOfBookResultContent(){
        print("Number of books in the results \(self.numBooksInResults)")
        if(self.bookContent.count >= self.numBooksInResults!){
            self.reachedEndOfBookResults = true
        }
    }
    
    func avatarTapped(tapGestureRecognizer: UITapGestureRecognizer){
        print("Hello?")
    }
    
    func ownerNameTapped(tapGestureRecognizer: UITapGestureRecognizer){
        print("HI!")
    }
    
    func resetPaginationValues(){
        self.pageNum = 0
        self.numCells = 0
        self.numBooksInResults = 0
        self.reachedEndOfBookResults = false
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
