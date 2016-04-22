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
}

class ViewController: UIViewController {
    //Page Elements
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordConfirmationField: UITextField!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var loginText: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var switchViewButton: UIButton!
    @IBOutlet weak var haveAccountText: UILabel!
    var blueBackground = UIColor(red: 0, green: 128/255, blue: 1, alpha: 1.0)
    var purpleBackground = UIColor(red: 204/255, green: 102/255, blue: 1, alpha: 1.0)
    var redColor = UIColor(red: 1, green:0, blue: 0, alpha: 0.8)
    
    // Create a reference to a Firebase location
    var myRootRef = Firebase(url:"https://crackling-heat-1030.firebaseio.com/")
    
    
    
    //function which fades in the signup page
    func FadeInSignup() {
        UIView.animateWithDuration(1.5, animations: {
            self.view.backgroundColor =  self.purpleBackground
            self.switchViewButton.setTitle("Log In", forState: .Normal)
            self.loginButton.alpha = 0.0
            self.loginText.text = "Sign Up"
            self.haveAccountText.alpha = 0.0
            self.passwordConfirmationField.alpha = 1.0
            self.emailField.alpha = 1.0
            self.signupButton.alpha = 1.0
        })
        self.haveAccountText.alpha = 1.0
        self.haveAccountText.text = "Already Have an Account?"
       
    }
    
//    func ShowError(errorMessage: String, currentBackground: UIColor) {
//        self.errorLabel.text = errorMessage
//        self.errorLabel.textColor = self.redColor
//        UIView.animateWithDuration(1.5, animations: {
//            //self.errorLabel.textColor = currentBackground
//        })
//    }
    
    //function to fade in the login screen
    func FadeInLogin() {
        UIView.animateWithDuration(1.5, animations: {
            self.view.backgroundColor =  self.blueBackground
            self.loginText.text = "Login to make a shared playlist with friends."
            self.switchViewButton.setTitle("Sign Up", forState: .Normal)
            self.emailField.alpha = 1.0
            self.loginText.alpha = 1.0
            self.signupButton.alpha = 0.0
            self.loginButton.alpha = 1.0
            self.emailField.alpha = 0.0
            self.passwordConfirmationField.alpha = 0.0
            self.haveAccountText.text = "Don\'t Have an Account?"
        })
        
    }
    
    //locks orientation to portrait
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.hideKeyboardOnTap()
        //add listeners on text fields
        self.passwordConfirmationField.addTarget(self, action: #selector(ViewController.LoginFieldChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        self.passwordField.addTarget(self, action: #selector(ViewController.LoginFieldChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        self.usernameField.addTarget(self, action: #selector(ViewController.LoginFieldChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        self.emailField.addTarget(self, action: #selector(ViewController.LoginFieldChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
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
    func MakeTextFieldRed(sender:UITextField) {
        sender.layer.borderColor = self.redColor.CGColor
        sender.layer.borderWidth = 2
        sender.layer.cornerRadius = 5
    }
    func AbleToSignup (sender:UITextField) {
        sender.layer.borderWidth = 0
        if(emailField.text != "" && usernameField.text != "" && passwordField != "" && passwordConfirmationField != "") {
            self.signupButton.enabled = true
        }
        else {
            self.signupButton.enabled = false
        }
    }
    
    func LoginFieldChange(sender:UITextField){
        switch sender {
        case passwordConfirmationField, passwordField:
            if(passwordField.text != passwordConfirmationField.text) {
                MakeTextFieldRed(passwordConfirmationField)
                self.signupButton.enabled = false
            }
            else {
                passwordConfirmationField.layer.borderWidth = 0
                AbleToSignup(passwordConfirmationField)
            }
        case emailField:
            let after = emailField.text!.componentsSeparatedByString("@");
            let num = after.count - 1;
            var separators = [""]
            if(emailField.text == "" || num != 1) {
                MakeTextFieldRed(emailField)
            }
            else if (after[1] == "" || after[0] == ""){
                MakeTextFieldRed(emailField)
            }
            else if (after[1] != "") {
                separators = after[1].componentsSeparatedByString(".")
            }
            if (separators.count - 1 != 1){
                MakeTextFieldRed(emailField)
            }
            else if (separators[0] == "" || separators[1] == "") {
                MakeTextFieldRed(emailField)
            }
            else {
                AbleToSignup(emailField)
            }
        case usernameField:
            if(usernameField.text == "") {
                MakeTextFieldRed(usernameField)
            }
            else {
                AbleToSignup(usernameField)
            }
            
        default:
            break
        }
    }
    
    @IBAction func signupButtonPressed(sender: AnyObject) {
        myRootRef.createUser(self.emailField.text!, password: self.passwordField.text!,
                             withValueCompletionBlock: { error, result in
                                
                                if error != nil {
                                    // There was an error creating the account
                                } else {
                                    let uid = result["uid"] as? String
                                    print("Successfully created user account with uid: \(uid)")
//                                    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
//                                    let HomeViewController = storyBoard.instantiateViewControllerWithIdentifier("HomeViewController")
//                                    self.presentViewController(HomeViewController, animated:true, completion:nil)
                                }
        })
    }
}

