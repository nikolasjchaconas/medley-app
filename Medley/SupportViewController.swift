//
//  SupportViewController.swift
//  Medley
//
//  Created by Joe Song on 5/2/16.
//  Copyright © 2016 Medley Team. All rights reserved.
//

import UIKit
import Firebase

class SupportViewController: UIViewController {
    
    var myRootRef = Firebase(url:"https://crackling-heat-1030.firebaseio.com/")
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageBox: UITextView!
    
    let buttonBorderColor : UIColor = UIColor( red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 0.35)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Stylize send button
        self.sendButton.layer.cornerRadius = 5
        self.sendButton.layer.borderColor = self.buttonBorderColor.CGColor
        self.sendButton.layer.borderWidth = 1
        //Stylize message box
        self.messageBox.layer.cornerRadius = 5
        
        self.hideKeyboardOnTap()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}