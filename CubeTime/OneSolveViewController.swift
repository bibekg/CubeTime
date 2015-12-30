//
//  OneSolveViewController.swift
//  CubeTime
//
//  Created by Bibek Ghimire on 12/22/15.
//  Copyright © 2015 Bibek. All rights reserved.
//

import UIKit
import Foundation

let attributesCount = 4;

class OneSolveViewController: UIViewController, UITableViewDataSource {
    
    var date = NSDate()
    var time: Double = 0
    var scramble: String = ""
    var inspectionTime: Int32 = 0
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return attributesCount - 1
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("OneSolveCell")
        switch indexPath.row {
        case 0: cell?.textLabel?.text = String("\(time) seconds")
        case 1: cell?.textLabel?.text = String(scramble)
        case 2:
            if inspectionTime != 0 {
                cell?.textLabel?.text = "\(inspectionTime) second inspection"
            } else {
                cell?.textLabel?.text = "No inspection"
            }
        default: cell?.textLabel?.text = "ERROR: EXTRA CELL CREATED"
        }
        return cell!
    }
    
    // Sets table view's section header as the date/time of solve
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return cleanDate(date)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = String(time)
    }
}