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
    
    @IBOutlet weak var albumCover: UIImageView!
    
    @IBOutlet weak var chatBar: UITextField!
    
    @IBOutlet weak var chatBox: UIScrollView!
    
    var roomCode : String!
    var username : String!
    var admin : String!
    var messageCount : Int = 0
    var songCount : Int = 0
    var totalLines : CGFloat = 0
    var chatBoxHeight : CGFloat = 0
    var chatBarConstraint : NSLayoutConstraint = NSLayoutConstraint()
    @IBOutlet weak var menuButton: UIButton!
    var myRootRef = Firebase(url:"https://crackling-heat-1030.firebaseio.com/")
    var observers = [Firebase]()
    @IBOutlet weak var songName: UILabel!
    
    @IBOutlet weak var searchBar: UITextField!
    @IBOutlet weak var songBox: UIScrollView!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var songsButton: UIButton!
    @IBOutlet weak var messagesButton: UIButton!
    var lighterGrey = UIColor(red: 190/255, green: 190/255, blue: 190/255, alpha: 1.0)
    var grey = UIColor(red: 77/255, green: 77/255, blue: 77/255, alpha: 1.0)
    
    var timer = NSTimer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //more customizations for this can be found here
        //http://www.ebc.cat/2015/03/07/customize-your-swrevealviewcontroller-slide-out-menu/
        self.revealViewController().rightViewRevealWidth = self.view.frame.width - 40
        self.revealViewController().rightViewRevealDisplacement = self.view.frame.width - 55
        self.revealViewController().hideKeyboard()
        
        self.searchBar.addTarget(self, action: #selector(songSearchChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        
        //Observer for listening to when application enters background
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RoomViewController.myBackgroundObserverMethod(_:)), name:UIApplicationDidEnterBackgroundNotification, object: nil)
        
        
        //Observer for listening to when application enters foreground
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RoomViewController.myForegroundObserverMethod(_:)), name:UIApplicationWillEnterForegroundNotification, object: nil)
        
        chatBoxHeight = chatBox.frame.height
        chatBarConstraint = NSLayoutConstraint(item: chatBar, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute:NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0)
        
        songsButton.setTitleColor(lighterGrey, forState: .Normal)
        songsButton.setTitleColor(UIColor.blackColor(), forState: .Highlighted)
        messagesButton.setTitleColor(grey, forState: .Normal)
        messagesButton.setTitleColor(UIColor.blackColor(), forState: .Highlighted)
        
        view.addConstraint(chatBarConstraint)
        // Do any additional setup after loading the view, typically from a nib.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RoomViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RoomViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        self.hideKeyboardOnTap()
        menuButton.setTitle("\u{2630}", forState: .Normal)
        menuButton.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.rightRevealToggle(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        myRootRef.observeAuthEventWithBlock({ authData in
            if authData != nil {
                self.myRootRef.childByAppendingPath("users")
                    .childByAppendingPath(authData.uid).childByAppendingPath("current_room")
                    .observeSingleEventOfType(.Value, withBlock: { snapshot in
                        if(!(snapshot.value is NSNull)) {
                            self.setUser((snapshot.value as? String)!)
                            self.currentSong((snapshot.value as? String)!);
                            self.retrieveSongList((snapshot.value as? String)!);
                        }
                    })
                    let ref = self.myRootRef.childByAppendingPath("users").childByAppendingPath(authData.uid)
                        .childByAppendingPath("current_room")
                    self.observers.append(ref)
                
                    ref.observeEventType(.Value, withBlock: { snapshot in
                        if((snapshot.value is NSNull)) {
                            self.performSegueWithIdentifier("HomeViewController", sender:self)
                            self.removeAllObservers()
                        }
                    })
 
            } else {
                self.performSegueWithIdentifier("ViewController", sender:self)
            }
            
        })
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplicationWillResignActiveNotification, object: nil)
        
    }
    
    func songSearchChange(sender : UITextField) {
        print("searching for " + sender.text!)
    }
    
    func currentSong(roomCode : String) {
        let ref = myRootRef.childByAppendingPath("rooms").childByAppendingPath(roomCode).childByAppendingPath("current_song")
        self.observers.append(ref)
        ref.observeEventType(.Value, withBlock: {snapshot in
            if(snapshot.value is NSNull) {
                self.songName.text = "daddy - Joe Song"
            } else {
                self.songName.text = (snapshot.value as? String)!
            }
            
        })
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
        checkForUsersAdded(roomCode, username : username)
    }
    
    func removeAllObservers() {
        for observer in observers {
            observer.removeAllObservers()
        }
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func checkForUsersAdded(roomCode : String, username : String) {
        let ref = self.myRootRef.childByAppendingPath("members").childByAppendingPath(roomCode)
        observers.append(ref)
        ref.observeEventType(.ChildAdded, withBlock: {snapshot in
            self.checkAdmin((snapshot.value as? String)!, roomCode : roomCode, currentUser : username)
            
        })
    }
    
    func checkAdmin(newUser : String, roomCode : String, currentUser : String) {
            let ref = myRootRef.childByAppendingPath("rooms")
                .childByAppendingPath(roomCode).childByAppendingPath("admin")
            ref.observeSingleEventOfType(.Value, withBlock: {snapshot in
                if(self.myRootRef.authData.uid == (snapshot.value as? String)!) {
                    self.admin = currentUser
                    if(self.messageCount == 0) {
                        let message = [
                            "Medley Bot" : "You are in room " + roomCode + ". Share the room code with your friends"
                                + " and start listening to synced music! <3"
                        ]
                        self.sendMessage(message)
                    }
                    else {
                        self.newMemberJoinedMessage(newUser)
                    }
                    
                    
                }
            })
    }
    
    func newMemberJoinedMessage(newUser : String) {
        
        let newMessage : [String : String] = [
            newUser : " "
        ]
        
        self.sendMessage(newMessage)
        
    }
    func retrieveSongList(roomCode: String) {
        addSongMessages();
        let ref = myRootRef.childByAppendingPath("songs").childByAppendingPath(roomCode)
        observers.append(ref)
        let errorMessage = "There are currently no songs in the playlist.\n Search in the toolbar to add some!"
        ref.observeEventType(.Value, withBlock: { snapshot in
            if(snapshot.value is NSNull) {
                self.appendSong(errorMessage, error : 1)
            } else {
                let snapshotObj = snapshot.children.nextObject() as! FDataSnapshot
                self.appendSong(snapshotObj.key, error : 0)
            }
            
        })
    }
    
    func removeError() {
        print(songBox.subviews.last)
        songBox.subviews.last?.removeFromSuperview()
    }
    
    func appendSong(songName : String, error : Int) {
        songCount += 1
        var text : String
        var label : UILabel
        
        if(error == 0) {
            let subview : UILabel = songBox.subviews.last as! UILabel
            if(subview.text != "Current Song Playlist:") {
                self.removeError()
            }
            let textBoxWidth : CGFloat = 20
            text = String(songCount) + ". " + songName
            var rect = CGRectMake(0, 0, self.songBox.bounds.size.width, textBoxWidth)
            rect.origin.y = textBoxWidth * CGFloat(self.songCount) + 40
            label = UILabel(frame: rect)
            label.numberOfLines = 1
            label.textAlignment = NSTextAlignment.Left
        } else {
            songCount -= 1
            let textBoxWidth : CGFloat = 80
            text = songName
            var rect = CGRectMake(0, 0, self.songBox.bounds.size.width, textBoxWidth)
            rect.origin.y = textBoxWidth * CGFloat(self.songCount) + 40
            label = UILabel(frame: rect)
            label.numberOfLines = 2
            label.textAlignment = NSTextAlignment.Center
        }
        
        label.layer.borderWidth = 1
        label.layer.borderColor = (UIColor.whiteColor()).CGColor
        
        
        
        let message = NSMutableAttributedString(string: text, attributes: [NSForegroundColorAttributeName : UIColor.blackColor()])
        label.attributedText = message
        self.songBox.addSubview(label)
    }
    
    func addSongMessages() {
        let textBoxWidth : CGFloat = 40
        var rect = CGRectMake(0, 0, self.songBox.bounds.size.width, textBoxWidth)
        rect.origin.y = 0
        let label = UILabel(frame: rect)
        label.layer.borderWidth = 1
        label.layer.borderColor = (UIColor.whiteColor()).CGColor
        label.numberOfLines = 1
        
        label.textAlignment = NSTextAlignment.Center
        let text = "Current Song Playlist:"
        let message = NSMutableAttributedString(string: text, attributes: [NSFontAttributeName : UIFont.boldSystemFontOfSize(20)])
        label.attributedText = message
        self.songBox.addSubview(label)
    }
    
    func retrieveMessages(roomCode : String) {
        let ref = myRootRef.childByAppendingPath("messages").childByAppendingPath(roomCode)
            observers.append(ref)
        
            ref.observeEventType(.ChildAdded, withBlock: { snapshot in
            self.messageCount += 1
            let snapshotObj = snapshot.children.nextObject() as! FDataSnapshot
            let message = (snapshotObj.value as? String)!
            let messageLength = message.characters.count
            let lineCount = messageLength > 40 ? messageLength / 40 + 1 : 1
            self.totalLines += CGFloat(lineCount)
            let textBoxWidth : CGFloat = 20 * CGFloat(lineCount)
            var rect = CGRectMake(0, 0, self.chatBox.bounds.size.width, textBoxWidth)
            rect.origin.y = 20 * (self.totalLines - CGFloat(lineCount))
            let label = UILabel(frame: rect)
            label.font = label.font.fontWithSize(15)
            label.layer.borderWidth = 1
            label.layer.borderColor = (UIColor.whiteColor()).CGColor
            label.numberOfLines = lineCount
            //label.backgroundColor = UIColor(red: 192/255, green: 192/255, blue: 192/255, alpha: 1.0)
            //label.textColor = UIColor.whiteColor()
            var stylizedMessage : NSMutableAttributedString
            if(message == "" || message == " ") {
                let string = message == "" ? " " + snapshotObj.key + " has left the room." : " " + snapshotObj.key + " has joined the room."
                stylizedMessage = NSMutableAttributedString(string: string, attributes: [NSFontAttributeName : UIFont.italicSystemFontOfSize(label.font.pointSize)])
            }
            else {
                stylizedMessage = NSMutableAttributedString(string: " " + snapshotObj.key + ": ", attributes: [NSFontAttributeName : UIFont.boldSystemFontOfSize(label.font.pointSize)])
                let attrMessage = NSAttributedString(string: message, attributes: [NSForegroundColorAttributeName : UIColor.blackColor()])
                stylizedMessage.appendAttributedString(attrMessage)
            }
            label.textAlignment = NSTextAlignment.Left
            
            label.attributedText = stylizedMessage
            self.chatBox.contentSize = CGSizeMake(320, 20 * self.totalLines)
            self.chatBox.addSubview(label)
            self.scrollChat()
        })
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
        
        self.myRootRef.childByAppendingPath("songs")
            .childByAppendingPath(roomCode).setValue(nil)
        
        self.performSegueWithIdentifier("HomeViewController", sender:self)
    }
    
    func appMovedToBackground() {
        self.hideKeyboard()
    }
    
    func leaveRoom () {
        print("Room has been left")
        
        let newMessage : [String : String] = [
            self.username : ""
        ]
        
        sendMessage(newMessage)
        removeAllObservers()
        
        messageCount = 0
        let current_uid = self.myRootRef.authData.uid
        
        self.myRootRef.childByAppendingPath("users")
            .updateChildValues([current_uid + "/current_room": NSNull()])
        
        self.myRootRef.childByAppendingPath("members")
            .childByAppendingPath(self.roomCode).childByAppendingPath(current_uid).removeValue()
        
        
        
        myRootRef.childByAppendingPath("members").childByAppendingPath(roomCode)
            .observeSingleEventOfType(.Value, withBlock: { snapshot in
                if((snapshot.value is NSNull)){
                    //no more members in the group
                   self.destroyRoom(self.roomCode)
                }
                else {
                    //check to see if current user is the admin of that group
                    self.myRootRef.childByAppendingPath("rooms")
                        .childByAppendingPath(self.roomCode).childByAppendingPath("admin")
                        .observeSingleEventOfType(.Value, withBlock: { snapshot in
                            let current_admin = snapshot.value as! String
                            if(current_admin == current_uid) {
                                //if we are the admin, appoint new admin
                                self.appointNewAdmin(self.roomCode)
                                self.performSegueWithIdentifier("HomeViewController", sender:self)
                            }
                            else {
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
        self.leaveRoom()
            
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: self.view.window)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: self.view.window)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let offset : CGFloat = notification.userInfo![UIKeyboardFrameEndUserInfoKey]!.CGRectValue.size.height
        
        MoveBar(self.chatBarConstraint, size : -offset)
        scrollChat()
    }
    
    func scrollChat() {
        UIView.animateWithDuration(0.5, animations: {
            self.chatBox.setContentOffset(CGPointMake(0, self.chatBox.contentSize.height - self.chatBox.bounds.size.height), animated: false)
        })
    }
    
    func keyboardWillHide(notification: NSNotification) {
        MoveBar(self.chatBarConstraint, size: 0)
    }
    
    func MoveBar(constraint : NSLayoutConstraint, size : CGFloat ) {
        constraint.constant = size
        UIView.animateWithDuration(0.2, animations: {
            self.view.layoutIfNeeded()
        })
        
    }
    @IBAction func songsButtonPressed(sender: AnyObject) {
        self.hideKeyboard()
        songsButton.setTitleColor(grey, forState: .Normal)
        messagesButton.setTitleColor(lighterGrey, forState: .Normal)

        UIView.animateWithDuration(0.3, animations: {
            self.searchBar.alpha = 1.0
            self.chatBox.alpha = 0.0
            self.songBox.alpha = 1.0
            self.chatBar.alpha = 0.0
            self.sendButton.alpha = 0.0
        })
    }
    
    @IBAction func messagesButtonPressed(sender: AnyObject) {
        self.hideKeyboard()
        messagesButton.setTitleColor(grey, forState: .Normal)
        songsButton.setTitleColor(lighterGrey, forState: .Normal)
        UIView.animateWithDuration(0.3, animations: {
            self.searchBar.alpha = 0.0
            self.chatBox.alpha = 1.0
            self.songBox.alpha = 0.0
            self.chatBar.alpha = 1.0
            self.sendButton.alpha = 1.0
        })
    }
    func sendMessage(message : [String : String]) {
        self.chatBar.text = ""
        myRootRef.childByAppendingPath("messages").childByAppendingPath(self.roomCode).childByAppendingPath(String(self.messageCount))
            .setValue(message)
    }
    
        @IBAction func sendButtonPressed(sender: AnyObject) {
        let whitespaceSet = NSCharacterSet.whitespaceCharacterSet()
        if(self.chatBar.text!.stringByTrimmingCharactersInSet(whitespaceSet) != ""){
            let newMessage = [
                self.username : self.chatBar.text!
            ]
            sendMessage(newMessage)
            self.chatBar.text = ""
            myRootRef.childByAppendingPath("messages").childByAppendingPath(self.roomCode).childByAppendingPath(String(self.messageCount))
                .setValue(newMessage)
        }
        
    }
    
    func myBackgroundObserverMethod(notification: NSNotification){
        print("Application is now in background")
        timer.invalidate()
        
        timer = NSTimer.scheduledTimerWithTimeInterval(300.0, target:self, selector: #selector(RoomViewController.leaveRoom), userInfo: nil, repeats: false)
    }
    
    func myForegroundObserverMethod(notification: NSNotification){
        print("Application is now in foreground")
        timer.invalidate()
    }
    
}

