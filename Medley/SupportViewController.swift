//
//  SupportViewController.swift
//  Medley
//
//  Created by Joe Song on 5/2/16.
//  Copyright © 2016 Medley Team. All rights reserved.
//

import UIKit
import Firebase

class SupportViewController: UIViewController, UITextViewDelegate {
    
    var myRootRef = Firebase(url:"https://crackling-heat-1030.firebaseio.com/")
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageBox: UITextView!
    
    let buttonBorderColor : UIColor = UIColor( red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 0.35)
    let placeholderColor : UIColor = UIColor( red: 199/255.0, green: 199/255.0, blue: 205/255.0, alpha: 1)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Stylize send button
        self.sendButton.layer.cornerRadius = 5
        self.sendButton.layer.borderColor = self.buttonBorderColor.CGColor
        self.sendButton.layer.borderWidth = 1
        //Stylize message box
        self.messageBox.layer.cornerRadius = 5
        self.messageBox.text = "Message..."
        self.messageBox.textColor = self.placeholderColor
        
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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}