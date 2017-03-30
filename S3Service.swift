//
//  S3Service.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-03-29.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import Foundation
import AWSS3
import AWSCore
import Photos

// Class to handle S3 Services for image uploading
class S3Service {
    
    typealias FinishedUploading = (String) -> ()

    
    init(){
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: AWSRegionType.USWest2, identityPoolId: Constants.S3.poolId)
        let configuration = AWSServiceConfiguration(region: AWSRegionType.USWest2, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
    }
    
   
    func startUploadingImage(selectedImageUrl : NSURL?, image : UIImage, keyPrefix: String, completed : @escaping FinishedUploading)
    {
        var localFileName:String?
        if let imageToUploadUrl = selectedImageUrl
        {
            
            let phResult = PHAsset.fetchAssets(withALAssetURLs: [imageToUploadUrl as URL], options: nil)
            localFileName = phResult.firstObject?.value(forKey: "filename") as! String?
        }
        
        if localFileName == nil
        {
            return
        }
    
        
        let remoteName = localFileName!
        
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest?.body = self.generateImageUrl(fileName: remoteName, image: image) as URL
        uploadRequest?.key = keyPrefix.appending(localFileName!).appending("_").appending(UUID().uuidString)
        print("Key is: \(uploadRequest?.key!)")

        uploadRequest?.bucket = Constants.S3.bucket
        uploadRequest?.contentType = "image/jpeg"
        
        
        let transferManager = AWSS3TransferManager.default()
        
        // Perform file upload
        transferManager.upload(uploadRequest!).continueWith { (task) -> AnyObject! in
            
            if let error = task.error {
                print("Upload failed with error: (\(error.localizedDescription))")
            }
            
            if task.result != nil {
                if(uploadRequest != nil){
                    let s3URL : String = "https://\(Constants.S3.bucket).s3.amazonaws.com/\(uploadRequest!.key!)"
                    print("Uploaded to:\n\(s3URL)")
                    completed(s3URL)
                }
                // Remove locally stored file
                self.remoteImageWithUrl(fileName: localFileName!)
                
            }
                
            else {
                print("Unexpected empty result.")
            }
            return nil
        }
    }
    
    func generateImageUrl(fileName: String, image : UIImage) -> NSURL{
        let fileURL = NSURL(fileURLWithPath: NSTemporaryDirectory().appending(fileName))
        let data = UIImageJPEGRepresentation(image, 0.6)
        do{
            try data!.write(to: fileURL as URL, options: .atomic)
        } catch {
            print(error)
        }
        
        return fileURL
    }
    
    func remoteImageWithUrl(fileName: String){
        let fileURL = NSURL(fileURLWithPath: NSTemporaryDirectory().appending(fileName))
        do {
            try FileManager.default.removeItem(at: fileURL as URL)
        } catch
        {
            print(error)
        }
    }
    
}
