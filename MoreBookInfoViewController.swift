//
//  MoreBookInfoViewController.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-03-31.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit

class MoreBookInfoViewController: UIViewController {
    
    var conditionHolder : String?
    var informationHolder : String?
    var locationHolder : String?

    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var bookInformation: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.setBookInformation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Set the book information in the popup
    private func setBookInformation(){
        if(conditionHolder != nil){
            conditionLabel.text = conditionHolder!
        }
        
        if(informationHolder != nil){
            bookInformation.text = informationHolder!
        }
        
        if(locationHolder != nil){
            locationLabel.text = locationHolder!
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
