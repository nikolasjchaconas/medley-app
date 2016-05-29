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
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var accountHeader: UILabel!
    @IBOutlet weak var oldPasswordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var temporaryPasswordWarning: UILabel!
    @IBOutlet weak var incorrectPasswordWarning: UILabel!
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

    let purpleGrad = CAGradientLayer().purpleGradient()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.hideKeyboardOnTap()
        
        //Add purple gradient
        self.purpleGrad.frame = self.view.bounds
        self.view.layer.addSublayer(purpleGrad)
        
        // Round edges of update info button
        self.updateInfoButton.layer.cornerRadius = 5
        self.updateInfoButton.layer.borderColor = self.buttonBorderColor.CGColor
        self.updateInfoButton.layer.borderWidth = 1
        
        // Add shadow to account header
        self.accountHeader.layer.shadowColor = buttonShadowColor.CGColor
        self.accountHeader.layer.shadowOffset = CGSizeMake(0, 3)
        self.accountHeader.layer.shadowRadius = 1.0
        self.accountHeader.layer.shadowOpacity = 1.0
        
        // Add listeners to text fields
//        self.confirmPasswordField.addTarget(self, action: #selector(ViewController.LoginFieldChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
//        self.newPasswordField.addTarget(self, action: #selector(ViewController.LoginFieldChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
//        self.oldPasswordField.addTarget(self, action: #selector(ViewController.LoginFieldChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
//        self.emailField.addTarget(self, action: #selector(ViewController.LoginFieldChange(_:)), forControlEvents: UIControlEvents.EditingDidEnd)
        
        if(self.IsPasswordTemporary()) {
            self.ShowWarning()
        }
        else {
            self.HideWarning()
        }
        self.HideSuccess()
        self.hideIncorrectPassword()
        self.emailField.text = GetCurrentUserEmail(myRootRef)
        
        loadingIndicator.alpha = 0;
    }
     
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//     func AbleToSignup (sender:UITextField) {
//         sender.layer.borderWidth = 0
//         if(oldPasswordField == ) {
//             if(!isRed(emailField) && !isRed(usernameField) && !isRed(passwordField) && !isRed(passwordConfirmationField)){
//                 self.updateInfoButton.enabled = true
//             }
//         }
//         else {
//             self.updateInfoButton.enabled = false
//         }
//     }
    
    func ShowSuccess() {
        self.successMessage.text = "Password Changed!"
    }
     
    func HideSuccess() {
        self.successMessage.text = ""
    }

    func hideIncorrectPassword(){
        self.incorrectPasswordWarning.text = ""
    }

    func showIncorrectPassword(){
        self.incorrectPasswordWarning.text = "Incorrect Password"
    }
    
    func showPasswordMismatch(){
        self.incorrectPasswordWarning.text = "New passwords do not match"
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
    
    func validEmail(emailField:UITextField) -> Bool {
        let after = emailField.text!.componentsSeparatedByString("@")
        let num = after.count - 1
        var separators = [""]
        if(emailField.text == "" || num != 1) {
            self.MakeTextFieldRed(emailField, color:self.redColor)
            return false
        }
        else if (after[1] == "" || after[0] == ""){
            self.MakeTextFieldRed(emailField, color:self.redColor)
            return false
        }
        else if (after[1] != "") {
            separators = after[1].componentsSeparatedByString(".")
        }
        if (separators.count < 2){
            self.MakeTextFieldRed(emailField, color:self.redColor)
            return false
        }
        else if (separators[0] == "" || separators[1] == "") {
            self.MakeTextFieldRed(emailField, color:self.redColor)
            return false
        }
        else {
            return true
        }
    }
    
    @IBAction func updateInfoPressed(sender: AnyObject) {
        self.hideKeyboard()
        self.HideSuccess()
        self.ShowLoading()
        
        if(self.ValidField(self.oldPasswordField)){
            if(self.newPasswordField.text != "" && self.confirmPasswordField.text != ""){
                if(self.confirmPasswordField.text != self.newPasswordField.text){
                    self.showPasswordMismatch()
                }
                else{
                    self.myRootRef.changePasswordForUser(GetCurrentUserEmail(myRootRef), fromOld: self.oldPasswordField.text!, toNew: self.newPasswordField.text!, withCompletionBlock: { error in
                        if error != nil{
                            self.HideLoading()
                            self.showIncorrectPassword()
                        }
                        else{
                            self.hideIncorrectPassword()
                            self.HideLoading()
                            self.HideWarning()
                            self.ShowSuccess()
                        }
                    })
                }
            }

        }
        self.HideLoading()
    }
    
    override func MakeTextFieldRed(sender:UITextField, color:UIColor) {
        sender.layer.borderColor = color.CGColor
        sender.layer.borderWidth = 2
        sender.layer.cornerRadius = 5
    }
    
    
    
}