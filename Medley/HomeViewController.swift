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
    
    
    @IBOutlet weak var greetingMessage: UILabel!
    var myRootRef = Firebase(url:"https://crackling-heat-1030.firebaseio.com/")
    @IBOutlet var roomCode: UITextField!
    @IBOutlet weak var joinRoomButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var createRoomButton: UIButton!
    
    let buttonBorderColor : UIColor = UIColor( red: 255, green: 255, blue: 255, alpha: 0.35)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.hideKeyboardOnTap()
        
        // Round the button corners
        self.createRoomButton.layer.cornerRadius = 5
        self.settingsButton.layer.cornerRadius = 5
        self.joinRoomButton.layer.cornerRadius = 5
        
        // Give buttons outlines
        self.createRoomButton.layer.borderWidth = 1
        self.createRoomButton.layer.borderColor = self.buttonBorderColor.CGColor
        self.joinRoomButton.layer.borderWidth = 1
        self.joinRoomButton.layer.borderColor = self.buttonBorderColor.CGColor
        self.settingsButton.layer.borderWidth = 1
        self.settingsButton.layer.borderColor = self.buttonBorderColor.CGColor
        
        
        //get username
        myRootRef.childByAppendingPath("users")
            .childByAppendingPath(myRootRef.authData.uid).childByAppendingPath("username")
            .observeEventType(.Value, withBlock: { snapshot in
                self.greetingMessage.text = "Hello " + ((snapshot.value as? String)!) + "!"
                }, withCancelBlock: { error in
            })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func joinRoom(alert: UIAlertAction!) {
        //use self.roomCode
        self.performSegueWithIdentifier("RoomViewController", sender:self)
    }
    
    func createPublicRoom(alert: UIAlertAction!) {
        createRoom("")
    }
    
    func createRoom(password: String) {
        if(password == "") {
            //create nonprivate room
            self.performSegueWithIdentifier("RoomViewController", sender:self)
        }
        else {
            //create private room
            self.performSegueWithIdentifier("RoomViewController", sender:self)
        }
    }
    
    func createPrivateRoom(alert: UIAlertAction!) {
        var password = ""
        let alertController = UIAlertController(title: "Create A Private Room", message:
            "Create a Password for your Room: Leave field blank to make Room Public", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.textAlignment = NSTextAlignment .Center
            textField.placeholder = "Room Code"
            password = textField.text!
        })
        alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler:{ action in
            // whatever else you need to do here
            self.createRoom(password)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func addTextField(textField: UITextField!) {
        textField.textAlignment = NSTextAlignment .Center
        textField.placeholder = "Room Code"
        self.roomCode = textField
    }

    
    @IBAction func joinRoomButtonPressed(sender: AnyObject) {
        let alertController = UIAlertController(title: "Enter Room Code", message:
            "Enter the room code of the room you would like to join", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addTextFieldWithConfigurationHandler(addTextField)
        alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: joinRoom))
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func createRoomButtonPressed(sender: AnyObject) {
        let alertController = UIAlertController(title: "Create Room", message:
            "What type of room you want?\nPublic: Anyone with a room code can join\nPrivate: A password is necessary to join", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Public", style: UIAlertActionStyle.Default, handler: createPublicRoom))
        alertController.addAction(UIAlertAction(title: "Private", style: UIAlertActionStyle.Default, handler: createPrivateRoom))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func logoutButtonPressed(sender: AnyObject) {
        myRootRef.unauth()
        self.performSegueWithIdentifier("ViewController", sender:sender)
    }
    
}
