//
//  RoomViewController.swift
//  Medley
//
//  Created by Nikolas Chaconas on 4/26/16.
//  Copyright © 2016 Medley Team. All rights reserved.
//

import UIKit
import Firebase
import YouTubePlayer

class RoomViewController: UIViewController, YouTubePlayerDelegate {
    
    @IBOutlet weak var albumCover: UIImageView!
    
    @IBOutlet weak var chatBar: UITextField!
    
    @IBOutlet weak var chatBox: UIScrollView!
    
    @IBOutlet weak var videoLoadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var playerView: YouTubePlayerView!
    
    @IBOutlet weak var syncVideoForwardButton: UIButton!
    @IBOutlet weak var syncVideoBackwardButton: UIButton!
    
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    var roomCode : String!
    var username : String!
    var admin : String!
    var messageCount : Int = 0
    var songCount : Int = 0
    var totalLines : CGFloat = 0
    var chatBoxHeight : CGFloat = 0
    var songPresent : Bool = false
    var chatBarConstraint : NSLayoutConstraint = NSLayoutConstraint()
    @IBOutlet weak var menuButton: UIButton!
    var myRootRef = Firebase(url:"https://crackling-heat-1030.firebaseio.com/")
    var observers = [Firebase]()
    var songStateRef : Firebase = Firebase()
    var songTime : Float = 0
    var seekAmount : Float = 0
    var songTimer : NSTimer = NSTimer()
    var waiting : Bool = false
    var firstTime : Bool = true
    var timeoutTimer :  NSTimer = NSTimer()
    var messagesMissing : Int = 0
    var inMessages : Bool = true
    @IBOutlet weak var songName: UILabel!
    
    @IBOutlet weak var searchBar: UITextField!
    @IBOutlet weak var songBox: UIScrollView!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var songsButton: UIButton!
    @IBOutlet weak var messagesButton: UIButton!
    
    var delegate:YouTubePlayerDelegate?
    
