//
//  AccountViewController.swift
//  Medley
//
//  Created by Joe Song on 5/6/16.
//  Copyright © 2016 Medley Team.

import UIKit
import Firebase

class AccountViewController: UIViewController {
    
    var myRootRef = Firebase(url:"https://crackling-heat-1030.firebaseio.com/")
     
     @IBOutlet weak var newPasswordField: UITextField!
    @IBOutlet weak var accountHeader: UILabel!
     @IBOutlet weak var oldPasswordField: UITextField!
     @IBOutlet weak var temporaryPasswordWarning: UILabel!
     @IBOutlet weak var updateInfoButton: UIButton!
     @IBOutlet weak var successMessage: UILabel!
     @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    /*
     
     change these, we need to make these global somewhere
     
     */
    var blueBackground = UIColor(red: 0, green: 128/255, blue: 1, alpha: 1.0)
    var purpleBackground = UIColor(red: 204/255, green: 102/255, blue: 1, alpha: 1.0)
    
    //Color for button borders
    let buttonBorderColor : UIColor = UIColor( red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 0.35)
    let buttonShadowColor : UIColor = UIColor( red: 20/255.0, green: 20/255.0, blue: 20/255.0, alpha: 1.0)
    var redColor = UIColor(red: 1, green:0, blue: 0, alpha: 0.8)
    var greenColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0.8)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.hideKeyboardOnTap()
        
        //Stylize update info button
        self.updateInfoButton.layer.cornerRadius = 5
        self.updateInfoButton.layer.borderColor = self.buttonBorderColor.CGColor
        self.updateInfoButton.layer.borderWidth = 1
        
        // Add shadow to account header, success message, and warning message
        self.accountHeader.layer.shadowColor = buttonShadowColor.CGColor
        self.accountHeader.layer.shadowOffset = CGSizeMake(0, 6)
        self.accountHeader.layer.shadowRadius = 3.0
        self.accountHeader.layer.shadowOpacity = 1.0
        self.temporaryPasswordWarning.layer.shadowColor = buttonShadowColor.CGColor
        self.temporaryPasswordWarning.layer.shadowOffset = CGSizeMake(0, 2)
        self.temporaryPasswordWarning.layer.shadowRadius = 1.0
        self.temporaryPasswordWarning.layer.shadowOpacity = 1.0
        self.successMessage.layer.shadowColor = buttonShadowColor.CGColor
        self.successMessage.layer.shadowOffset = CGSizeMake(0, 2)
        self.successMessage.layer.shadowRadius = 1.0
        self.successMessage.layer.shadowOpacity = 1.0
        
         if(self.IsPasswordTemporary()) {
            self.ShowWarning()
         }
         else {
            self.HideWarning()
         }
         self.HideSuccess()
         loadingIndicator.alpha = 0;
    }
     
     override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
     }
     
     
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
        self.ShowSuccess()
     }
     
    
    
}