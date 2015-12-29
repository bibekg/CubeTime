//
//  Solves.swift
//  CubeTime
//
//  Created by Bibek Ghimire on 12/24/15.
//  Copyright © 2015 Bibek. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Solves: NSManagedObject {

    var displayList = [NSManagedObject]()
    
    var dateSortedList = [NSManagedObject]()
    var timeSortedList = [NSManagedObject]()
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    func downloadByDate() {
        let managedContext = appDelegate.managedObjectContext
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        let sortDescriptors = [sortDescriptor]
        let fetchRequest = NSFetchRequest(entityName: "Solve")
        fetchRequest.sortDescriptors = sortDescriptors
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            dateSortedList = results as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    func downloadByTime() {
        let managedContext = appDelegate.managedObjectContext
        let sortDescriptor = NSSortDescriptor(key: "time", ascending: true)
        let sortDescriptors = [sortDescriptor]
        let fetchRequest = NSFetchRequest(entityName: "Solve")
        fetchRequest.sortDescriptors = sortDescriptors
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            timeSortedList = results as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    func saveSolve(time: Double, scramble: String, inspectionUsed: Bool) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let entity =  NSEntityDescription.entityForName("Solve",
            inManagedObjectContext:managedContext)
        let solve = NSManagedObject(entity: entity!,
            insertIntoManagedObjectContext: managedContext)
        let date = NSDate()
        
        solve.setValue(time, forKey: "time")
        solve.setValue(scramble, forKey: "scramble")
        solve.setValue(date, forKey: "date")
        solve.setValue(inspectionUsed, forKey: "inspectionUsed")
        
        do {
            try managedContext.save()
            dateSortedList.append(solve)
            print("Saved solve")
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    func deleteSolve(indexPath: NSIndexPath) {
        let managedContext = appDelegate.managedObjectContext
        let solveToDelete = displayList[indexPath.row]
        managedContext.deleteObject(solveToDelete)
        displayList.removeAtIndex(indexPath.row)
        do {
            try managedContext.save()
        } catch {
            print("Post-delete save failed")
        }

    }
}