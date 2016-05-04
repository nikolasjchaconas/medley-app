//
//  SupportViewController.swift
//  Medley
//
//  Created by Joe Song on 5/2/16.
//  Copyright © 2016 Medley Team. All rights reserved.
//

import UIKit
import Firebase
import MessageUI

class SupportViewController: UIViewController, UITextViewDelegate, MFMailComposeViewControllerDelegate {
    
    var myRootRef = Firebase(url:"https://crackling-heat-1030.firebaseio.com/")
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageBox: UITextView!
    @IBOutlet weak var subjectBox: UITextField!
    
    let buttonBorderColor : UIColor = UIColor( red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 0.35)
    let placeholderColor : UIColor = UIColor( red: 199/255.0, green: 199/255.0, blue: 205/255.0, alpha: 1)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Stylize send button
        self.sendButton.layer.cornerRadius = 5
        self.sendButton.layer.borderColor = self.buttonBorderColor.CGColor
        self.sendButton.layer.borderWidth = 1
        //Stylize message box
        self.messageBox.layer.cornerRadius = 5
        self.messageBox.text = "Message..."
        self.messageBox.textColor = self.placeholderColor
        self.messageBox.layer.borderWidth = 1
        self.messageBox.layer.borderColor = self.buttonBorderColor.CGColor
        
        //Disable button by default
        self.sendButton.enabled = false
        
        //Create message box listener
        messageBox.delegate = self
        
        self.hideKeyboardOnTap()
    }
    
    func textViewDidBeginEditing(messageBox: UITextView){
        if(messageBox.textColor == self.placeholderColor){
            messageBox.text = nil
            messageBox.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidEndEditing(messageBox: UITextView){
        if (messageBox.text.isEmpty){
            messageBox.text = "Message..."
            messageBox.textColor = self.placeholderColor
        }
        else if (!(messageBox.text.isEmpty) && !(subjectBox.text?.isEmpty)!){
            self.sendButton.enabled = true
        }
    }
    
    //Code from http://stackoverflow.com/questions/28963514/sending-email-with-swift
    func configuredMailComposeViewController() -> MFMailComposeViewController{
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setToRecipients(["medleymusicapp@gmail.com"])
        mailComposerVC.setSubject(self.subjectBox.text!)
        mailComposerVC.setMessageBody(self.messageBox.text!, isHTML: false)
        
        return mailComposerVC
    }
    
    @IBAction func sendButtonPressed(sender: AnyObject) {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.presentViewController(mailComposeViewController, animated: true, completion: self.mailSent)
        } else{
          self.showSendMailError()
        }
    }
    
    func mailSent(){
        self.messageBox.text = "Message..."
        self.messageBox.textColor = self.placeholderColor
        self.subjectBox.text = nil
    }
    
    func showSendMailError(){
        let mailErrorAlert = UIAlertController(title: "Error", message: "Your device could not send the email. Please check email configuration and try again", preferredStyle: UIAlertControllerStyle.Alert)
        mailErrorAlert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default , handler: nil))
        self.presentViewController(mailErrorAlert, animated: true, completion: nil)
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}