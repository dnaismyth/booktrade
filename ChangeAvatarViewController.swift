//
//  ChangeAvatarViewController.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-03-29.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit

class ChangeAvatarViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK : - Properties
    var imagePicker = UIImagePickerController()
    var imageView = UIImageView()
    var selectedImageUrl: NSURL!
    var imageSelected = false
    let userDefaults = Foundation.UserDefaults.standard
    var segueFromController : String?   // previous view controller


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
        } else {
            self.showNoCameraAlert()
        }
    }
    
    // Take photo
    @IBAction func takePhoto(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            self.showNoCameraAlert()
        }
    }
    
    func showNoCameraAlert(){
        let alertVC = UIAlertController(
            title: "Camera not Available",
            message: "Please turn camera availability on through your device settings menu.",
            preferredStyle: .alert)
        let okAction = UIAlertAction(
            title: "OK",
            style:.default,
            handler: nil)
        alertVC.addAction(okAction)
        present(
            alertVC,
            animated: true,
            completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var image : UIImage?
        if(picker.sourceType == .camera){
            // If coming from camera
            let tempFileUrl : String = "camera"
            image = info[UIImagePickerControllerOriginalImage] as? UIImage
            self.s3UploadFromCamera(image: image, fileName: tempFileUrl)
        }  else {
            // If coming from album
            selectedImageUrl = info[UIImagePickerControllerReferenceURL] as! NSURL
            image = info[UIImagePickerControllerOriginalImage] as? UIImage
            self.s3UploadFromLibrary(image: image, selectedImageUrl : selectedImageUrl)
        }

        if(segueFromController == "ProfileController"){
            performSegue(withIdentifier: "unwindToProfile", sender: self)
        }
        
        if(segueFromController == "SettingsController"){
            performSegue(withIdentifier: "unwindToProfileSettings", sender: self)
        }

    }
    
    func saveImage (image : UIImage, path: String){
        let data = UIImageJPEGRepresentation(image, 0.6)
        let filePath = NSURL(fileURLWithPath: NSTemporaryDirectory().appending(path))
        do{
            try data!.write(to: filePath as URL , options: .atomic)
        } catch {
            print(error)
        }
    }
    
    func fileInDocumentsDirectory(fileName: String) -> NSURL {
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in:.userDomainMask).first!
        return documentsUrl.appendingPathComponent(fileName) as NSURL
    }
    
    func s3UploadFromLibrary(image : UIImage?, selectedImageUrl : NSURL){
        if(image != nil){
            imageView.image = image?.resized(withPercentage: 0.1)
            imageView.contentMode = UIViewContentMode.scaleAspectFill
            imageSelected = true
            dismiss(animated: true, completion: nil)
            print(imageView)
            let s3KeyPrefix : String = userDefaults.string(forKey: Constants.USER_DEFAULTS.userIdKey)!.appending("/AVATAR_")
            S3Service().uploadImageFromLibrary(selectedImageUrl: selectedImageUrl, image: imageView.image!, keyPrefix: s3KeyPrefix) { (avatar) in
                OperationQueue.main.addOperation {
                    UserService().updateUserAvatar(avatar: avatar)
                }
            }
        }
    }
    
    func s3UploadFromCamera(image: UIImage?, fileName : String){
        if(image != nil){
            imageView.image = image?.resized(withPercentage: 0.1)
            imageView.contentMode = UIViewContentMode.scaleAspectFill
            imageSelected = true
            dismiss(animated: true, completion: nil)
            print(imageView)
            let s3KeyPrefix : String = userDefaults.string(forKey: Constants.USER_DEFAULTS.userIdKey)!.appending("/AVATAR_")
            S3Service().uploadImageFromCamera(fileName: fileName, image: imageView.image!, keyPrefix: s3KeyPrefix) { (avatar) in
                OperationQueue.main.addOperation {
                    UserService().updateUserAvatar(avatar: avatar)
                }
            }
        }
    }
  
    
    // MARK : - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindToProfile" {
            print(imageSelected)
            if(imageSelected){
                let profileView = segue.destination as! ProfileViewController
                profileView.avatarImage.image = self.imageView.image
            }
        }
        
        if segue.identifier == "unwindToProfileSettings" {
            if(imageSelected){
                let profileSettingsView = segue.destination as! UpdateProfileTableViewController
                profileSettingsView.avatarImage.image = self.imageView.image
            }
        }
    }
    
    @IBAction func cancelButton(_ sender: UIButton) {
        if(segueFromController == "ProfileController"){
            performSegue(withIdentifier: "unwindToProfile", sender: self)
        }
        
        if(segueFromController == "SettingsController"){
            performSegue(withIdentifier: "unwindToProfileSettings", sender: self)
        }
    }
   
}
