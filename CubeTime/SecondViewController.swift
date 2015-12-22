//
//  SecondViewController.swift
//  CubeTime
//
//  Created by Bibek Ghimire on 8/5/15.
//  Copyright (c) 2015 Bibek. All rights reserved.
//

import UIKit
import CoreData

class SecondViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITabBarDelegate {
    
    var solves = [NSManagedObject]()
    var managedContext: NSManagedObjectContext? = nil
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
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
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return solves.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell")
        let solve = solves[indexPath.row]
        let time = solve.valueForKey("time") as! Double
//        cell!.textLabel!.text = String((round(time*100)/100))
        cell!.textLabel!.text = String(time)
        return cell!
    }
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            deleteSolveIndexPath = indexPath
            let solveToDelete = solves[indexPath.row]
            confirmDelete(solveToDelete)
        }
    }
    
    // Delete Solve Functions //
    var deleteSolveIndexPath: NSIndexPath? = nil
    func confirmDelete(solve: NSManagedObject) {
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
            
            let solveToDelete = solves[indexPath.row]
            self.managedContext?.deleteObject(solveToDelete)
            solves.removeAtIndex(indexPath.row)
            do {
                try self.managedContext?.save()
            } catch {
                print("Post-delete save failed")
            }
            
            // Note that indexPath is wrapped in an array:  [indexPath]
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            deleteSolveIndexPath = nil
            
            tableView.endUpdates()
        }
    }
    func cancelDeleteSolve(alertAction: UIAlertAction!) {
        deleteSolveIndexPath = nil
    }
    
    
    //---------------------------------//
    //------- Default Functions -------//
    //---------------------------------//
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Previous Solves"
        self.editButton.style = UIBarButtonItemStyle.Plain
        self.editButton.title = "Edit"
        self.tableView.editing = false
    }
    override func viewWillAppear(animated: Bool) {

        // Core Data Prep
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Solve")
        do {
            let results = try managedContext!.executeFetchRequest(fetchRequest)
            solves = results as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        self.tableView.reloadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
