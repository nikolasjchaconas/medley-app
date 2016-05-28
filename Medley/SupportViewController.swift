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
    @IBOutlet weak var supportHeader: UILabel!
    @IBOutlet weak var supportMessage: UILabel!
    @IBOutlet weak var messageBox: UITextView!
    @IBOutlet weak var subjectBox: UITextField!
    @IBOutlet weak var successText: UILabel!
    
    let buttonBorderColor : UIColor = UIColor( red: 200/255.0, green: 200/255.0, blue: 200/255.0, alpha: 0.35)
    let buttonShadowColor : UIColor = UIColor( red: 20/255.0, green: 20/255.0, blue: 20/255.0, alpha: 1.0)
    let placeholderColor : UIColor = UIColor( red: 199/255.0, green: 199/255.0, blue: 205/255.0, alpha: 1)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Add shadow to about header message, support info text, and success text
        self.supportHeader.layer.shadowColor = buttonShadowColor.CGColor
        self.supportHeader.layer.shadowOffset = CGSizeMake(0, 6)
        self.supportHeader.layer.shadowRadius = 3.0
        self.supportHeader.layer.shadowOpacity = 1.0
        self.supportMessage.layer.shadowColor = buttonShadowColor.CGColor
        self.supportMessage.layer.shadowOffset = CGSizeMake(0, 2)
        self.supportMessage.layer.shadowRadius = 1.0
        self.supportMessage.layer.shadowOpacity = 1.0
        self.successText.layer.shadowColor = buttonShadowColor.CGColor
        self.successText.layer.shadowOffset = CGSizeMake(0, 2)
        self.successText.layer.shadowRadius = 1.0
        self.successText.layer.shadowOpacity = 1.0
        
        // Round send button corners
        self.sendButton.layer.cornerRadius = 5
        self.sendButton.layer.borderColor = self.buttonBorderColor.CGColor
        self.sendButton.layer.borderWidth = 1
        
        //Put shadow on send button
        self.sendButton.layer.shadowColor = self.buttonShadowColor.CGColor
        self.sendButton.layer.shadowOpacity = 1.0
        self.sendButton.layer.shadowRadius = 1.0
        self.sendButton.layer.shadowOffset = CGSizeMake(0, 3)
        
        //Stylize message box
        self.messageBox.layer.cornerRadius = 5
        self.messageBox.text = "Message..."
        self.messageBox.textColor = self.placeholderColor
        self.messageBox.layer.borderWidth = 1
        self.messageBox.layer.borderColor = self.buttonBorderColor.CGColor
        
        //Disable button by default
        self.sendButton.enabled = false
        
        //Hide success text by default
        self.successText.hidden = true
        
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
            self.presentViewController(mailComposeViewController, animated: true, completion: nil)
        } else{
          self.showSendMailError()
        }
    }
    
    func mailSent(){
        self.messageBox.text = "Message..."
        self.messageBox.textColor = self.placeholderColor
        self.subjectBox.text = nil
        self.successText.hidden = false
    }
    
    func showSendMailError(){
        let mailErrorAlert = UIAlertController(title: "Error", message: "Your device could not send the email. Please check email configuration and try again", preferredStyle: UIAlertControllerStyle.Alert)
        mailErrorAlert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default , handler: nil))
        self.presentViewController(mailErrorAlert, animated: true, completion: nil)
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        if (result == MFMailComposeResultSent){
            controller.dismissViewControllerAnimated(true, completion: self.mailSent)
        }
        else{
            controller.dismissViewControllerAnimated(true, completion: nil)
        }

        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}