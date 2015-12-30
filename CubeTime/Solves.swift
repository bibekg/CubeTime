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

class SolvesStore {
    
    var displayList = [Solve]()
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    var timeSortedList: [Solve] {
        get {
            var results = [Solve]()
            let sortDescriptor = NSSortDescriptor(key: "time", ascending: true)
            let sortDescriptors = [sortDescriptor]
            let fetchRequest = NSFetchRequest(entityName: "Solve")
            fetchRequest.sortDescriptors = sortDescriptors
            do {
                results = try managedObjectContext.executeFetchRequest(fetchRequest) as! [Solve]
            } catch let error as NSError {
                print("Could not fetch \(error), \(error.userInfo)")
            }
            return results
        }
    }
    
    var dateSortedList: [Solve] {
        get {
            var results = [Solve]()
            let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
            let sortDescriptors = [sortDescriptor]
            let fetchRequest = NSFetchRequest(entityName: "Solve")
            fetchRequest.sortDescriptors = sortDescriptors
            do {
                results = try managedObjectContext.executeFetchRequest(fetchRequest) as! [Solve]
            } catch let error as NSError {
                print("Could not fetch \(error), \(error.userInfo)")
            }
            return results
        }
    }
    
    func saveSolve(time: Double, scramble: String, inspectionTime: Int, moc: NSManagedObjectContext) {
        let newSolve = NSEntityDescription.insertNewObjectForEntityForName("Solve", inManagedObjectContext: moc) as! Solve
        newSolve.time = time
        newSolve.scramble = scramble
        newSolve.date = NSDate()
        newSolve.inspectionTime = Int32(inspectionTime)
        
        do {
            try moc.save()
            print("Saved solve")
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    func deleteSolve(indexPath: NSIndexPath, moc: NSManagedObjectContext) {
        let solveToDelete = displayList[indexPath.row]
        moc.deleteObject(solveToDelete)
        displayList.removeAtIndex(indexPath.row)
        do {
            try moc.save()
        } catch {
            print("Post-delete save failed")
        }
    }
}