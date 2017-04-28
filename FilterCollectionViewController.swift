//
//  FilterCollectionViewController.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-04-27.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit

private let reuseIdentifier = "filterCollectionCell"

class FilterCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    let filterCategories: [String] = [
        "Children",
        "Fiction",
        "Free",
        "Non-Fic",
        "Textbook"
    ]
    
    @IBOutlet var filterCollection: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        filterCollection.delegate = self
        filterCollection.dataSource = self
        filterCollection.
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return filterCategories.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FilterCollectionViewCell
        let filter = filterCategories[indexPath.item]
        cell.filterLabel.text = filter
        return cell
    }

}
