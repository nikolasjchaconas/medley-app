//
//  ViewController.swift
//  Medley
//
//  Created by Joe Song on 4/16/16.
//  Copyright © 2016 Medley Team. All rights reserved.
//

import UIKit
import Firebase

extension UIViewController {
    func hideKeyboardOnTap() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.hideKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func hideKeyboard() {
        view.endEditing(true)
    }
    
    func GetCurrentUser(myRootRef : Firebase) -> FAuthData {
        return myRootRef.authData
        
    }
    
    func GetCurrentUserEmail(myRootRef : Firebase) -> String {
        return (GetCurrentUser(myRootRef).providerData["email"] as? String)!
    }
    
    func ReturnUsername(username : String) -> String {
        return username
    }
    
    
    func MakeTextFieldRed(sender:UITextField, color:UIColor) {
        sender.layer.borderColor = color.CGColor
        sender.layer.borderWidth = 2
        sender.layer.cornerRadius = 5
    }
}

class ViewController: UIViewController {
    //Page Elements
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var resetPasswordButton: UIButton!
    @IBOutlet weak var helpSigningInText: UILabel!
    @IBOutlet weak var loginErrorMessage: UILabel!
    @IBOutlet weak var signupErrorMessage: UILabel!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordConfirmationField: UITextField!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var loginText: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var loginSuccessMessage: UILabel!
    @IBOutlet weak var signupSuccessMessage: UILabel!
    @IBOutlet weak var switchViewButton: UIButton!
    @IBOutlet weak var haveAccountText: UILabel!
    var blueBackground = UIColor(red: 0, green: 128/255, blue: 1, alpha: 1.0)
    var purpleBackground = UIColor(red: 204/255, green: 102/255, blue: 1, alpha: 1.0)
    
