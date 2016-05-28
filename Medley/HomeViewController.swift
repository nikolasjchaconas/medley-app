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
    @IBOutlet var roomCodeField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet weak var medleyLogo: UILabel!
    @IBOutlet weak var joinRoomButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var createRoomButton: UIButton!
    let buttonBorderColor : UIColor = UIColor( red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 0.35)
    let buttonShadowColor : UIColor = UIColor( red: 20/255.0, green: 20/255.0, blue: 20/255.0, alpha: 1.0)
    
    let blackGrad = CAGradientLayer().blackGradient()
    
    //locks orientation to portrait
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.hideKeyboardOnTap()
        
        //Add black gradient
        self.blackGrad.frame = self.view.bounds
        self.view.layer.addSublayer(blackGrad)
        
        // Put shadow on Medley logo and greetings text
        self.medleyLogo.layer.shadowColor = buttonShadowColor.CGColor
        self.medleyLogo.layer.shadowOffset = CGSizeMake(0, 6)
        self.medleyLogo.layer.shadowRadius = 3.0
        self.medleyLogo.layer.shadowOpacity = 1.0
        self.greetingMessage.layer.shadowColor = buttonShadowColor.CGColor
        self.greetingMessage.layer.shadowOffset = CGSizeMake(0, 2)
        self.greetingMessage.layer.shadowRadius = 1.0
        self.greetingMessage.layer.shadowOpacity = 1.0
        
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
        
        // Give buttons shadows
        self.createRoomButton.layer.shadowColor = self.buttonShadowColor.CGColor
        self.createRoomButton.layer.shadowOpacity = 1.0
        self.createRoomButton.layer.shadowRadius = 1.0
        self.createRoomButton.layer.shadowOffset = CGSizeMake(0, 3)
        self.joinRoomButton.layer.shadowColor = self.buttonShadowColor.CGColor
        self.joinRoomButton.layer.shadowOpacity = 1.0
        self.joinRoomButton.layer.shadowRadius = 1.0
        self.joinRoomButton.layer.shadowOffset = CGSizeMake(0, 3)
        self.settingsButton.layer.shadowColor = self.buttonShadowColor.CGColor
        self.settingsButton.layer.shadowOpacity = 1.0
        self.settingsButton.layer.shadowRadius = 1.0
        self.settingsButton.layer.shadowOffset = CGSizeMake(0, 3)
        
        
        //get username
        
        myRootRef.observeAuthEventWithBlock({ authData in
            if authData != nil {
                self.myRootRef.childByAppendingPath("users")
                    .childByAppendingPath(self.myRootRef.authData.uid).childByAppendingPath("username")
                    .observeEventType(.Value, withBlock: { snapshot in
                        self.greetingMessage.text = "Hello " + ((snapshot.value as? String)!) + "!"
                        }, withCancelBlock: { error in
                    })
                        
                    }
            else {
                self.performSegueWithIdentifier("ViewController", sender:self)
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    
    func joinPublicRoom(roomCode : String) {
        let current_id = myRootRef.authData.uid
        myRootRef.childByAppendingPath("users")
        .updateChildValues([current_id + "/current_room": roomCode])
        
        myRootRef.childByAppendingPath("users").childByAppendingPath(current_id).childByAppendingPath("username")
            .observeSingleEventOfType(.Value, withBlock: {snapshot in
                print(snapshot.value)
                self.myRootRef.childByAppendingPath("members").childByAppendingPath(roomCode).childByAppendingPath(current_id).setValue(snapshot.value)
            })
        
        self.performSegueWithIdentifier("SWRevealViewController", sender:self)
    }
    
    func joinPrivateRoom(roomCode : String, password : String) {
        let current_id = myRootRef.authData.uid
        myRootRef.childByAppendingPath("rooms").childByAppendingPath(roomCode).childByAppendingPath("password")
            .observeSingleEventOfType(.Value, withBlock: { snapshot in
                if(password != snapshot.value as? String) {
                    let alertController = UIAlertController(title: "Incorrect Password", message:
                        "The password entered for room " + roomCode + " is not correct", preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler:nil))
                    self.presentViewController(alertController, animated: true, completion: nil)
                } else {
                    self.myRootRef.childByAppendingPath("users")
                        .updateChildValues([current_id + "/current_room": roomCode])
                    
                    self.myRootRef.childByAppendingPath("users").childByAppendingPath(current_id).childByAppendingPath("username")
                        .observeSingleEventOfType(.Value, withBlock: {snapshot in
                            self.myRootRef.childByAppendingPath("members").childByAppendingPath(roomCode).childByAppendingPath(current_id).setValue(snapshot.value)
                        })
                    
                    self.performSegueWithIdentifier("SWRevealViewController", sender:self)
                }
            })
        myRootRef.childByAppendingPath("users").childByAppendingPath(current_id)
    }
    
    func joinRoomWithCode(roomCode : String) {
        
        myRootRef.childByAppendingPath("rooms").childByAppendingPath(roomCode).childByAppendingPath("password")
            .observeSingleEventOfType(.Value, withBlock: { snapshot in
                let password = snapshot.value as? String
                if(password == "") {
                    self.joinPublicRoom(roomCode)
                }
                else {
                    let alertController = UIAlertController(title: "Room is Private", message:
                        "This room is private. Please enter the password for this room", preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addTextFieldWithConfigurationHandler(self.addPassword)
                    alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler:{ action in
                        self.joinPrivateRoom(roomCode, password: self.passwordField.text!)
                    }))
                    alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
        })
    }
    
    func joinRoom(alert: UIAlertAction!) {
        //use self.roomCode
        if(self.roomCodeField.text! == "") {
            let alertController = UIAlertController(title: "Room Does not Exist", message:
                "A Room With That Room Code Does Not Exist.", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler:nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        else {
            myRootRef.childByAppendingPath("rooms").childByAppendingPath(self.roomCodeField.text!).childByAppendingPath("available")
                .observeSingleEventOfType(.Value, withBlock: { snapshot in
                    if(snapshot.value is NSNull) {
                        let alertController = UIAlertController(title: "Room Does not Exist", message:
                            "A Room With That Room Code Does Not Exist.", preferredStyle: UIAlertControllerStyle.Alert)
                        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler:nil))
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                    else if(snapshot.value as! Bool == false){
                        self.joinRoomWithCode(self.roomCodeField.text!)
                    }
                    else {
                        let alertController = UIAlertController(title: "Room Does not Exist", message:
                            "A Room With That Room Code Does Not Exist.", preferredStyle: UIAlertControllerStyle.Alert)
                        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler:nil))
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                })
        }
        
        
    }
    
    func createPublicRoom(alert: UIAlertAction!) {
        createRoom("")
    }
    
    func newRoom(room : FDataSnapshot, password: String) {
    
        let roomCode = room.key
        let current_id = myRootRef.authData.uid
        let newRoom = [
            "room_name" : room.key,
            "admin" : self.myRootRef.authData.uid,
            "password": password,
            "available" : false,
        ]
        
        self.myRootRef.childByAppendingPath("messages").childByAppendingPath(roomCode).setValue(nil)
        
        self.myRootRef.childByAppendingPath("users")
            .updateChildValues([self.myRootRef.authData.uid + "/current_room": room.key])
        
        self.myRootRef.childByAppendingPath("rooms")
            .childByAppendingPath(roomCode).setValue(newRoom)
        
        myRootRef.childByAppendingPath("users").childByAppendingPath(current_id).childByAppendingPath("username")
            .observeSingleEventOfType(.Value, withBlock: {snapshot in
                self.myRootRef.childByAppendingPath("members").childByAppendingPath(roomCode).childByAppendingPath(current_id).setValue(snapshot.value)
            })
        
        
        self.performSegueWithIdentifier("SWRevealViewController", sender:self)
        
    }
    
    func createRoom(password: String) {
        
            //create private room
            myRootRef.childByAppendingPath("rooms").queryOrderedByChild("available").queryEqualToValue(true).queryLimitedToFirst(1)
                .observeSingleEventOfType(.Value, withBlock: { snapshot in
                    if(!(snapshot.value is NSNull)) {
                        let child: FDataSnapshot = snapshot.children.nextObject() as! FDataSnapshot
                        self.newRoom(child, password: password)
                    }
                    else {
                        let alertController = UIAlertController(title: "No more Available Room Codes", message:
                            "The makers of medley suck and there arent any more room codes.", preferredStyle: UIAlertControllerStyle.Alert)
                        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler:nil))
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                    
                    
                })

    }
    
    func createPrivateRoom(alert: UIAlertAction!) {
        let alertController = UIAlertController(title: "Create A Private Room", message:
            "Create a Password for your Room: Leave field blank to make Room Public", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addTextFieldWithConfigurationHandler(addPassword)
        alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler:{ action in
            self.createRoom(self.passwordField.text!)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func addPassword(textField: UITextField!) {
        textField.textAlignment = NSTextAlignment .Center
        textField.placeholder = "Password"
        self.passwordField = textField
    }
    
    func addTextField(textField: UITextField!) {
        textField.textAlignment = NSTextAlignment .Center
        textField.placeholder = "Room Code"
        self.roomCodeField = textField
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
    
}
