//
//  ScanViewController.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-03-22.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit
import AVFoundation

class ScanViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ScanOrCameraPopupViewDelegate, BookConfirmationPopupViewDelegate {
    
    var previousViewControllerIndex: Int? // default, return to search
    
    let userDefaults = Foundation.UserDefaults.standard

    var scanOrCameraPopup : ScanOrCameraPopupView!
    var bookConfirmationPopup : BookConfirmationPopupView!
    
    var bookSource : String?
    
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    var barcodeDetected : Bool = false
    var capturedISBN : String?
    var smallImageUrl : String?
    var largeImageUrl: String?
    var bookTitle : String?
    var author : String?
    var coverImage : UIImage?
    var imagePicker : UIImagePickerController?
    
    // Camera related properties
    var imageView = UIImageView()
    var selectedImageUrl: NSURL!
    var imageSelected = false
    var isFromCamera: Bool = false
    var isFromLibrary : Bool = false
    var userCanEdit : Bool = false
    var saveChangesSelected : Bool = true
    
    let undectedBarcodeMessage : String = "Cannot read barcode."
    let supportedCodeTypes = [AVMetadataObjectTypeUPCECode,
                              AVMetadataObjectTypeCode39Code,
                              AVMetadataObjectTypeCode39Mod43Code,
                              AVMetadataObjectTypeCode93Code,
                              AVMetadataObjectTypeCode128Code,
                              AVMetadataObjectTypeEAN8Code,
                              AVMetadataObjectTypeEAN13Code,
                              AVMetadataObjectTypeAztecCode,
                              AVMetadataObjectTypePDF417Code,
                              AVMetadataObjectTypeQRCode]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.showStatusPopup()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.cancelAddingBookPosting))
        //self.setupScanner()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if(previousViewControllerIndex == nil){
            previousViewControllerIndex = 0;
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func cancelAddingBookPosting(){
        self.tabBarController?.selectedIndex = self.previousViewControllerIndex!    // on cancel, go back to the previously viewed controller
    }
    
    // MARK: - AVCaptureMetadataOutputObjectsDelegate Methods
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if (metadataObjects == nil || metadataObjects.count == 0) && !barcodeDetected {
            qrCodeFrameView?.frame = CGRect.zero
            //messageLabel.text = undectedBarcodeMessage
            //TODO: Show alert that you could not detect books barcode
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedCodeTypes.contains(metadataObj.type) && !barcodeDetected {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                barcodeDetected = true
                capturedISBN = metadataObj.stringValue
                if((capturedISBN) != nil){
                    searchBookByBarcode(barcode: capturedISBN!)
                }
            }
            
            // Stop capture session
            videoPreviewLayer?.isHidden = true
            qrCodeFrameView?.isHidden = true
            self.captureSession?.stopRunning()
        }
    }
    
    func searchBookByBarcode(barcode : String){
        print(barcode)
        let url : String = Constants.GOODREADS.searchByIsbn.appending(barcode)
        GetRequest().HTTPGetXML(getUrl: url, token: nil) { (dictionary) in
           print(dictionary)
            self.bookTitle = dictionary.value(forKey: "title") as! String?
            self.author = dictionary.value(forKey: "name") as! String?
            let imageUrl : String = (dictionary.value(forKey: "image_url") as! String?)!
            self.smallImageUrl = imageUrl
            self.largeImageUrl = self.formatLargeImageUrl(url: imageUrl)
            self.bookSource = Constants.BOOKSOURCE.goodreads
            if(self.largeImageUrl != nil){
                self.setBookImage(imageUrl: self.largeImageUrl!)
            } else {
                // set default image
                self.showBookConfirmationPopup()
            }
        }
    }
    
    func formatLargeImageUrl(url : String) -> String {
        if(url.contains(Constants.GOODREADS.baseUrl)){
            let index = Constants.GOODREADS.baseUrl.index(Constants.GOODREADS.baseUrl.startIndex, offsetBy : Constants.GOODREADS.baseUrl.characters.count)
            var splitUrl : String = Constants.GOODREADS.baseUrl.substring(from: index)
            print(splitUrl)
            splitUrl = splitUrl.replacingOccurrences(of: "m/", with: "l/")
            return Constants.GOODREADS.baseUrl.appending(splitUrl)
        } else {
            return url
        }
    }
    
    func setBookImage(imageUrl: String){
        let url = URL(string: imageUrl)
        
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            DispatchQueue.main.async {
                self.coverImage = UIImage(data: data!)
                self.showBookConfirmationPopup()
            }
        }
    }
    
    func setupScanner(){
        // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video as the media type parameter.
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Initialize the captureSession object.
            captureSession = AVCaptureSession()
            
            // Set the input device on the capture session.
            captureSession?.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
            
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            // Start video capture.
            captureSession?.startRunning()
            
            // Initialize QR Code Frame to highlight the QR code
            qrCodeFrameView = UIView()
            
            if let qrCodeFrameView = qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                qrCodeFrameView.layer.borderWidth = 2
                view.addSubview(qrCodeFrameView)
                view.bringSubview(toFront: qrCodeFrameView)
            }
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
    }
    
    @IBAction func continueToPostingButton(_ sender: UIButton) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "bookPostingSegue" {
            print("Continue to posting.")
            let bookPostingView = segue.destination as! BookPostingTableViewController
            if(!isFromCamera ){
                bookPostingView.tmbImageUrl = self.smallImageUrl // thumbnail image
            }
            
            bookPostingView.titleHolder = self.bookConfirmationPopup.titleTextField.text
            bookPostingView.authorHolder = self.bookConfirmationPopup.authorTextField.text
            
            bookPostingView.isFromLibrary = self.isFromLibrary
            bookPostingView.isFromCamera = self.isFromCamera
            
            if(isFromLibrary){
                bookPostingView.selectedImageUrl = self.selectedImageUrl
            }
            
            bookPostingView.mainImageUrl = self.largeImageUrl   // main, larger image
            bookPostingView.dataSource = self.bookSource!
            if(self.capturedISBN != nil){
                bookPostingView.isbnHolder = self.capturedISBN!
            }
            bookPostingView.imageHolder = self.bookConfirmationPopup.coverImage.image
        }
    }
    
    @IBAction func backToScannerButton(_ sender: UIButton) {
        print("Back to scanner")
    }
    
    func showStatusPopup(){
        self.scanOrCameraPopup = ScanOrCameraPopupView(frame: CGRect(x: 10, y: 200, width: 300, height: 200))
        self.scanOrCameraPopup.delegate = self
        self.view.addSubview(self.scanOrCameraPopup)
    }
    
    func showBookConfirmationPopup(){
        self.bookConfirmationPopup = BookConfirmationPopupView(frame: CGRect(x: 10, y: 100, width: 300, height: 375))
        if(!isFromCamera && !isFromLibrary){
            self.bookConfirmationPopup.authorTextField.text = self.author
            self.bookConfirmationPopup.titleTextField.text = self.bookTitle
            self.toggleEditingTextFields(popup: bookConfirmationPopup)
        } else {
            self.bookConfirmationPopup.editButton.isHidden = true   // fields will already be editable, no need to show this button
        }
        if(self.coverImage != nil){
            self.bookConfirmationPopup.coverImage.image = self.coverImage!
        }
        self.bookConfirmationPopup.delegate = self
        self.view.addSubview(self.bookConfirmationPopup)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if(picker.sourceType == .camera){
            // If coming from camera
            let tempFileUrl : String = "camera"
            self.coverImage = info[UIImagePickerControllerOriginalImage] as? UIImage
            //self.s3UploadFromCamera(image: image, fileName: tempFileUrl)
        }  else {
            // If coming from album
            selectedImageUrl = info[UIImagePickerControllerReferenceURL] as! NSURL
            self.coverImage = info[UIImagePickerControllerOriginalImage] as? UIImage
            //self.s3UploadFromLibrary(image: image, selectedImageUrl : selectedImageUrl)
        }
        
        self.bookSource = Constants.BOOKSOURCE.book_trader
        dismiss(animated: true, completion: nil)
        self.showBookConfirmationPopup()
    }
    
    func useCameraIsSelected(popup: ScanOrCameraPopupView) {
        scanOrCameraPopup.removeFromSuperview()
        imagePicker = UIImagePickerController()
        imagePicker?.delegate = self
        print("Camera is selected!")
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            imagePicker!.sourceType = UIImagePickerControllerSourceType.camera;
            imagePicker!.allowsEditing = false
            self.present(imagePicker!, animated: true, completion: nil)
            self.isFromCamera = true
        } else {
            print("No camera")
        }
    }
    
    func useCameraLibraryIsSelected(popup: ScanOrCameraPopupView) {
        scanOrCameraPopup.removeFromSuperview()
        imagePicker = UIImagePickerController()
        imagePicker?.delegate = self
        print("Library is selected")
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            print("Button capture")
            imagePicker!.sourceType = .savedPhotosAlbum;
            imagePicker!.allowsEditing = false
            self.present(imagePicker!, animated: true, completion: nil)
            self.isFromLibrary = true
        } else {
            print("No camera library")
        }
        
    }
    
    func scanBarcodeIsSelected(popup: ScanOrCameraPopupView) {
        print("Scan barcode is selected!")
        self.isFromCamera = false
        self.isFromLibrary = false
        self.setupScanner()
        self.scanOrCameraPopup.removeFromSuperview()
    }
    
    func continueIsSelected(popup: BookConfirmationPopupView) {
        print("Continuing!")
        performSegue(withIdentifier: "bookPostingSegue", sender: self)
    }
    
    func tryAgainIsSelected(popup: BookConfirmationPopupView) {
        print("try again!")
    }
    
    func editButtonIsSelected(popup: BookConfirmationPopupView) {
        if(self.saveChangesSelected){
            popup.editButton.titleLabel?.text = "Save"
            self.userCanEdit = true
            self.saveChangesSelected = false
        } else if (self.userCanEdit){
            popup.editButton.titleLabel?.text = "Edit"
            self.saveChangesSelected = true
            self.userCanEdit = false
        }
        
        self.toggleEditingTextFields(popup: popup)
    }
    
    func toggleEditingTextFields(popup : BookConfirmationPopupView){
        if(userCanEdit){
            popup.authorTextField.isUserInteractionEnabled = true
            popup.titleTextField.isUserInteractionEnabled = true
        } else {
            popup.authorTextField.isUserInteractionEnabled = false
            popup.titleTextField.isUserInteractionEnabled = false
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
