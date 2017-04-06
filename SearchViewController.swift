    //
//  SearchViewController.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-03-25.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate {
    
    @IBOutlet var searchCollectionView: UICollectionView!
    @IBOutlet var searchBar: UISearchBar!
    
    let userDefaults = Foundation.UserDefaults.standard
    var filterPrefs : [String : AnyObject] = [:]
    var bookContent : NSArray = []
    var searchActivated : Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        self.searchCollectionView.delegate = self
        self.searchCollectionView.dataSource = self
        self.hideKeyboardWhenTappedAround()
        filterPrefs = userDefaults.dictionary(forKey: "filter_pref") as! [String : AnyObject]
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            
        }
        searchActivated = true;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bookContent.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = searchCollectionView.dequeueReusableCell(withReuseIdentifier: "searchBookCell", for: indexPath) as! BookSearchCollectionViewCell
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
    
    
    func setBookImage(imageUrl: String, cell : BookSearchCollectionViewCell){
        print(cell)
        if let url = NSURL(string: imageUrl) {
            if let data = NSData(contentsOf: url as URL){
                if let imageUrl = UIImage(data: data as Data) {
                    cell.coverImage.image = imageUrl
                }
            }
        }
    }
    
    func searchBooksWithoutFilter(searchValue : String){
        let token : String = userDefaults.string(forKey: "access_token")!
        BookService().searchBooks(token: token, value: searchValue, page: String(0), size: String(5)) { (dictionary) in
            OperationQueue.main.addOperation {
                self.bookContent = dictionary.value(forKey: "content") as! NSArray
                self.searchCollectionView.reloadData()
            }
        }
    }
    
    // Initially display most recent, nearby books
    func getMostRecentBooks(){
        let token : String = userDefaults.string(forKey: "access_token")!
        BookService().getMostRecentBooks(token: token, page: String(0), size: String(10)) { (dictionary) in
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