    var lighterGrey = UIColor(red: 190/255, green: 190/255, blue: 190/255, alpha: 1.0)
    var grey = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1.0)
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //more customizations for this can be found here
        //http://www.ebc.cat/2015/03/07/customize-your-swrevealviewcontroller-slide-out-menu/
        self.revealViewController().rightViewRevealWidth = self.view.frame.width - 40
        self.revealViewController().rightViewRevealDisplacement = self.view.frame.width - 55
        self.revealViewController().hideKeyboard()
        
        self.searchBar.addTarget(self, action: #selector(songSearchChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        self.searchBar.addTarget(self, action: #selector(searchBarTapped(_:)), forControlEvents: UIControlEvents.EditingDidBegin)
        self.searchBar.addTarget(self, action: #selector(searchBarGone(_:)), forControlEvents: UIControlEvents.EditingDidEnd)
        
        //Observer for listening to when application enters background
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RoomViewController.myBackgroundObserverMethod(_:)), name:UIApplicationDidEnterBackgroundNotification, object: nil)
        //Observer for listening to when application enters foreground
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RoomViewController.myForegroundObserverMethod(_:)), name:UIApplicationWillEnterForegroundNotification, object: nil)
        
        playerView.delegate = self
        
        chatBoxHeight = chatBox.frame.height
        chatBarConstraint = NSLayoutConstraint(item: chatBar, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute:NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0)
        
        songsButton.setTitleColor(lighterGrey, forState: .Normal)
        messagesButton.setTitleColor(grey, forState: .Normal)
        
        view.addConstraint(chatBarConstraint)
        // Do any additional setup after loading the view, typically from a nib.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RoomViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RoomViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        self.hideKeyboardOnTap()
        menuButton.setTitle("\u{2630}", forState: .Normal)
        menuButton.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.rightRevealToggle(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        observers.append(myRootRef)
        myRootRef.observeAuthEventWithBlock({ authData in
            if authData != nil {
                self.myRootRef.childByAppendingPath("users")
                    .childByAppendingPath(authData.uid).childByAppendingPath("current_room")
                    .observeSingleEventOfType(.Value, withBlock: { snapshot in
                        if(!(snapshot.value is NSNull)) {
                            self.checkSeek((snapshot.value as? String)!)
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
    
        func checkSeek(roomCode : String) {
            let ref2 = self.myRootRef.childByAppendingPath("rooms")
                .childByAppendingPath(roomCode).childByAppendingPath("song_time")
            self.observers.append(ref2)
            
            ref2.observeEventType(.Value, withBlock: {snapshot in
                if (!(snapshot.value is NSNull)) {
                    self.songTime = (snapshot.value as? Float)!
                }
            })
        }
        func songState(roomCode : String) {
            
            songStateRef = myRootRef.childByAppendingPath("rooms")
                .childByAppendingPath(roomCode).childByAppendingPath("song_state")
            observers.append(songStateRef)
            if(waiting == true) {
                waiting = false
                self.videoLoadingIndicator.stopAnimating()
            }
            songStateRef.observeEventType(.Value, withBlock: {snapshot in
                if(!(snapshot.value is NSNull)) {
                    let state: String = (snapshot.value as? String)!
                    if(state == "playing") {
                        print("song is currently playing, calling play and seeking to " + String(self.songTime + self.seekAmount))
                        self.playerView.play()
                        self.playerView.seekTo(self.songTime + self.seekAmount, seekAhead: true)
                    }
                    else if(state == "paused") {
                        print("pressing pause2")
                        self.playerView.pause()
                    } else if (state == "ended") {
                        //this is kind of optional
                        print("stopping video")
                        self.playerView.stop()
                    }
                }
                
            })
        }
    
        func playOrPauseVideo() {
            if playerView.playerState != YouTubePlayerState.Playing {
                myRootRef.childByAppendingPath("rooms")
                    .childByAppendingPath(self.roomCode).childByAppendingPath("song_state")
                    .setValue("playing")
                print("playing")
                playerView.play()
                playButton.setTitle("Pause", forState: .Normal)
            } else {
                myRootRef.childByAppendingPath("rooms")
                    .childByAppendingPath(self.roomCode).childByAppendingPath("song_state")
                    .setValue("paused")
                print("pressing pause")
                playerView.pause()
                playButton.setTitle("Play", forState: .Normal)
            }
        }
        //protocols
        func playerReady(videoPlayer: YouTubePlayerView) {
            if(myRootRef.authData.uid != self.admin) {
                if(firstTime == true) {
                    firstTime = false
                    print("calling song state")
                    songState(self.roomCode)
                }
                
            } else {
                if(waiting == true) {
                    print("waiting")
                    waiting = false
                    self.videoLoadingIndicator.stopAnimating()
                    self.playOrPauseVideo()
                }
            }
            
        }
    
        func playerStateChanged(videoPlayer: YouTubePlayerView, playerState: YouTubePlayerState) {
            print("state is " + String(playerState))
            if(playerState == YouTubePlayerState.Ended) {
                seekAmount = 0
            }
            if(myRootRef.authData.uid == self.admin) {
                if(self.playerView.playerState == YouTubePlayerState.Paused) {
                    print("turning off timer")
                    songTimer.invalidate()
                } else if (playerState == YouTubePlayerState.Playing) {
                    songTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(songTimerIncrementor), userInfo: nil, repeats: true)
                } else if(playerState == YouTubePlayerState.Ended) {
                    print("turning off timer")
                    songTimer.invalidate()
                    playButton.setTitle("Play", forState: .Normal)
                    setSeekZero()
                    myRootRef.childByAppendingPath("rooms")
                        .childByAppendingPath(self.roomCode).childByAppendingPath("song_playing")
                        .setValue(false)
                    myRootRef.childByAppendingPath("rooms")
                        .childByAppendingPath(self.roomCode).childByAppendingPath("song_state")
                        .setValue("ended")
                }
            }
            
        }
        func playerQualityChanged(videoPlayer: YouTubePlayerView, playbackQuality: YouTubePlaybackQuality) {
            
        }
    
    func adminChange(roomCode : String, username : String) {
        let ref = myRootRef.childByAppendingPath("rooms")
            .childByAppendingPath(roomCode).childByAppendingPath("admin")
        observers.append(ref)
        ref.observeEventType(.Value, withBlock: {snapshot in
            self.admin = (snapshot.value as? String)!
            if(self.myRootRef.authData.uid == (snapshot.value as? String)!) {
                if(self.playerView.playerState == YouTubePlayerState.Playing) {
                    self.playButton.setTitle("Pause", forState: .Normal)
                    self.songTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(self.songTimerIncrementor), userInfo: nil, repeats: true)
                }
                self.seekAmount = 0
                self.songStateRef.removeAllObservers()
                self.playButton.alpha = 1.0
                self.nextButton.alpha = 1.0
                self.previousButton.alpha = 1.0
                self.syncVideoForwardButton.alpha = 0.0
                self.syncVideoBackwardButton.alpha = 0.0
                let alertController = UIAlertController(title: "Admin", message:
                    "You are now the admin for room " + roomCode, preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler:nil))
                self.presentViewController(alertController, animated: true, completion: nil)
            } else {
                self.playButton.alpha = 0.0
                self.nextButton.alpha = 0.0
                self.previousButton.alpha = 0.0
                self.syncVideoForwardButton.alpha = 1.0
                self.syncVideoBackwardButton.alpha = 1.0
            }
        })
    }
    
    func songSearchChange(sender : UITextField) {
        print("searching for " + sender.text!)
    }
    
    func searchBarTapped(sender : UITextField) {
        print("helloo!")
    }
    
    func searchBarGone(sender : UITextField) {
        print("gooodbye!!")
    }
    
    @IBAction func playButtonPressed(sender: AnyObject) {
        if(self.songPresent == true) {
            if(!(playerView.ready)) {
                self.videoLoadingIndicator.startAnimating()
                self.waiting = true
            } else {
                self.playOrPauseVideo()
            }
        }
    }
    
    func songTimerIncrementor() {
        self.songTime += 0.1
        myRootRef.childByAppendingPath("rooms").childByAppendingPath(self.roomCode)
            .childByAppendingPath("song_time").setValue(self.songTime)
    }
    
    func setSeekZero() {
        songTime = 0
        myRootRef.childByAppendingPath("rooms").childByAppendingPath(self.roomCode)
            .childByAppendingPath("song_time").setValue(self.songTime)
    }
    
    @IBAction func nextButtonPressed(sender: AnyObject) {
        songTime = 0
        myRootRef.childByAppendingPath("rooms").childByAppendingPath(self.roomCode)
            .childByAppendingPath("song_time").setValue(self.songTime)
    }
    @IBAction func previousButtonPressed(sender: AnyObject) {
        
    }
    
    @IBAction func syncVideoForwardButtonPressed(sender: AnyObject) {
        print(playerView.playerState)
        if(playerView.playerState == YouTubePlayerState.Playing) {
            seekAmount += 0.1
            playerView.seekTo(songTime + seekAmount, seekAhead: true)
        }
    }
    
    @IBAction func syncVideoBackwardButtonPressed(sender: AnyObject) {
        if(playerView.playerState == YouTubePlayerState.Playing) {
            seekAmount -= 0.1
            playerView.seekTo(songTime + seekAmount, seekAhead: true)
        }
    }
    
    
    func currentSong(roomCode : String) {
        let ref = myRootRef.childByAppendingPath("rooms").childByAppendingPath(roomCode).childByAppendingPath("current_song")
        self.observers.append(ref)
        ref.observeEventType(.Value, withBlock: {snapshot in
            if(snapshot.value is NSNull) {
                self.songPresent = false
                self.songName.text = "There are no videos in your playlist!"
            } else {
                self.songPresent = true
                let snapshotObj = snapshot.children.nextObject() as! FDataSnapshot
                self.songName.text = snapshotObj.key
                self.loadVideo((snapshotObj.value as? String)!)
            }
            
        })
    }
    
    func loadVideo(videoUrl : String) {
        playerView.playerVars = [
            "playsinline": "1",
            "controls": "0",
            "showinfo": "0",
            "start" : String(songTime)
        ]
        print("loading video with URL "  + videoUrl + "to timestamp " + String(songTime))
        //playerView.loadVideoID("wQg3bXrVLtg")
        let url = NSURL(string: videoUrl)
        playerView.loadVideoURL(url!)
    }
    
    func setUser(roomCode : String) {
        self.myRootRef.childByAppendingPath("users").childByAppendingPath(myRootRef.authData.uid)
        .childByAppendingPath("username")
            .observeSingleEventOfType(.Value, withBlock: { snapshot in
                self.setCode(roomCode, username: (snapshot.value as? String)!)
                self.adminChange(roomCode, username: (snapshot.value as? String)!);
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
                self.admin = (snapshot.value as? String)!
                if(self.myRootRef.authData.uid == (snapshot.value as? String)!) {
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
                if(self.inMessages == false) {
                    self.messagesMissing += 1
                    self.showMessagesMissed()
                }
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
        
        let newMessage : [String : String] = [
            self.username : ""
        ]
        playerView.stop()
        songTimer.invalidate()
        sendMessage(newMessage)
        removeAllObservers()
        
        messageCount = 0
        let current_uid = self.myRootRef.authData.uid
        
        self.myRootRef.childByAppendingPath("users")
            .updateChildValues([current_uid + "/current_room": NSNull()])
        
        self.myRootRef.childByAppendingPath("members")
            .childByAppendingPath(self.roomCode).childByAppendingPath(current_uid).removeValue()
        
        
        
        myRootRef.childByAppendingPath("members").childByAppendingPath(self.roomCode)
            .observeSingleEventOfType(.Value, withBlock: { snapshot in
                if((snapshot.value is NSNull)){
                    //no more members in the group
                   self.destroyRoom(self.roomCode)
                }
                else {
                    //check to see if current user is the admin of that group
                    if(self.admin == current_uid) {
                        //if we are the admin, appoint new admin
                        self.appointNewAdmin(self.roomCode)
                        self.performSegueWithIdentifier("HomeViewController", sender:self)
                    }
                    else {
                        self.performSegueWithIdentifier("HomeViewController", sender:self)
                    }
                }
            })
        
        
    }
    
    func appointNewAdmin(roomCode : String) {
        self.myRootRef.childByAppendingPath("members").childByAppendingPath(roomCode)
            .observeSingleEventOfType(.Value, withBlock: {snapshot in
                let child: FDataSnapshot = snapshot.children.nextObject() as! FDataSnapshot
                self.myRootRef.childByAppendingPath("rooms").childByAppendingPath(roomCode).childByAppendingPath("admin")
                    .setValue(child.key)
                self.songTimer.invalidate()
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
    
    func showMessagesMissed() {
        messagesMissing = messagesMissing > 10 ? 10 : messagesMissing
        let num = messagesMissing + 10101
        let unicodeChar = Character(UnicodeScalar(num))
        let toAdd = messagesMissing >= 10 ? "\(unicodeChar)" + "+" : "\(unicodeChar)"
        messagesButton.setTitle("\(toAdd)" + " Messages", forState: .Normal)
    }
    
    @IBAction func songsButtonPressed(sender: AnyObject) {
        inMessages = false
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
        messagesButton.setTitle("Messages", forState: .Normal)
        inMessages = true
        messagesMissing = 0
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
        timeoutTimer.invalidate()
        timeoutTimer = NSTimer.scheduledTimerWithTimeInterval(300.0, target:self, selector: #selector(RoomViewController.leaveRoom), userInfo: nil, repeats: false)
    }
    
    func myForegroundObserverMethod(notification: NSNotification){
        print("Application is now in foreground")
        timeoutTimer.invalidate()
     }
}