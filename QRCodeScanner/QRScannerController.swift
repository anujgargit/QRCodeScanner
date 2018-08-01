//
//  QRScannerController.swift
//  QRCodeReader
//
//  Created by Simon Ng on 13/10/2016.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData

class QRScannerController: UIViewController,AVCaptureMetadataOutputObjectsDelegate {
    var captureSession:AVCaptureSession!
    var videoPreviewLayer:AVCaptureVideoPreviewLayer!
    var qrCodeFrameView:UIView?
     var dataArray = [FileDataModel]()
    var exist:Bool = false
    @IBOutlet var messageLabel:UILabel!
    @IBOutlet var topbar: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        SaveData(sportdate: "7 July", id: "123", intime: "2", outtime: "3")
//        self.GetDateandTime(id: "1")
        // Get the back-facing camera for capturing videos
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.frame = view.layer.bounds
        videoPreviewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(videoPreviewLayer)
        
        captureSession.startRunning()
        // Initialize QR Code Frame to highlight the QR code
        qrCodeFrameView = UIView()
        
        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
            qrCodeFrameView.layer.borderWidth = 2
            view.addSubview(qrCodeFrameView)
            view.bringSubview(toFront: qrCodeFrameView)
        }
        // Move the message label and top bar to the front
        view.bringSubview(toFront: messageLabel)
        view.bringSubview(toFront: topbar)

        // Do any additional setup after loading the view.
    }
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            messageLabel.text = "No QR code is detected"
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                messageLabel.text = metadataObj.stringValue
                for item in dataArray{
                    if item.id == metadataObj.stringValue{
                        exist = true
                    }
                }
                if exist == false{
                 let obj = FileDataModel()
                obj.id = metadataObj.stringValue!
                dataArray.append(obj)
                self.GetDateandTime(id: metadataObj.stringValue!)
                }
                else{
                    exist = false
                   self.GetDateandTime(id: metadataObj.stringValue!)
                }
            }
        }
    }
    func GetDateandTime(id:String) {
        //Date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let dateString = dateFormatter.string(from: Date() as Date)
        UserDefaults.standard.set(dateString, forKey: "Date")
        //        labelfordate.text = String(dateString)
        
        
        //Time
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        dateFormatter.dateFormat = "h:mm:ss a"
        let timeString = timeFormatter.string(from: Date() as Date)
        let arr = timeString.components(separatedBy: " ")
        let time = arr[0]
        UserDefaults.standard.set(time, forKey: "LoginTime")
        //        labelfortime.text = String(timeString)
        for item in dataArray{
            if item.id == id {
                if item.isLogin == true  {
                    item.logouttime = String(timeString)
                    self.SaveData(sportdate:item.date,id: item.id, intime: item.logintime, outtime: item.logouttime)
                    item.logintime = ""
                    item.logouttime = ""
                    item.isLogin = false
                }
                else if item.isLogin == false {
                   item.logintime = String(timeString)
                     item.date =  String(dateString)
                    item.isLogin = true
                }
            
            }
        }
        
    }
    func SaveData(sportdate:String,id:String,intime:String,outtime:String){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Report", in: context)
        let newUser = NSManagedObject(entity: entity!, insertInto: context)
        newUser.setValue(id, forKey: "id")
        newUser.setValue(intime, forKey: "logintime")
        newUser.setValue(outtime, forKey: "logouttime")
        newUser.setValue(sportdate, forKey: "date")
//        newUser.setValue("123", forKey: "id")
//        newUser.setValue("2", forKey: "logintime")
//        newUser.setValue("3", forKey: "logouttime")
//        newUser.setValue("7 july", forKey: "date")
        do {
            try context.save()
            
        } catch {
            print("Failed saving")
        }
    }
    func FetchData(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Report")
        //request.predicate = NSPredicate(format: "age = %@", "12")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            print(result.count)
            for data in result as! [NSManagedObject] {
               let id = data.value(forKey: "id") as! String
               let intime = data.value(forKey: "logintime") as! String
                let outtime = data.value(forKey: "logouttime") as! String
                let date = data.value(forKey: "date") as! String
            }
        }
        catch {
            
            print("Failed")
        }
    }
    
}