    //Color for button borders
    let buttonBorderColor : UIColor = UIColor( red: 255, green: 255, blue: 255, alpha: 0.35)
    var redColor = UIColor(red: 1, green:0, blue: 0, alpha: 0.8)
    var greenColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0.8)
    // Create a reference to a Firebase location
    let myRootRef = Firebase(url:"https://crackling-heat-1030.firebaseio.com/")
    
    
    //function which fades in the signup page
    func FadeInSignup() {
        UIView.animateWithDuration(1.5, animations: {
            self.signupButton.enabled = false
            self.loginErrorMessage.text = ""
            self.view.backgroundColor =  self.purpleBackground
            self.switchViewButton.setTitle("Log In", forState: .Normal)
            self.loginButton.alpha = 0.0
            self.loginText.text = "Sign Up"
            self.haveAccountText.alpha = 0.0
            self.passwordConfirmationField.alpha = 1.0
            self.usernameField.alpha = 1.0
            self.signupButton.alpha = 1.0
            self.resetPasswordButton.alpha = 0.0
            self.helpSigningInText.text = ""
            self.emailField.text = ""
            self.passwordField.text = ""
        })
        self.haveAccountText.alpha = 1.0
        self.haveAccountText.text = "Already Have an Account?"
        HideMessages()
       
    }
    
    func ShowError(errorMessage: String, label: UILabel) {
        self.HideMessages()
        label.text = errorMessage
        label.textColor = self.redColor
    }
    
    func HideMessages() {
        loginSuccessMessage.text = ""
        loginErrorMessage.text = ""
        signupSuccessMessage.text = ""
        signupErrorMessage.text = ""
    }
    
    func ShowSuccess(successMessage: String, label: UILabel) {
        self.HideMessages()
        label.text = successMessage
        label.textColor = self.greenColor
    }
    
    //function to fade in the login screen
    func FadeInLogin() {
        UIView.animateWithDuration(1.5, animations: {
            self.loginButton.enabled = false
            self.view.backgroundColor =  self.blueBackground
            self.loginText.text = "Login to make a shared playlist with friends."
            self.switchViewButton.setTitle("Sign Up", forState: .Normal)
            self.loginText.alpha = 1.0
            self.signupButton.alpha = 0.0
            self.loginButton.alpha = 1.0
            self.usernameField.alpha = 0.0
            self.passwordConfirmationField.alpha = 0.0
            self.resetPasswordButton.alpha = 1.0
            self.haveAccountText.text = "Don\'t Have an Account?"
            self.usernameField.text = ""
            self.emailField.text = ""
            self.passwordField.text = ""
            self.passwordConfirmationField.text = ""
        })
        self.helpSigningInText.text = "Need Help Signing in?"
        self.HideMessages()
    }
    
    //locks orientation to portrait
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.hideKeyboardOnTap()
        // Make login and signup buttons rounded
        loginButton.layer.cornerRadius = 5
        signupButton.layer.cornerRadius = 5
        
        // Make login and signup buttons have a slight border
        loginButton.layer.borderWidth = 1
        loginButton.layer.borderColor = buttonBorderColor.CGColor
        signupButton.layer.borderWidth = 1
        signupButton.layer.borderColor = buttonBorderColor.CGColor
        
        //add listeners on text fields
        self.passwordConfirmationField.addTarget(self, action: #selector(ViewController.LoginFieldChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        self.passwordField.addTarget(self, action: #selector(ViewController.LoginFieldChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        self.usernameField.addTarget(self, action: #selector(ViewController.LoginFieldChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        self.emailField.addTarget(self, action: #selector(ViewController.LoginFieldChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        self.loginButton.enabled = false
        self.signupButton.enabled = false
        
        //iphone 4S stuff
        if UIDevice.currentDevice().model == "iPhone4,1" {
            helpSigningInText.text = UIDevice.currentDevice().model
            helpSigningInText.font = helpSigningInText.font.fontWithSize(11)
            resetPasswordButton.titleLabel!.font =  UIFont.systemFontOfSize(12)
            haveAccountText.font = haveAccountText.font.fontWithSize(11)
            switchViewButton.titleLabel!.font = UIFont.boldSystemFontOfSize(12)
        }
        
        self.hideLoading()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //Action to take when at bottom of view is pressed
    @IBAction func switchViewButtonPressed(sender: AnyObject) {
        emailField.layer.borderWidth = 0
        usernameField.layer.borderWidth = 0
        passwordField.layer.borderWidth = 0
        passwordConfirmationField.layer.borderWidth = 0
        if switchViewButton.titleLabel!.text == "Sign Up" {
            FadeInSignup()
        }
        else {
            FadeInLogin()
        }
    }
    
    
    func isRed(sender:UITextField) -> Bool {
        let output = sender.layer.borderWidth == 2 ? true : false
        return output;
    }
    
    func validEmail(emailField:UITextField) -> Bool {
        let after = emailField.text!.componentsSeparatedByString("@")
        let num = after.count - 1
        var separators = [""]
        if(emailField.text == "" || num != 1) {
            return false
        }
        else if (after[1] == "" || after[0] == ""){
            return false
        }
        else if (after[1] != "") {
            separators = after[1].componentsSeparatedByString(".")
        }
        if (separators.count < 2){
            return false
        }
        else if (separators[0] == "" || separators[1] == "") {
            return false
        }
        else {
            return true
        }
    }
    
    func AbleToSignup (sender:UITextField) {
        sender.layer.borderWidth = 0
        if(emailField.text != "" && usernameField.text != "" && passwordField != "" && passwordConfirmationField != "") {
            if(!isRed(emailField) && !isRed(usernameField) && !isRed(passwordField) && !isRed(passwordConfirmationField)){
                self.signupButton.enabled = true
            }
        }
        else {
            self.signupButton.enabled = false
        }
    }
    
    func AbleToLogin (sender:UITextField) {
        sender.layer.borderWidth = 0
        if(emailField.text != "" && passwordField.text != "") {
            if(!isRed(emailField) && !isRed(passwordField)){
                self.loginButton.enabled = true
            }
        }
        else {
            self.loginButton.enabled = false
        }
    }
    
    func LoginFieldChange(sender:UITextField){
        switch sender {
        //validations for passwordConfirmationField
        case passwordConfirmationField:
            if(passwordField.text == "") {
                MakeTextFieldRed(passwordField, color:self.redColor)
            }

            else if(passwordField.text != passwordConfirmationField.text && passwordField.text?.characters.count >= 7) {
                MakeTextFieldRed(passwordConfirmationField, color: self.redColor)
                self.ShowError("Passwords do not match", label: self.signupErrorMessage)
            }
            else if(passwordField.text != passwordConfirmationField.text && passwordField.text?.characters.count < 7) {
                MakeTextFieldRed(passwordConfirmationField, color: self.redColor)
            }
            else if(passwordField.text?.characters.count < 7 && passwordField.text == passwordConfirmationField.text){
                AbleToSignup(passwordConfirmationField)
            }
            else {
                AbleToLogin(sender)
                AbleToSignup(passwordConfirmationField)
                AbleToSignup(passwordField)
                self.HideMessages()
            }
            break
            
        //validations for passwordField
        case passwordField:
            if(passwordField.text?.characters.count < 7){
                MakeTextFieldRed(passwordField, color: self.redColor)
                self.ShowError("Please make password at least 7 characters", label: self.signupErrorMessage)
            }
            else if(passwordField.text != passwordConfirmationField.text && passwordField.text?.characters.count < 7) {
                MakeTextFieldRed(passwordConfirmationField, color: self.redColor)
            }
            else if(passwordField.text != passwordConfirmationField.text && passwordField.text?.characters.count >= 7 && passwordConfirmationField.text != "") {
                AbleToSignup(passwordField)
                MakeTextFieldRed(passwordConfirmationField, color: self.redColor)
                self.ShowError("Passwords do not match", label: self.signupErrorMessage)
            }

            else if(passwordField.text?.characters.count < 7 && passwordField.text == passwordConfirmationField.text){
                AbleToSignup(passwordConfirmationField)
            }
            else {
                self.HideMessages()
                AbleToSignup(passwordField)
                AbleToLogin(passwordConfirmationField)

            }
            break
            
        //validations for emailField
        case emailField:
            if (!validEmail(emailField)){
                MakeTextFieldRed(emailField, color:self.redColor)
            }
            else {
                AbleToLogin(emailField)
                AbleToSignup(emailField)
            }
            break
            
        //add validations for usernamefield
        case usernameField:

            if(usernameField.text == "") {
                MakeTextFieldRed(usernameField, color:self.redColor)
            }
            else if(usernameField.text != ""){
                myRootRef.childByAppendingPath("usernames")
                    .childByAppendingPath(usernameField.text?.lowercaseString).observeSingleEventOfType(.Value, withBlock: { snapshot in
                    if(!(snapshot.value is NSNull)){
                        self.MakeTextFieldRed(self.usernameField, color: self.redColor)
                        self.ShowError("Username is taken.", label: self.signupErrorMessage)
                    }
                    else {
                        self.HideMessages()
                        self.AbleToSignup(self.usernameField)
                    }
                })

            }

            else {
                
                AbleToSignup(usernameField)
            }
            break
            
        default:
            break
        }
    }
    
    func showLoading() {
        loginButton.enabled = false
        signupButton.enabled = false
        switchViewButton.enabled = false
        emailField.enabled = false
        usernameField.enabled = false
        passwordField.enabled = false
        passwordConfirmationField.enabled = false
        resetPasswordButton.enabled = false
        loadingIndicator.alpha = 1.0
        loadingIndicator.startAnimating()
        
    }
    
    func hideLoading() {
        switchViewButton.enabled = true
        loginButton.enabled = true
        signupButton.enabled = true
        emailField.enabled = true
        usernameField.enabled = true
        passwordField.enabled = true
        resetPasswordButton.enabled = true
        passwordConfirmationField.enabled = true
        loadingIndicator.stopAnimating()
        loadingIndicator.alpha = 0.0
    }
    
    @IBAction func loginButtonPressed(sender: AnyObject) {
        self.hideKeyboard()
        self.showLoading()
        self.HideMessages()
        myRootRef.authUser(self.emailField.text!, password: self.passwordField.text!,
                     withCompletionBlock: { error, authData in
                        if error != nil {
                            // There was an error logging in to this account
                            self.hideLoading()
                            self.ShowError("Incorrect Username/Password.", label: self.loginErrorMessage)
                        } else {
                            self.hideLoading()
                            // We are now logged in
                            self.performSegueWithIdentifier("HomeViewController", sender:sender)
                        }
        })
    }
    
    @IBAction func signupButtonPressed(sender: AnyObject) {
        self.hideKeyboard()
        self.showLoading()
        self.HideMessages()
        myRootRef.createUser(self.emailField.text!, password: self.passwordField.text!,
                             withValueCompletionBlock: { error, result in
                                
                                if error != nil {
                                    //add error conditions from https://www.firebase.com/docs/ios/guide/user-auth.html#section-storing
<<<<<<< HEAD
                                    switch(error){
                                        case "EMAIL_TAKEN":
                                            self.ShowError("Email is already in use.", label:self.signupErrorMessage)
                                            break
                                        default:
                                            self.ShowError("Could not connect.", label:self.signupErrorMessage)
                                            break
                                    }
=======
                                    self.hideLoading()
>>>>>>> 47e03b22856fd48688a661ebd5dc5a58c312f94e
                                    self.ShowError("Error creating account!", label: self.signupErrorMessage)
                                } else {
                                    //let uid = result["uid"] as? String
                                    self.hideLoading()
                                    self.FirstSignIn()
                                }
        })
    }
    
    func FirstSignIn() {
        self.myRootRef.authUser(self.emailField.text!, password: self.passwordField.text!) {
            error, authData in
            if error != nil {
                // Something went wrong. :(
            } else {
                let newUser = [
                    "username": (self.usernameField.text?.lowercaseString)!
                ]
                let userID = [
                    "id": authData.uid
                ]
                // Create a child path with a key set to the uid underneath the "users" node
                // This creates a URL path like the following:
                //  - https://<YOUR-FIREBASE-APP>.firebaseio.com/users/<uid>
                self.myRootRef.childByAppendingPath("users")
                    .childByAppendingPath(authData.uid).setValue(newUser)
                self.myRootRef.childByAppendingPath("usernames")
                    .childByAppendingPath(self.usernameField.text?.lowercaseString).setValue(userID)
                self.performSegueWithIdentifier("HomeViewController", sender:self)
            }
        }
    }
    
    func sendRecoveryEmail (alert: UIAlertAction!) {
        showLoading()
        myRootRef.resetPasswordForUser(emailField.text!, withCompletionBlock: { error in
            if error != nil {
                self.hideLoading()
                self.ShowError("Email Does not Exist", label: self.loginErrorMessage)
            } else {
                self.hideLoading()
                self.ShowSuccess("Password Recovery Email Sent", label: self.loginErrorMessage)
                // Password reset sent successfully
            }
        })
    }
    
    func ShowPasswordChangeAlert() {
        let alertController = UIAlertController(title: "Reset Password", message:
            "A recovery password will be sent to " + emailField.text!, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: sendRecoveryEmail))
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func IsPasswordTemporary() -> Bool {
        return (self.GetCurrentUser(self.myRootRef).providerData["isTemporaryPassword"] as? Bool)!
    }
    
    @IBAction func resetPasswordButtonPressed(sender: AnyObject) {
        self.hideKeyboard()
        if(validEmail(self.emailField)) {
            ShowPasswordChangeAlert()
        }
        else {
            MakeTextFieldRed(self.emailField, color:self.redColor)
        }
        
    }

}

