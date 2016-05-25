//
//  SlideOutMenuViewController.swift
//  Medley
//
//  Created by Nikolas Chaconas on 5/12/16.
//  Copyright © 2016 Medley Team. All rights reserved.
//

import UIKit
import Firebase

class SlideOutMenuViewController: UITableViewController {
    var myRootRef = Firebase(url:"https://crackling-heat-1030.firebaseio.com/")
    var tableArray = [NSMutableAttributedString]()
    var observers = [Firebase]()
    
    @IBOutlet var tableReference: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myRootRef.childByAppendingPath("users").childByAppendingPath(myRootRef.authData.uid).childByAppendingPath("current_room")
            .observeSingleEventOfType(.Value, withBlock: {snapshot in
                let roomCode = (snapshot.value as? String)!
                self.setTable(roomCode)
            })
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        var frame = self.view.frame;
        frame.origin.x = 60
        self.view.frame = frame
    }
    
    func setTable(roomCode : String) {
        let text = makeMutableString("Room Code: ")
        let stylizedCode = makeBoldMutableString(roomCode)
        text.appendAttributedString(stylizedCode)
        self.tableArray = [text]
        self.tableArray.append(makeMutableString("Share the code with Friends!"))
        self.tableArray.append(makeMutableString(""))
        self.tableArray.append(makeMutableString("Current Members:"))
        self.showMembers(roomCode)
        tableReference.reloadData()
    }
    
    func makeMutableString(text : String) -> NSMutableAttributedString {
        return NSMutableAttributedString(string: text, attributes: [NSForegroundColorAttributeName : UIColor.blackColor()])
    }
    
    func makeBoldMutableString(text : String) -> NSMutableAttributedString {
        return NSMutableAttributedString(string:text, attributes: [NSFontAttributeName : UIFont.boldSystemFontOfSize(16)])
    }
    func showMembers(roomCode : String) {
        let observer1 =
        myRootRef.childByAppendingPath("members").childByAppendingPath(roomCode)
        observers.append(observer1)
            observer1.observeEventType(.ChildAdded, withBlock: { snapshot in
            let value = self.makeBoldMutableString("   " + (snapshot.value as? String)!)
            self.appendMember(value)
            }, withCancelBlock: { error in
                print(error.description)
        })
        
        myRootRef.childByAppendingPath("members").childByAppendingPath(roomCode)
            .observeEventType(.ChildRemoved, withBlock: { snapshot in
                let value = self.makeBoldMutableString("   " + (snapshot.value as? String)!)
                self.removeMember(value)
                }, withCancelBlock: { error in
                    print(error.description)
            })
    }
    
//    override func viewWillDisappear(animated: Bool) {
//        self.removeAllObservers()
//    }
    
    func appendMember(username : NSMutableAttributedString) {
        tableArray.append(username)
        tableReference.reloadData()
    }
    
    func removeMember(username : NSMutableAttributedString) {
        let index = tableArray.indexOf(username)
        if (index != nil) {
            tableArray.removeAtIndex(index!)
        }
        tableReference.reloadData()
    }
    
    func removeAllObservers() {
        for observer in observers {
            observer.removeAllObservers()
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableArray.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier("myCell", forIndexPath: indexPath)
        cell.textLabel!.attributedText = tableArray[indexPath.row]
        cell.textLabel?.textAlignment = .Left
        return cell
    }
}
