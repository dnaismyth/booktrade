//
//  ScanViewController.swift
//  booktrader
//
//  Created by Dayna Naismyth on 2017-03-22.
//  Copyright © 2017 Dayna Naismyth. All rights reserved.
//

import UIKit
import AVFoundation

class ScanViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, ScanOrCameraPopupViewDelegate, BookConfirmationPopupViewDelegate {
    
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
        //self.setupScanner()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            self.largeImageUrl = (dictionary.value(forKey: "image_url") as! String?)!
            self.smallImageUrl = dictionary.value(forKey: "small_image_url") as! String?
            self.bookSource = Constants.BOOKSOURCE.goodreads
            if(self.largeImageUrl != nil){
                self.setBookImage(imageUrl: self.largeImageUrl!)
            } else {
                // set default image
                self.showBookConfirmationPopup()
            }
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
            let bookPostingView = segue.destination as! BookPostingViewController
            bookPostingView.titleHolder = self.bookConfirmationPopup.bookTitle.text
            bookPostingView.authorHolder = self.bookConfirmationPopup.authorLabel.text
            bookPostingView.mainImageUrl = self.largeImageUrl   // main, larger image
            bookPostingView.tmbImageUrl = self.smallImageUrl // thumbnail image
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
        self.bookConfirmationPopup.authorLabel.text = self.author
        self.bookConfirmationPopup.bookTitle.text = self.bookTitle
        if(self.coverImage != nil){
            self.bookConfirmationPopup.coverImage.image = self.coverImage!
        }
        self.bookConfirmationPopup.delegate = self
        self.view.addSubview(self.bookConfirmationPopup)
    }
    
    func useCameraIsSelected(popup: ScanOrCameraPopupView) {
        print("Camera is selected!")
        //TODO Show camera.
    }
    
    func scanBarcodeIsSelected(popup: ScanOrCameraPopupView) {
        print("Scan barcode is selected!")
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
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
