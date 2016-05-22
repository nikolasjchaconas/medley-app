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
    var tableArray = [String]()
    
    @IBOutlet var tableReference: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myRootRef.childByAppendingPath("users").childByAppendingPath(myRootRef.authData.uid).childByAppendingPath("current_room")
            .observeSingleEventOfType(.Value, withBlock: {snapshot in
                let roomCode = (snapshot.value as? String)!
                self.setTable(roomCode)
            })
    }
    
    func setTable(roomCode : String) {
        self.tableArray = ["RoomCode " + "\"" + roomCode + "\""  , "Share the code!"]
        self.tableArray.append("Members:")
        self.showMembers(roomCode)
        tableReference.reloadData()
    }
    
    func showMembers(roomCode : String) {
        myRootRef.childByAppendingPath("members").childByAppendingPath(roomCode)
        .observeEventType(.ChildAdded, withBlock: { snapshot in
            self.appendMember((snapshot.value as? String)!)
            }, withCancelBlock: { error in
                print(error.description)
        })
        
        myRootRef.childByAppendingPath("members").childByAppendingPath(roomCode)
            .observeEventType(.ChildRemoved, withBlock: { snapshot in
                self.removeMember((snapshot.value as? String)!)
                }, withCancelBlock: { error in
                    print(error.description)
            })
    }
    
    func appendMember(username : String) {
        tableArray.append(username)
        tableReference.reloadData()
    }
    
    func removeMember(username : String) {
        let index = tableArray.indexOf(username)
        if (index != nil) {
            tableArray.removeAtIndex(index!)
        }
        tableReference.reloadData()

    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableArray.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier("myCell", forIndexPath: indexPath)
        cell.textLabel!.text = tableArray[indexPath.row]
        cell.textLabel?.textAlignment = .Right
        return cell
    }
}
