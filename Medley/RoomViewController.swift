//
//  RoomViewController.swift
//  Medley
//
//  Created by Nikolas Chaconas on 4/26/16.
//  Copyright © 2016 Medley Team. All rights reserved.
//

import UIKit
import Firebase
import youtube_ios_player_helper

class RoomViewController: UIViewController, YTPlayerViewDelegate, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var chatBar: UITextField!
    
    @IBOutlet weak var searchForSongsTitle: UILabel!
    @IBOutlet weak var chatBox: UIScrollView!
    
    @IBOutlet weak var leaveRoomButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var videoLoadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var playerView: YTPlayerView!
    
    @IBOutlet weak var syncVideoForwardButton: UIButton!
    @IBOutlet weak var syncVideoBackwardButton: UIButton!
    @IBOutlet weak var resyncVideoButton: UIButton!
    
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchIndicatorView: UIView!
    var songList: Array<(String, String)> = []
    var currentRoomSong: Bool = false
    var YTSearch : YouTubeSearch = YouTubeSearch()
    var roomCode : String!
    var username : String!
    var admin : String!
    var currentSongIndex : Int = 0
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
    var searchTimer : NSTimer = NSTimer()
    var songTimer : NSTimer = NSTimer()
    var waiting : Bool = false
    var firstTime : Bool = true
    var timeoutTimer :  NSTimer = NSTimer()
    var messagesMissing : Int = 0
    var inMessages : Bool = true
    
    @IBOutlet weak var videoTapView: UIView!
    @IBOutlet weak var searchBar: UITextField!
    @IBOutlet weak var songBox: UIScrollView!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var songsButton: UIButton!
    @IBOutlet weak var messagesButton: UIButton!
    
    @IBOutlet weak var disableKeyboardView: UIView!
    
    var lighterGrey = UIColor(red: 190/255, green: 190/255, blue: 190/255, alpha: 1.0)
    var highlightedButton = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1.0)
    var grey = UIColor(red: 100/255, green: 100/255, blue: 100/255, alpha: 1.0)
    
    
    
    let blackGrad = CAGradientLayer().blackGradient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Add black gradient
        self.blackGrad.frame = self.view.bounds
        self.view.layer.addSublayer(blackGrad)
        
        self.chatBar.layer.addBorder(UIRectEdge.Top, color: lighterGrey,
                                     thickness: 1.0, width: chatBar.frame.width, height: 50)
        self.searchBar.layer.addBorder(UIRectEdge.Top, color: lighterGrey,
                                       thickness: 1.0, width: self.view.frame.width, height : 50)
        
        self.sendButton.layer.addBorder(UIRectEdge.Top, color: lighterGrey,
                                        thickness: 1.0, width: 55.0, height: 50)
        
        //Highlight playlist button by default
        self.songsButton.layer.backgroundColor = self.highlightedButton.CGColor
        
        //Center button labels
        self.messagesButton.titleLabel?.textAlignment = NSTextAlignment.Center
        self.songsButton.titleLabel?.textAlignment = NSTextAlignment.Center
        

        tableView.layer.addBorder(UIRectEdge.Top, color: lighterGrey,
                                  thickness: 0.5, width: self.view.frame.width, height: tableView.frame.height)
        
        
        tableView.delegate = self
        tableView.dataSource = self
        playerView.delegate = self
        
        //more customizations for this can be found here
        //http://www.ebc.cat/2015/03/07/customize-your-swrevealviewcontroller-slide-out-menu/
        self.revealViewController().rightViewRevealWidth = self.view.frame.width - 40
        self.revealViewController().rightViewRevealDisplacement = self.view.frame.width - 55
        self.searchIndicatorView.hidden = true
        self.searchBar.addTarget(self, action: #selector(songSearchChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        self.searchBar.addTarget(self, action: #selector(searchBarTapped(_:)), forControlEvents: UIControlEvents.EditingDidBegin)
        self.searchBar.addTarget(self, action: #selector(searchBarGone(_:)), forControlEvents: UIControlEvents.EditingDidEnd)
        self.disableKeyboardView.hidden = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(RoomViewController.hideKeyboardForSearch(_:)))
        
        let tap2 = UITapGestureRecognizer(target: self, action:
            #selector(RoomViewController.playerViewTapped(_:)))
        
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(RoomViewController.hideKeyboardForSearch(_:)))
        swipeDown.direction = UISwipeGestureRecognizerDirection.Down
        
        
        disableKeyboardView.addGestureRecognizer(swipeDown)
        disableKeyboardView.addGestureRecognizer(tap)
        videoTapView.addGestureRecognizer(tap2)
        
        //Observer for listening to when application enters background
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RoomViewController.myBackgroundObserverMethod(_:)), name:UIApplicationDidEnterBackgroundNotification, object: nil)
        //Observer for listening to when application enters foreground
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RoomViewController.myForegroundObserverMethod(_:)), name:UIApplicationWillEnterForegroundNotification, object: nil)
        
        
        
        chatBoxHeight = chatBox.frame.height
        chatBarConstraint = NSLayoutConstraint(item: chatBar, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute:NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0)
        
        songsButton.setTitleColor(grey, forState: .Normal)
        messagesButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        
        view.addConstraint(chatBarConstraint)
        // Do any additional setup after loading the view, typically from a nib.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RoomViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RoomViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        //self.hideKeyboardOnTap()
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
        
        }
    
        func checkSeek(roomCode : String) {
            let ref3 = self.myRootRef.childByAppendingPath("rooms")
            .childByAppendingPath(roomCode).childByAppendingPath("currentSongIndex")
                ref3.observeEventType(.Value, withBlock: {snapshot in
                    self.currentSongIndex = (snapshot.value as? Int)!
                })
            let ref2 = self.myRootRef.childByAppendingPath("rooms")
                .childByAppendingPath(roomCode).childByAppendingPath("song_time")
            self.observers.append(ref2)
            self.observers.append(ref3)
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
                        self.waiting = true
                        self.playerView.playVideo()
                        self.seekAmount = 0
                        self.syncVideoByAmount()
                    }
                    else if(state == "paused") {
                        self.playerView.pauseVideo()
                    } else if (state == "ended") {
                        //this is kind of optional
                        self.playerView.stopVideo()
                    }
                }
                
            })
        }
    
        func playOrPauseVideo() {
            if playerView.playerState() != YTPlayerState.Playing {
                myRootRef.childByAppendingPath("rooms")
                    .childByAppendingPath(self.roomCode).childByAppendingPath("song_state")
                    .setValue("playing")
                playerView.playVideo()
                playButton.setTitle("Pause", forState: .Normal)
            } else {
                myRootRef.childByAppendingPath("rooms")
                    .childByAppendingPath(self.roomCode).childByAppendingPath("song_state")
                    .setValue("paused")
                playerView.pauseVideo()
                playButton.setTitle("Play", forState: .Normal)
            }
        }
        //delegates
    
        func playerViewDidBecomeReady(playerView: YTPlayerView) {
            self.highlightCurrentSong()
            if(myRootRef.authData.uid != self.admin) {
                if(firstTime == true) {
                    firstTime = false
                    songState(self.roomCode)
                }
                if(waiting == true) {
                    waiting = false
                    self.videoLoadingIndicator.stopAnimating()
                    self.playerView.playVideo()
                    self.syncVideoByAmount()
                }
                
            } else {
                if(waiting == true) {
                    waiting = false
                    self.videoLoadingIndicator.stopAnimating()
                    self.playOrPauseVideo()
                }
            }
        }
    
        func playerView(playerView: YTPlayerView, didChangeToState state: YTPlayerState) {
            if(state == YTPlayerState.Ended) {
                seekAmount = 0
            }
            if(myRootRef.authData.uid == self.admin) {
                if(self.playerView.playerState() == YTPlayerState.Paused) {
                    songTimer.invalidate()
                } else if (state == YTPlayerState.Playing) {
                    songTimer.invalidate()
                    songTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(setSongTime), userInfo: nil, repeats: true)
                } else if(state == YTPlayerState.Ended) {
                    playNextSong()
                    songTimer.invalidate()
                    playButton.setTitle("Play", forState: .Normal)
                    myRootRef.childByAppendingPath("rooms")
                        .childByAppendingPath(self.roomCode).childByAppendingPath("song_playing")
                        .setValue(false)
                    myRootRef.childByAppendingPath("rooms")
                        .childByAppendingPath(self.roomCode).childByAppendingPath("song_state")
                        .setValue("ended")
                    myRootRef.childByAppendingPath("rooms").childByAppendingPath(self.roomCode)
                        .childByAppendingPath("song_time").setValue(0)
                }
            }
            
        }
    
        func playNextSong() {
            //we're not at the end of playlist
            if(songList.count > currentSongIndex) {
                
                let nextVideo = [songList[currentSongIndex].0 : songList[currentSongIndex].1]
                
                myRootRef.childByAppendingPath("rooms").childByAppendingPath(roomCode)
                        .childByAppendingPath("current_song").setValue(nextVideo)
                //terrible but only way to get event to fire
                myRootRef.childByAppendingPath("rooms").childByAppendingPath(roomCode)
                    .childByAppendingPath("song_state").setValue("garbage")
                myRootRef.childByAppendingPath("rooms").childByAppendingPath(roomCode)
                .childByAppendingPath("song_state").setValue("playing")
                
                myRootRef.childByAppendingPath("rooms").childByAppendingPath(self.roomCode)
                .childByAppendingPath("currentSongIndex").setValue(currentSongIndex + 1)
                
                waiting = true
            }
        }
    
        func playPreviousSong() {
            //we're not at the beginning
            if(currentSongIndex - 2 >= 0) {
                
                let nextVideo = [songList[currentSongIndex - 2].0 : songList[currentSongIndex - 2].1]

                myRootRef.childByAppendingPath("rooms").childByAppendingPath(roomCode)
                    .childByAppendingPath("current_song").setValue(nextVideo)
                //terrible but only way to get event to fire
                myRootRef.childByAppendingPath("rooms").childByAppendingPath(roomCode)
                    .childByAppendingPath("song_state").setValue("garbage")
                myRootRef.childByAppendingPath("rooms").childByAppendingPath(roomCode)
                    .childByAppendingPath("song_state").setValue("playing")
                
                myRootRef.childByAppendingPath("rooms").childByAppendingPath(self.roomCode)
                    .childByAppendingPath("currentSongIndex").setValue(currentSongIndex - 1)
                
                waiting = true
            }
        }
    
        func highlightCurrentSong() {
            var padding = 0
            var i = 1
            while(i != songList.count + 1) {
                print(NSStringFromClass(songBox.subviews[i + padding].classForCoder))
                if(NSStringFromClass(songBox.subviews[i + padding].classForCoder) == "UILabel") {
                    let newLabel = songBox.subviews[i + padding] as! UILabel
                    let newText = newLabel.text!
                    if(i == currentSongIndex) {
                        newLabel.attributedText = NSMutableAttributedString(string:newText, attributes: [NSFontAttributeName : UIFont.boldSystemFontOfSize(18)])
                    } else {
                        newLabel.attributedText = NSMutableAttributedString(string: newText, attributes: [NSForegroundColorAttributeName : UIColor.blackColor()])
                    }
                i += 1
                } else {
                    padding += 1
                }
            
            }

        }

        func adminChange(roomCode : String, username : String) {
            let ref = myRootRef.childByAppendingPath("rooms")
                .childByAppendingPath(roomCode).childByAppendingPath("admin")
            observers.append(ref)
            ref.observeEventType(.Value, withBlock: {snapshot in
                self.admin = (snapshot.value as? String)!
                if(self.myRootRef.authData.uid == (snapshot.value as? String)!) {
                    if(self.playerView.playerState() == YTPlayerState.Playing) {
                        self.playButton.setTitle("Pause", forState: .Normal)
                        self.songTimer.invalidate()
                        self.songTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(self.setSongTime), userInfo: nil, repeats: true)
                    }
                    self.seekAmount = 0
                    self.songStateRef.removeAllObservers()
                    self.playButton.alpha = 1.0
                    self.nextButton.alpha = 1.0
                    self.previousButton.alpha = 1.0
                    self.syncVideoForwardButton.alpha = 0.0
                    self.syncVideoBackwardButton.alpha = 0.0
                    self.resyncVideoButton.alpha = 0.0
                    self.videoTapView.alpha = 1.0
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
                    self.resyncVideoButton.alpha = 1.0
                    self.videoTapView.alpha = 0.0
                }
            })
        }
        
        
        @IBAction func playButtonPressed(sender: AnyObject) {
            pressPlayButton()
        }
        
        func pressPlayButton() {
            if(self.songPresent == true) {
                if(playerView.playerState() == YTPlayerState.Buffering || YTPlayerState.Unknown == playerView.playerState()) {
                    self.videoLoadingIndicator.startAnimating()
                    self.waiting = true
                } else {
                    self.playOrPauseVideo()
                }
            }
        }
        func setSongTime() {
            self.songTime = playerView.currentTime()
            myRootRef.childByAppendingPath("rooms").childByAppendingPath(self.roomCode)
                .childByAppendingPath("song_time").setValue(self.songTime)
        }
        
        @IBAction func nextButtonPressed(sender: AnyObject) {
            playNextSong()
        }
        @IBAction func previousButtonPressed(sender: AnyObject) {
            playPreviousSong()
        }
        
        @IBAction func resyncVideoButtonPressed(sender: AnyObject) {
            if(playerView.playerState() == YTPlayerState.Playing) {
                seekAmount = 0
                syncVideoByAmount()
            }
            
        }
        @IBAction func syncVideoForwardButtonPressed(sender: AnyObject) {
            if(playerView.playerState() == YTPlayerState.Playing) {
                seekAmount += 0.1
                syncVideoByAmount()
            }
        }
        
        @IBAction func syncVideoBackwardButtonPressed(sender: AnyObject) {
            if(playerView.playerState() == YTPlayerState.Playing) {
                seekAmount -= 0.1
                syncVideoByAmount()
            }
        }
        
        func syncVideoByAmount() {
            playerView.seekToSeconds(songTime + 0.5 + seekAmount, allowSeekAhead: true)
        }
        
        func currentSong(roomCode : String) {
            let ref = myRootRef.childByAppendingPath("rooms").childByAppendingPath(roomCode).childByAppendingPath("current_song")
            self.observers.append(ref)
            ref.observeEventType(.Value, withBlock: {snapshot in
                if(snapshot.value is NSNull) {
                    self.currentRoomSong = false
                    self.songPresent = false
                } else {
                    self.songPresent = true
                    let snapshotObj = snapshot.children.nextObject() as! FDataSnapshot
                    self.loadVideo((snapshotObj.value as? String)!)
                }
                
            })
        }
        
        func loadVideo(videoID : String) {
            let playerVars = [
                "playsinline" : "1",
                "showinfo" : "0",
                "rel" : "0",
                "modestbranding" : "1",
                "controls" : "0",
                "origin" : "https://www.example.com",
                "start" : String(songTime)
            ]
            
            
            playerView.loadWithVideoId(videoID, playerVars:  playerVars)
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
            self.roomCode = roomCode
            addSongMessages();
            let ref = myRootRef.childByAppendingPath("songs").childByAppendingPath(roomCode)
            observers.append(ref)
            let errorMessage = "\nThere are currently no videos in the playlist.\n Search in the toolbar to add some!"
            self.appendSong(errorMessage, error : 1, songID: " ")
            ref.observeEventType(.ChildAdded, withBlock: { snapshot in
                let snapshotObj = snapshot.children.nextObject() as! FDataSnapshot
                self.appendSong(snapshotObj.key, error : 0, songID: (snapshotObj.value as? String)!)
            })
        }
        
        func appendSong(songName : String, error : Int, songID : String) {
            songCount += 1
            var text : String
            var label : UILabel
            
            if(error == 0) {
                let subview : UILabel = songBox.subviews.last as! UILabel
                let newSong = [
                    songName : songID
                ]
                if(subview.text == "\nThere are currently no videos in the playlist.\n Search in the toolbar to add some!") {
                    subview.removeFromSuperview()
                }
                if(songCount == 1) {
                    myRootRef.childByAppendingPath("rooms").childByAppendingPath(self.roomCode)
                        .childByAppendingPath("admin")
                        .observeSingleEventOfType(.Value, withBlock: {snapshot in
                            if((snapshot.value as? String)! == self.myRootRef.authData.uid) {                                self.myRootRef.childByAppendingPath("rooms").childByAppendingPath(self.roomCode).childByAppendingPath("currentSongIndex").setValue(1)
                                
                                self.waiting = true
                                self.myRootRef.childByAppendingPath("rooms").childByAppendingPath(self.roomCode)
                                    .childByAppendingPath("current_song").setValue(newSong)
                            }
                            
                            
                        })
                }
                
                
                songList.append((songName, songID))
                let textBoxWidth : CGFloat = 35.0
                text = String(songCount) + ". " + songName
                var rect = CGRectMake(0, 0, self.songBox.bounds.size.width, textBoxWidth)
                rect.origin.y = textBoxWidth * CGFloat(self.songCount)
                label = UILabel(frame: rect)
                label.numberOfLines = 1
                label.textAlignment = NSTextAlignment.Left
            } else {
                songCount -= 1
                let textBoxWidth : CGFloat = 80.0
                text = songName
                var rect = CGRectMake(0, 0, self.songBox.bounds.size.width, textBoxWidth)
                rect.origin.y = textBoxWidth * CGFloat(self.songCount)
                label = UILabel(frame: rect)
                label.numberOfLines = 2
                label.textAlignment = NSTextAlignment.Center
            }
            
            label.layer.borderWidth = 1
            label.layer.borderColor = (UIColor.whiteColor()).CGColor
            
            let message : NSMutableAttributedString
            if(songCount == 1) {
                message = NSMutableAttributedString(string:text, attributes: [NSFontAttributeName : UIFont.boldSystemFontOfSize(18)])
            } else {
                message = NSMutableAttributedString(string: text, attributes: [NSForegroundColorAttributeName : UIColor.blackColor()])
            }
            self.songBox.contentSize =
                CGSizeMake(self.view.bounds.width, 35.0 * CGFloat(self.songCount + 1))
            
            label.attributedText = message
            self.songBox.addSubview(label)
        }
        
        func addSongMessages() {
            let textBoxWidth : CGFloat = 35
            var rect = CGRectMake(0, 0, self.songBox.bounds.size.width, textBoxWidth)
            rect.origin.y = 0
            let label = UILabel(frame: rect)
            label.layer.borderWidth = 1
            label.layer.borderColor = (UIColor.whiteColor()).CGColor
            label.numberOfLines = 1
            
            label.textAlignment = NSTextAlignment.Center
            let text = "Current Video Playlist:"
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
                    self.chatBox.contentSize = CGSizeMake(self.view.bounds.width, 20 * self.totalLines)
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
        
        func leaveRoom () {
            let newMessage : [String : String] = [
                self.username : ""
            ]
            playerView.stopVideo()
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
            if(songBox.bounds.height < 20 * self.totalLines) {
                UIView.animateWithDuration(0.5, animations: {
                    self.chatBox.setContentOffset(CGPointMake(0, self.chatBox.contentSize.height - self.chatBox.bounds.size.height), animated: false)
                })
            }
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
            messagesButton.setTitle("\(toAdd)" + " Chat Room", forState: .Normal)
        }
        
        @IBAction func songsButtonPressed(sender: AnyObject) {
            self.songsButton.layer.backgroundColor = UIColor.whiteColor().CGColor
            self.messagesButton.layer.backgroundColor = self.highlightedButton.CGColor
            inMessages = false
            self.hideKeyboard()
            songsButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
            messagesButton.setTitleColor(grey, forState: .Normal)
            UIView.animateWithDuration(0.3, animations: {
                self.searchBar.alpha = 1.0
                self.chatBox.alpha = 0.0
                self.songBox.alpha = 1.0
                self.chatBar.alpha = 0.0
                self.sendButton.alpha = 0.0
            })
        }
        
        @IBAction func messagesButtonPressed(sender: AnyObject) {
            self.messagesButton.layer.backgroundColor = UIColor.whiteColor().CGColor
            self.songsButton.layer.backgroundColor = self.highlightedButton.CGColor
            messagesButton.setTitle("Chat Room", forState: .Normal)
            inMessages = true
            messagesMissing = 0
            self.hideKeyboard()
            messagesButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
            songsButton.setTitleColor(grey, forState: .Normal)
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
            self.hideKeyboard()
            timeoutTimer.invalidate()
            timeoutTimer = NSTimer.scheduledTimerWithTimeInterval(300.0, target:self, selector: #selector(RoomViewController.leaveRoom), userInfo: nil, repeats: false)
        }
        
        func myForegroundObserverMethod(notification: NSNotification){
            print("Application is now in foreground")
            seekAmount = 0
            syncVideoByAmount()
            timeoutTimer.invalidate()
         }
        
        //Youtube search
        func doQuery() {
            songTimer.invalidate()
            if(searchBar.text! != "") {
                YTSearch.query(searchBar.text!, tableView: tableView, viewWait: searchIndicatorView)
            } else {
                searchIndicatorView.hidden = true
            }
        }
    
        func songSearchChange(sender : UITextField) {
            searchIndicatorView.hidden = false
            songTimer.invalidate()
            songTimer = NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: #selector(doQuery), userInfo: nil, repeats: true)
            
        }
        
        func searchBarTapped(sender : UITextField) {
            self.leaveRoomButton.alpha = 0.0
            self.menuButton.alpha = 0.0
            tableView.reloadData()
            UIView.animateWithDuration(0.20, animations: {
                self.tableView.alpha = 1.0
            })
            disableKeyboardView.hidden = false
        }
        
        func searchBarGone(sender : UITextField) {
            self.searchBar.text = ""
            self.leaveRoomButton.alpha = 1.0
            self.menuButton.alpha = 1.0
            UIView.animateWithDuration(0.20, animations: {
                self.tableView.alpha = 0.0
            })
            disableKeyboardView.hidden = true
            YTSearch.videosArray.removeAll(keepCapacity: false)
        }

        
        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return YTSearch.videosArray.count
        }
        
        func numberOfSectionsInTableView(tableView: UITableView) -> Int {
            return 1
        }
        
        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

            var cell: UITableViewCell!
            cell = tableView.dequeueReusableCellWithIdentifier("idCellVideo", forIndexPath: indexPath)
            
            let videoTitle = cell.viewWithTag(10) as! UILabel
            let videoThumbnail = cell.viewWithTag(11) as! UIImageView
            let videoDetails = YTSearch.videosArray[indexPath.row]
            videoTitle.text = videoDetails["title"] as? String
            videoThumbnail.image = UIImage(data: NSData(contentsOfURL: NSURL(string: (videoDetails["thumbnail"] as? String)!)!)!)
        
            return cell
        }
        
        func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
            return 70.0
        }
        
        func hideKeyboardForSearch(sender: UITapGestureRecognizer? = nil) {
            self.hideKeyboard()
            disableKeyboardView.hidden = true
        }
        
        func playerViewTapped(sender: UITapGestureRecognizer? = nil) {
            pressPlayButton()
        }
        
        //when a song option is tapped
        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            
            let songName : String = (YTSearch.videosArray[indexPath.row]["title"] as? String)!
            let songID : String = (YTSearch.videosArray[indexPath.row]["videoID"] as? String)!
            
            let newSong = [
                removeSpecialCharsFromString(songName) : songID
            ]
            
            
            searchBar.text = ""
            self.hideKeyboard()
            myRootRef.childByAppendingPath("songs").childByAppendingPath(roomCode)
            .childByAppendingPath(String(songCount + 1)).setValue(newSong)
        }
        
        func removeSpecialCharsFromString(text: String) -> String {
            let badChars : Set<Character> =
                Set("/.#$[]".characters)
            return String(text.characters.filter {!(badChars.contains($0)) })
        }

}