//
//  SettingsViewController.swift
//  Medley
//
//  Created by Nikolas Chaconas on 4/26/16.
//  Copyright © 2016 Medley Team. All rights reserved.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController {
    
    var myRootRef = Firebase(url:"https://crackling-heat-1030.firebaseio.com/")
    @IBOutlet weak var accountSettingsButton: UIButton!
    @IBOutlet weak var aboutButton: UIButton!
    @IBOutlet weak var supportButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    

    

    /*

     @IBOutlet weak var showAboutPopup: UIButton!
    @IBOutlet weak var newPasswordField: UITextField!
    @IBOutlet weak var oldPasswordField: UITextField!
    @IBOutlet weak var temporaryPasswordWarning: UILabel!
    @IBOutlet weak var successMessage: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    */
    
    /*
 
            change these, we need to make these global somewhere
 
    */
    var blueBackground = UIColor(red: 0, green: 128/255, blue: 1, alpha: 1.0)
    var purpleBackground = UIColor(red: 204/255, green: 102/255, blue: 1, alpha: 1.0)
    
    //Color for button borders
    let buttonBorderColor : UIColor = UIColor( red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 0.35)
    var redColor = UIColor(red: 1, green:0, blue: 0, alpha: 0.8)
    var greenColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0.8)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.hideKeyboardOnTap()
        
        //Give buttons nicer appearances
        self.aboutButton.layer.borderWidth = 1
        self.aboutButton.layer.borderColor = self.buttonBorderColor.CGColor
        self.aboutButton.layer.cornerRadius = 5
        self.accountSettingsButton.layer.borderWidth = 1
        self.accountSettingsButton.layer.borderColor = self.buttonBorderColor.CGColor
        self.accountSettingsButton.layer.cornerRadius = 5
        self.logoutButton.layer.borderWidth = 1
        self.logoutButton.layer.borderColor = self.buttonBorderColor.CGColor
        self.logoutButton.layer.cornerRadius = 5
        self.supportButton.layer.borderWidth = 1
        self.supportButton.layer.borderColor = self.buttonBorderColor.CGColor
        self.supportButton.layer.cornerRadius = 5
        
        
        /*
        if(self.IsPasswordTemporary()) {
            self.ShowWarning()
        }
        else {
            self.HideWarning()
        }
        self.HideSuccess()
        loadingIndicator.alpha = 0;
        */
    }
    
    @IBAction func showAboutPopup(sender: AnyObject) {
        let alertController = UIAlertController(title: "About Medley", message:
            "Medley is an app where you can join rooms with friends to listen to music and chat. \n\nMedley was first created by five students at the University of California, Santa Barbara in Spring 2016. \n\nWe hope you enjoy using our app!", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func showSupportPopup(sender: AnyObject) {
        var subject = ""
        var message = ""
        let alertController = UIAlertController(title: "Contact", message:
            "Send us a message and we'll contact you at your account email.", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
        alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: contactUs))
        
        alertController.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.textAlignment = NSTextAlignment .Center
            textField.placeholder = "Subject"
            subject = textField.text!
        })
        alertController.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.textAlignment = NSTextAlignment .Center
            textField.placeholder = "Message"
            message = textField.text!
        })
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func addTextField(textField: UITextField!) {
        textField.textAlignment = NSTextAlignment .Center
        textField.placeholder = "Room Code"

    }
    
    func contactUs(alert: UIAlertAction!){
        let alertController = UIAlertController(title: "Thank you!", message:
            "We will reply to your message as soon as possible! \n\nSorry if it takes a while, we're just a team of five college students.", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    func ShowSuccess() {
        self.successMessage.text = "Password Changed!"
    }
    
    func HideSuccess() {
        self.successMessage.text = ""
    }
    
    func ShowLoading() {
        loadingIndicator.alpha = 1.0
        loadingIndicator.startAnimating()
    }
    
    func HideLoading() {
        loadingIndicator.alpha = 0.0
    }
    
    func ShowWarning() {
        self.temporaryPasswordWarning.text = "You are using a temporary password, it will expire in the next 24 hours. Please change your password."
    }
    
    func HideWarning() {
        self.temporaryPasswordWarning.text = ""
    }
    
    func IsPasswordTemporary() -> Bool {
        return (self.GetCurrentUser(self.myRootRef).providerData["isTemporaryPassword"] as? Bool)!
    }
    
    func ValidField(field : UITextField) -> Bool {
        let valid = field.text != "" ? true : false
        if(!valid)  {
           self.MakeTextFieldRed(field, color:self.redColor)
        }
        return valid
    }
    
    @IBAction func changePasswordPressed(sender: AnyObject) {
        if(self.ValidField(self.newPasswordField) && self.ValidField(self.oldPasswordField)) {
            ShowLoading()
            self.myRootRef.changePasswordForUser(GetCurrentUserEmail(myRootRef), fromOld: self.oldPasswordField.text!,
                toNew: self.newPasswordField.text!, withCompletionBlock: { error in
                if error != nil {
                    self.HideLoading()
                } else {
                    self.HideLoading()
                    self.HideWarning()
                    self.ShowSuccess()
                }
            })
        }
    }
    */
    
}