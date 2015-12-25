//
//  TableViewController.swift
//  CubeTime
//
//  Created by Bibek Ghimire on 8/5/15.
//  Copyright (c) 2015 Bibek. All rights reserved.
//

import UIKit

class TableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITabBarDelegate {
    
    var sortStyle = String()
    var solves = Solves()
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    // Statistics Labels
    @IBOutlet weak var bestTimeLabel: UILabel!
    @IBOutlet weak var worstTimeLabel: UILabel!
    @IBOutlet weak var averageAllLabel: UILabel!
    @IBOutlet weak var averageFiveLabel: UILabel!
    
    @IBAction func editPressed(sender: UIBarButtonItem) {
        if (!self.tableView.editing) {
            self.tableView.editing = true
            self.navigationItem.rightBarButtonItem! = UIBarButtonItem(title: "Done", style: .Done, target: self, action: "editPressed:")
        } else {
            self.tableView.editing = false
            self.navigationItem.rightBarButtonItem! = UIBarButtonItem(title: "Edit", style: .Plain, target: self, action: "editPressed:")
        }
    }
    
    //--------------------------//
    //------- Table View -------//
    //--------------------------//
    
    var deleteSolveIndexPath: NSIndexPath? = nil
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return solves.dateSortedList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TimeCell")
        let solve = solves.dateSortedList[indexPath.row]
        let time = solve.valueForKey("time") as! Double
        let date = solve.valueForKey("date") as! NSDate
        
        cell!.textLabel!.text = String(time)
        cell!.detailTextLabel!.text = String(cleanDate(date))
        
        return cell!
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            deleteSolveIndexPath = indexPath
            confirmDelete()
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if (solves.dateSortedList.count != 0) {
            return "\(solves.dateSortedList.count) solves"
        }
        return "No solves yet. Start cubing!"
        
    }
    
    //----------------------------//
    //------- Delete Solve -------//
    //----------------------------//
    
    func confirmDelete() {
        let alert = UIAlertController(title: "Delete Solve", message: "Are you sure you want to permanently delete this solve?", preferredStyle: .ActionSheet)
        
        // Edit what the alert asks to be more specific so user knows what he/she is deleting
        
        let DeleteAction = UIAlertAction(title: "Delete", style: .Destructive, handler: handleDeleteSolve)
        let CancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: cancelDeleteSolve)
        
        alert.addAction(DeleteAction)
        alert.addAction(CancelAction)
        
        // Support display in iPad
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = CGRectMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func handleDeleteSolve(alertAction: UIAlertAction!) -> Void {
        if let indexPath = deleteSolveIndexPath {
            tableView.beginUpdates()
            
            solves.deleteSolve(indexPath)
            // Note that indexPath is wrapped in an array:  [indexPath]
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            deleteSolveIndexPath = nil
            setStatistics()
            
            tableView.endUpdates()
        }
    }
    
    func cancelDeleteSolve(alertAction: UIAlertAction!) {
        deleteSolveIndexPath = nil
    }
    
    //---------------------//
    //------- Segue -------//
    //---------------------//
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "viewSolveSegue" {
            if let destination = segue.destinationViewController as? OneSolveViewController {
                if let solveIndex = tableView.indexPathForSelectedRow?.row {
                    let solve = solves.dateSortedList[solveIndex]
                    destination.date = solve.valueForKey("date") as! NSDate
                    destination.time = solve.valueForKey("time") as! Double
                    destination.scramble = solve.valueForKey("scramble") as! String
                }
            }
        }
    }
    
    //---------------------------------//
    //------- Default Functions -------//
    //---------------------------------//
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Previous Solves"
        sortStyle = "date"
    }
    
    override func viewWillAppear(animated: Bool) {
        solves.downloadByAscendingTimes()
        self.tableView.reloadData()
        
        setStatistics()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setStatistics() {
        solves.downloadByAscendingTimes()
        solves.downloadByDate()
        
        let total = solves.dateSortedList.count
        let bestTime = solves.timeSortedList[0].valueForKey("time") as! Double
        let worstTime = solves.timeSortedList[solves.timeSortedList.count - 1].valueForKey("time") as! Double
        var totalSum = 0.0
        var fiveSum = 0.0
        for (var i = 0; i < total; i++) {
            if (i < 5) {
                fiveSum += solves.dateSortedList[i].valueForKey("time") as! Double
            }
            totalSum += solves.dateSortedList[i].valueForKey("time") as! Double
        }
        
        self.bestTimeLabel.text = "Best time: " + String(bestTime)
        self.worstTimeLabel.text = "Worst time: " + String(worstTime)
        self.averageAllLabel.text = "Average (all): " + String(format: "%.2f", totalSum/Double(total))
        self.averageFiveLabel.text = "Average (last 5): " + String(format: "%.2f", fiveSum/min(Double(total), 5.0))
    }
}

// Global function used by this and OneSolveViewController to get human-readable date
func cleanDate(date: NSDate) -> String {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "MMM dd, yyyy, h:mm a"
    let dateString = dateFormatter.stringFromDate(date)
    return String(dateString)
}


