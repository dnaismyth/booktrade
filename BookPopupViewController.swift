//
//  BookPopupViewController.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-03-30.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit

class BookPopupViewController: UIViewController {
    
    // MARK: - Properties
    
    // Passed through from previous view controller
    var authorToPass : String?
    var titleToPass : String?
    var coverImageToPass : UIImage?
    var priceToPass : String?
    
    @IBOutlet weak var bookCoverImage: UIImageView!
    @IBOutlet weak var bookTitle: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var createdDateLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.setBookInfoData()  // set book data
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setBookInfoData(){
        print(authorToPass)
        if(authorToPass != nil){
            self.authorLabel.text = authorToPass!
        }
        
        if(titleToPass != nil){
            self.bookTitle.text = titleToPass!
        }
        
        if(coverImageToPass != nil){
            self.bookCoverImage.image = coverImageToPass!
        }
    }
    // MARK: - Navigation
    
    @IBAction func exitBookPopup(_ sender: UIButton) {
        
    }
    
    @IBAction func getMoreBookInfo(_ sender: UIButton) {
        
    }

    /*
    

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
