//
//  QRCodeViewController.swift
//  QRCodeReader
//
//  Created by Simon Ng on 13/10/2016.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit
import CoreData
import MessageUI

class QRCodeViewController: UIViewController,MFMailComposeViewControllerDelegate {
    
    var fileName:String! = nil
    var path:URL! = nil
    var csvText:String!
    override func viewDidLoad() {
    super.viewDidLoad()
     self.creatCSV()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    @IBAction func unwindToHomeScreen(segue: UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func GenerateReport(_ sender: UIButton) {
        self.FetchData()
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
                let newLine = "\(date),\(id),\(intime),\(outtime)\n"
                csvText.append(newLine)
            }
            do {
                try csvText.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
                if MFMailComposeViewController.canSendMail() {
                    let emailController = MFMailComposeViewController()
                    emailController.mailComposeDelegate = self
                    emailController.setToRecipients([])
                    emailController.setSubject("Sport data export")
                    emailController.setMessageBody("Hi,\n\nThe .csv data export is attached", isHTML: false)
                    
                    emailController.addAttachmentData(try NSData(contentsOf: path) as Data, mimeType: "text/csv", fileName: fileName)
                    
                    self.navigationController?.present(emailController, animated: true, completion: nil)
                }
            } catch {
                print("Failed to create file")
                print("\(error)")
            }
        }
        catch {
            
            print("Failed")
        }
    }
    func creatCSV() -> Void {
         fileName = "Report.csv"
         path = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]).appendingPathComponent(fileName)
         csvText = "Date,ID,In Time,Out Time\n"
        print(path)
    }
    func GenerateReport(){
        
    }
    private func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismiss(animated: true, completion: nil)
    }

}
