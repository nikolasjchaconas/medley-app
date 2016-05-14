//
//  RoomViewController.swift
//  Medley
//
//  Created by Nikolas Chaconas on 4/26/16.
//  Copyright © 2016 Medley Team. All rights reserved.
//

import UIKit
import Firebase

class RoomViewController: UIViewController {
    
    @IBOutlet weak var album_cover: UIImageView!
    
    @IBOutlet weak var chat_bar: UITextField!
    
    @IBOutlet weak var chat_box: UIScrollView!
    var roomCode : String!
    var username : String!
    var messageCount : Int = 0
    var chatBoxSize : CGFloat = 0
    @IBOutlet weak var menuButton: UIButton!
    var myRootRef = Firebase(url:"https://crackling-heat-1030.firebaseio.com/")
    
    @IBOutlet weak var sendButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RoomViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RoomViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        sendButton.layer.cornerRadius = 5
        self.hideKeyboardOnTap()
        
        menuButton.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.rightRevealToggle(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        myRootRef.observeAuthEventWithBlock({ authData in
            if authData != nil {
                self.myRootRef.childByAppendingPath("users").childByAppendingPath(authData.uid).childByAppendingPath("current_room")
                    .observeSingleEventOfType(.Value, withBlock: { snapshot in
                        if(!(snapshot.value is NSNull)) {
                            self.setCode((snapshot.value as? String)!)
                        }
                    })
                self.myRootRef.childByAppendingPath("users").childByAppendingPath(authData.uid).childByAppendingPath("username")
                    .observeSingleEventOfType(.Value, withBlock: { snapshot in
                        self.setname((snapshot.value as? String)!)
                    })
                
            }
            
        })
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.messageCount = 0
    }
    
    //locks orientation to portrait
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    func setname(username : String) {
        self.username = username
    }
    func setCode(roomCode : String) {
        memberJoined(roomCode)
        memberLeft(roomCode)
        retrieveMessages(roomCode)
        self.roomCode = roomCode
    }
    func memberLeft(roomCode : String) {
        myRootRef.childByAppendingPath("members").childByAppendingPath(roomCode)
            .observeEventType(.ChildRemoved, withBlock: {snapshot in
                
                let newUser = (snapshot.value as? String)!
                let newMessage : [String : String] = [
                    newUser : "has left the room"
                ]
                
                self.chat_bar.text = ""
                self.myRootRef.childByAppendingPath("messages").childByAppendingPath(self.roomCode).childByAppendingPath(String(self.messageCount))
                    .setValue(newMessage)
            })
    }
    func memberJoined(roomCode : String) {
        myRootRef.childByAppendingPath("members").childByAppendingPath(roomCode)
            .observeEventType(.ChildAdded, withBlock: {snapshot in

                let newUser = (snapshot.value as? String)!
                let newMessage : [String : String] = [
                    newUser : "has entered the room"
                ]
                
                self.chat_bar.text = ""
                self.myRootRef.childByAppendingPath("messages").childByAppendingPath(self.roomCode).childByAppendingPath(String(self.messageCount))
                    .setValue(newMessage)
            })
    }
    
    func retrieveMessages(roomCode : String) {
        myRootRef.childByAppendingPath("messages").childByAppendingPath(roomCode).observeEventType(.ChildAdded, withBlock: { snapshot in
            self.messageCount += 1
            print("added -> \(snapshot.value)")
            let snapshotObj = snapshot.children.nextObject() as! FDataSnapshot
            var rect = CGRectMake(0, 0, self.chat_box.bounds.size.width, 30)
            rect.origin.y = CGFloat(self.messageCount - 1) * 30.0
            let label = UILabel(frame: rect)
            label.layer.borderWidth = 1
            label.layer.borderColor = (UIColor.whiteColor()).CGColor
            label.numberOfLines = 2
            label.backgroundColor = UIColor(red: 192/255, green: 192/255, blue: 192/255, alpha: 1.0)
            label.textColor = UIColor.whiteColor()
            label.textAlignment = NSTextAlignment.Left
            label.text = "  " + snapshotObj.key + " : " + (snapshotObj.value as? String)!
            self.chat_box.contentSize = CGSizeMake(320, (CGFloat(self.messageCount) * 30.0))
            self.chat_box.addSubview(label)
            self.chat_box.setContentOffset(CGPointMake(0, self.chat_box.contentSize.height - self.chat_box.bounds.size.height), animated: true)
        })
    }
    
