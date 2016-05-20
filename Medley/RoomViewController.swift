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
    var admin : String!
    var messageCount : Int = 0
    var chatBoxSize : CGFloat = 0
    var totalLines : CGFloat = 0
    var retrieveMessagesHandle : FirebaseHandle = 0, currentRoomHandle : FirebaseHandle = 0
    
    @IBOutlet weak var menuButton: UIButton!
    var myRootRef = Firebase(url:"https://crackling-heat-1030.firebaseio.com/")
    
    @IBOutlet weak var sendButton: UIButton!
    
    
    //locks orientation to portrait
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RoomViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RoomViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        self.hideKeyboardOnTap()
        menuButton.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.rightRevealToggle(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        myRootRef.observeAuthEventWithBlock({ authData in
            if authData != nil {
                self.myRootRef.childByAppendingPath("users")
                    .childByAppendingPath(authData.uid).childByAppendingPath("current_room")
                    .observeSingleEventOfType(.Value, withBlock: { snapshot in
                        if(!(snapshot.value is NSNull)) {
                            self.setUser((snapshot.value as? String)!)
                            
                        }
                    })
                
                    self.currentRoomHandle = self.myRootRef.childByAppendingPath("users").childByAppendingPath(authData.uid).childByAppendingPath("current_room")
                    .observeEventType(.Value, withBlock: { snapshot in
                        if((snapshot.value is NSNull)) {
                            self.performSegueWithIdentifier("HomeViewController", sender:self)
                            self.myRootRef.removeObserverWithHandle(self.currentRoomHandle)
                        }
                    })
 
            } else {
                self.performSegueWithIdentifier("ViewController", sender:self)
            }
            
        })
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplicationWillResignActiveNotification, object: nil)
        
    }
    func setUser(roomCode : String) {
        self.myRootRef.childByAppendingPath("users").childByAppendingPath(myRootRef.authData.uid)
        .childByAppendingPath("username")
            .observeSingleEventOfType(.Value, withBlock: { snapshot in
                self.setCode(roomCode, username: (snapshot.value as? String)!)
            })
    }
    
    func setCode(roomCode : String, username : String) {
        self.username = username
        retrieveMessages(roomCode)
        
        self.roomCode = roomCode
        admin(roomCode,username : username)
    }
    
    func admin(roomCode : String, username : String) {
        
        myRootRef.childByAppendingPath("rooms").childByAppendingPath(roomCode).childByAppendingPath("admin")
            .observeSingleEventOfType(.Value, withBlock: {snapshot in
                if(self.myRootRef.authData.uid == (snapshot.value as? String)!) {
                    self.admin = username
                    let message = [
                        "Medley Bot" : "You are in room " + roomCode + ". Share the room code with your friends"
                        + " and start listening to synced music! <3"
                    ]
                    self.sendMessage(message)
                    self.myRootRef.childByAppendingPath("members").childByAppendingPath(roomCode)
                        .observeEventType(.ChildAdded, withBlock: {snapshot in
    
                        let newMessage : [String : String] = [
                             (snapshot.value as? String)! : "has entered the room"
                        ]
                        
                        self.sendMessage(newMessage)
                        
                        })
                }
            })
    }
    
    func retrieveMessages(roomCode : String) {
        retrieveMessagesHandle = myRootRef.childByAppendingPath("messages").childByAppendingPath(roomCode).observeEventType(.ChildAdded, withBlock: { snapshot in
            self.messageCount += 1
            print("added -> \(snapshot.value)")
            let snapshotObj = snapshot.children.nextObject() as! FDataSnapshot
            let message = (snapshotObj.value as? String)!
            let messageLength = message.characters.count
            print("messages.char.count is " + String(messageLength))
            let lineCount = messageLength > 40 ? messageLength / 40 + 1 : 1
            print("message is " + message)
            self.totalLines += CGFloat(lineCount)
            let textBoxWidth : CGFloat = 20 * CGFloat(lineCount)
            var rect = CGRectMake(0, 0, self.chat_box.bounds.size.width, textBoxWidth)
            rect.origin.y = 20 * (self.totalLines - CGFloat(lineCount))
            let label = UILabel(frame: rect)
            label.font = label.font.fontWithSize(15)
            label.layer.borderWidth = 1
            label.layer.borderColor = (UIColor.whiteColor()).CGColor
            label.numberOfLines = lineCount
            //label.backgroundColor = UIColor(red: 192/255, green: 192/255, blue: 192/255, alpha: 1.0)
            //label.textColor = UIColor.whiteColor()
            label.textAlignment = NSTextAlignment.Left
            let stylizedMessage = NSMutableAttributedString(string: " " + snapshotObj.key + ": ", attributes: [NSFontAttributeName : UIFont.boldSystemFontOfSize(label.font.pointSize)])
            let attrMessage = NSAttributedString(string: message, attributes: [NSForegroundColorAttributeName : UIColor.blackColor()])
            stylizedMessage.appendAttributedString(attrMessage)
            label.attributedText = stylizedMessage
            self.chat_box.contentSize = CGSizeMake(320, 20 * self.totalLines)
            self.chat_box.addSubview(label)
            self.chat_box.setContentOffset(CGPointMake(0, self.chat_box.contentSize.height - self.chat_box.bounds.size.height), animated: true)
        })
    }
    //change this to correct function
    @IBAction func chat_barTouched(sender: AnyObject) {
        print("done")
        self.chat_box.setContentOffset(CGPointMake(0, self.chat_box.contentSize.height - self.chat_box.bounds.size.height), animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func destroyRoom (roomCode : String) {
        messageCount = 0        
        let available_room = [
            "available" : true,
            "room_name" : NSNull()
        ]
        self.myRootRef.childByAppendingPath("rooms")
            .childByAppendingPath(roomCode).setValue(available_room)
        
        self.myRootRef.childByAppendingPath("messages")
        .childByAppendingPath(roomCode).setValue(nil)
    }
    
    func appMovedToBackground() {
        self.hideKeyboard()
    }
    
    func leaveRoom (roomCode : String) {
        
        let newMessage : [String : String] = [
            self.username : "has left the room"
        ]
        
        sendMessage(newMessage)
        myRootRef.removeAllObservers()
        messageCount = 0
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
    func sendMessage(message : [String : String]) {
        self.chat_bar.text = ""
        myRootRef.childByAppendingPath("messages").childByAppendingPath(self.roomCode).childByAppendingPath(String(self.messageCount))
            .setValue(message)
    }
    
        @IBAction func sendButtonPressed(sender: AnyObject) {
        if(self.chat_bar.text! != ""){
            let newMessage = [
                self.username : self.chat_bar.text!
            ]
            sendMessage(newMessage)
            self.chat_bar.text = ""
            myRootRef.childByAppendingPath("messages").childByAppendingPath(self.roomCode).childByAppendingPath(String(self.messageCount))
                .setValue(newMessage)
        }
        
    }
    
}