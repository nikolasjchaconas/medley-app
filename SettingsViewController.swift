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
    @IBOutlet weak var settingsHeader: UILabel!
    @IBOutlet weak var logoutButton: UIButton!

    /*
 
            change these, we need to make these global somewhere
 
    */
    var blueBackground = UIColor(red: 0, green: 128/255, blue: 1, alpha: 1.0)
    var purpleBackground = UIColor(red: 204/255, green: 102/255, blue: 1, alpha: 1.0)
    
    //Color for button borders
    let buttonBorderColor : UIColor = UIColor( red: 200/255.0, green: 200/255.0, blue: 200/255.0, alpha: 0.35)
    let buttonShadowColor : UIColor = UIColor( red: 20/255.0, green: 20/255.0, blue: 20/255.0, alpha: 1.0)
    var redColor = UIColor(red: 1, green:0, blue: 0, alpha: 0.8)
    var greenColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0.8)
    
    let blueGrad = CAGradientLayer().blueGradient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.hideKeyboardOnTap()
        
        //Add blue gradient
        self.blueGrad.frame = self.view.bounds
        self.view.layer.addSublayer(blueGrad)
        
        //Put shadow on settings header
        self.settingsHeader.layer.shadowColor = buttonShadowColor.CGColor
        self.settingsHeader.layer.shadowOffset = CGSizeMake(0, 3)
        self.settingsHeader.layer.shadowRadius = 1.0
        self.settingsHeader.layer.shadowOpacity = 1.0
        
        //Round button edges
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
    
    @IBAction func logoutButtonPressed(sender: AnyObject) {
        myRootRef.unauth()
        self.performSegueWithIdentifier("ViewController", sender:sender)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 }