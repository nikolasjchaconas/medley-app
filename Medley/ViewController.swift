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
        self.passwordConfirmationField.addTarget(self, action: #selector(ViewController.LoginFieldChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        self.passwordField.addTarget(self, action: #selector(ViewController.LoginFieldChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //Action to take when at bottom of view is pressed
    @IBAction func switchViewButtonPressed(sender: AnyObject) {
        if switchViewButton.titleLabel!.text == "Sign Up" {
            FadeInSignup()
        }
        else {
            FadeInLogin()
        }
    }
    //
    func LoginFieldChange(sender:UITextField){
        switch sender {
        case passwordConfirmationField, passwordField:
            if(passwordField.text != passwordConfirmationField.text) {
                passwordConfirmationField.layer.borderColor = self.redColor.CGColor
                passwordConfirmationField.layer.borderWidth = 2
                passwordConfirmationField.layer.cornerRadius = 5
            }
            else {
                passwordConfirmationField.layer.borderWidth = 0
            }
            
        default:
            break
        }
    }
    
    @IBAction func signupButtonPressed(sender: AnyObject) {
        
    }
}

