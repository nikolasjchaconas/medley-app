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
    
    @IBOutlet weak var aboutHeader: UILabel!
    @IBOutlet weak var aboutMessage: UILabel!
    
    let buttonShadowColor : UIColor = UIColor( red: 20/255.0, green: 20/255.0, blue: 20/255.0, alpha: 1.0)
    
    let blackGrad = CAGradientLayer().blackGradient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Add black gradient
        self.blackGrad.frame = self.view.bounds
        self.view.layer.addSublayer(blackGrad)
        
        // Add shadow to about header message and about text
        self.aboutHeader.layer.shadowColor = buttonShadowColor.CGColor
        self.aboutHeader.layer.shadowOffset = CGSizeMake(0, 6)
        self.aboutHeader.layer.shadowRadius = 3.0
        self.aboutHeader.layer.shadowOpacity = 1.0
        self.aboutMessage.layer.shadowColor = buttonShadowColor.CGColor
        self.aboutMessage.layer.shadowOffset = CGSizeMake(0, 2)
        self.aboutMessage.layer.shadowRadius = 1.0
        self.aboutMessage.layer.shadowOpacity = 1.0
        // Do any additional setup after loading the view, typically from a nib.
        self.hideKeyboardOnTap()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}