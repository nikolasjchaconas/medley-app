//
//  AboutViewController.swift
//  Medley
//
//  Created by Joe Song on 5/3/16.
//  Copyright © 2016 Medley Team. All rights reserved.
//

import UIKit
import Firebase

class AboutViewController: UIViewController {
    
    var myRootRef = Firebase(url:"https://crackling-heat-1030.firebaseio.com/")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.hideKeyboardOnTap()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}