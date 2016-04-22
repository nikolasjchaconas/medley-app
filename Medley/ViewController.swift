//
//  ViewController.swift
//  Medley
//
//  Created by Joe Song on 4/16/16.
//  Copyright © 2016 Medley Team. All rights reserved.
//

import UIKit

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
    @IBOutlet weak var passwordConfirmationField: UITextField!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var loginText: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var switchViewButton: UIButton!
    @IBOutlet weak var HaveAccountText: UILabel!
    var blueBackground = UIColor(red: 0, green: 128/255, blue: 1, alpha: 1.0)
    var purpleBackground = UIColor(red: 204/255, green: 102/255, blue: 1, alpha: 1.0)
    //Color for button borders
    let buttonBorderColor : UIColor = UIColor( red: 255, green: 255, blue: 255, alpha: 0.35)
    
    //function which fades in the signup page
    func FadeInSignup() {
        UIView.animateWithDuration(1.5, animations: {
            self.view.backgroundColor =  self.purpleBackground
            self.switchViewButton.setTitle("Log In", forState: .Normal)
            self.loginButton.alpha = 0.0
            self.loginText.text = "Sign Up"
            self.HaveAccountText.alpha = 0.0
            self.passwordConfirmationField.alpha = 1.0
            self.emailField.alpha = 1.0
            self.signupButton.alpha = 1.0
        })
        self.HaveAccountText.alpha = 1.0
        self.HaveAccountText.text = "Already Have an Account?"
    }
    
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
            self.HaveAccountText.text = "Don\'t Have an Account?"
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
        
        // Make login and signup buttons rounded
        loginButton.layer.cornerRadius = 5
        signupButton.layer.cornerRadius = 5
        
        // Make login and signup buttons have a slight border
        loginButton.layer.borderWidth = 1
        loginButton.layer.borderColor = buttonBorderColor.CGColor
        signupButton.layer.borderWidth = 1
        signupButton.layer.borderColor = buttonBorderColor.CGColor
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

}

