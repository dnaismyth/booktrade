//
//  ChangeAvatarViewController.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-03-29.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit

class ChangeAvatarViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var imagePicker = UIImagePickerController()
    var imageView = UIImageView()
    var selectedImageUrl: NSURL!
    var imageSelected = false
    let userDefaults = Foundation.UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Choose photo from library
    @IBAction func choosePhotoFromLibrary(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            print("Button capture")
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    // Take photo
    @IBAction func takePhoto(_ sender: UIButton) {
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //first run if its coming from photo album
        selectedImageUrl = info[UIImagePickerControllerReferenceURL] as! NSURL
        imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        imageView.contentMode = UIViewContentMode.scaleAspectFill
        dismiss(animated: true, completion: nil)
        print(imageView)
        let s3KeyPrefix : String = userDefaults.string(forKey: "user_id")!.appending("/AVATAR_")
        S3Service().startUploadingImage(selectedImageUrl: selectedImageUrl, image: imageView.image!, keyPrefix: s3KeyPrefix) { (avatar) in
            UserService().updateUserAvatar(avatar: avatar)
        }
        performSegue(withIdentifier: "unwindToProfile", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindToProfile" {
            if(imageSelected){
                let profileView = segue.destination as! ProfileViewController
                profileView.avatarImage.image = self.imageView.image
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