    @IBAction func chat_barTouched(sender: AnyObject) {
        self.chat_box.setContentOffset(CGPointMake(0, self.chat_box.contentSize.height - self.chat_box.bounds.size.height), animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func destroyRoom (roomCode : String) {
        let available_room = [
            "available" : true,
            "room_name" : NSNull()
        ]
        self.myRootRef.childByAppendingPath("rooms")
            .childByAppendingPath(roomCode).setValue(available_room)
        
        self.myRootRef.childByAppendingPath("messages")
        .childByAppendingPath(roomCode).setValue(nil)
        //will have to use this if we make functionality for deleting room with people in it
//        self.myRootRef.childByAppendingPath("members").childByAppendingPath(roomCode)
//            .observeSingleEventOfType(.Value, withBlock: {snapshot in
//                print(snapshot.children.allObjects)
//            })
        self.performSegueWithIdentifier("HomeViewController", sender:self)
    }
    
    func leaveRoom (roomCode : String) {
        let current_uid = self.myRootRef.authData.uid
        
        self.myRootRef.childByAppendingPath("users")
            .updateChildValues([current_uid + "/current_room": NSNull()])
        
        self.myRootRef.childByAppendingPath("members")
            .childByAppendingPath(roomCode).childByAppendingPath(current_uid).removeValue()
        
        
        myRootRef.childByAppendingPath("members").childByAppendingPath(roomCode)
            .observeSingleEventOfType(.Value, withBlock: { snapshot in
                if((snapshot.value is NSNull)){
                    //no more members in the group
                   self.destroyRoom(roomCode)
                }
                else {
                    //check to see if current user is the admin of that group
                    self.myRootRef.childByAppendingPath("rooms")
                        .childByAppendingPath(roomCode).childByAppendingPath("admin")
                        .observeSingleEventOfType(.Value, withBlock: { snapshot in
                            let current_admin = snapshot.value as! String
                            if(current_admin == current_uid) {
                                //if we are the admin, appoint new admin
                                self.appointNewAdmin(roomCode)
                                self.performSegueWithIdentifier("HomeViewController", sender:self)
                            } else {
                                //we've already removed ourselves, time to go
                                self.performSegueWithIdentifier("HomeViewController", sender:self)
                            }
                        })
                }
            })
        
        
        
    }
    
    func appointNewAdmin(roomCode : String) {
        self.myRootRef.childByAppendingPath("members").childByAppendingPath(roomCode)
            .observeSingleEventOfType(.Value, withBlock: {snapshot in
                let child: FDataSnapshot = snapshot.children.nextObject() as! FDataSnapshot
                self.myRootRef.childByAppendingPath("rooms").childByAppendingPath(roomCode).childByAppendingPath("admin")
                    .setValue(child.key)
            })
        
    }
    
    @IBAction func leaveRoomButtonPressed(sender: AnyObject) {
        myRootRef.childByAppendingPath("users").childByAppendingPath(myRootRef.authData.uid).childByAppendingPath("current_room")
            .observeSingleEventOfType(.Value, withBlock: { snapshot in
                //print(snapshot.value)
                self.leaveRoom(snapshot.value as! String)
            })
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y -= keyboardSize.height
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y += keyboardSize.height
        }
    }
    @IBAction func sendButtonPressed(sender: AnyObject) {
        
        let newMessage = [
            self.username : self.chat_bar.text!
        ]
        
        self.chat_bar.text = ""
        myRootRef.childByAppendingPath("messages").childByAppendingPath(self.roomCode).childByAppendingPath(String(self.messageCount))
        .setValue(newMessage)
        self.hideKeyboard()
    }
    
}