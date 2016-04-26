//
//  HomeViewController.swift
//  Medley
//
//  Created by Nikolas Chaconas on 4/20/16.
//  Copyright © 2016 Medley Team. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController {
    
    @IBOutlet weak var greetingMessage: UITextField!
    var myRootRef = Firebase(url:"https://crackling-heat-1030.firebaseio.com/")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.hideKeyboardOnTap()
        let current_user = myRootRef.authData
        let current_user_email = current_user.providerData["email"] as? String
        greetingMessage.text =  "Hello " + current_user_email! + "!"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
