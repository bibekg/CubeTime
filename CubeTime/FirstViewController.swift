//
//  FirstViewController.swift
//  CubeTime
//
//  Created by Bibek Ghimire on 7/29/15.
//  Copyright (c) 2015 Bibek. All rights reserved.
//

import UIKit
import CoreData

protocol TableViewResponder: class {
    func refreshTable()
}

class FirstViewController: UIViewController, TimerResponder {
    
    var delegate: TableViewResponder?
    
    //-------------------------//
    //------- Scrambler -------//
    //-------------------------//
    
    // Scrambler Connections and Data
    @IBOutlet var scrambleAlgorithm: UILabel!
    @IBOutlet var slider: UISlider!
    @IBOutlet var sliderValueLabel: UILabel!
    var scramble: String?
    
    // Generates and outputs a new algorithm based on slider value
    @IBAction func scramblePressed(sender: AnyObject) {
        let algorithmLength = Int(self.slider.value)
        let algorithm = Algorithm()
        scramble = algorithm.createAlgorithm(algorithmLength)
        self.scrambleAlgorithm.text = scramble
    }
    
    // Updates the value label when the slider is used
    @IBAction func scrambleSliderUsed(sender: AnyObject) {
        updateValueLabel()
    }
    
    // Updates the value of the label below the slider with the slider's value.
    func updateValueLabel() {
        let newValue = Int(slider.value)
        self.sliderValueLabel.text = String(newValue)
    }
    
    //---------------------//
    //------- Timer -------//
    //---------------------//
    
    // Timer Connections and Data
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet var startOrStopLabel: UIButton!
    @IBOutlet var resetButton: UIButton!
    @IBOutlet var saveButton: UIButton!
    let stopwatch = Stopwatch()
    
    // Updates timer every "timeInterval" seconds
    func updateTimer(min: Int, sec: Int, ms: Int) {
        let newMin = String(format: "%02d", min)
        let newSec = String(format: "%02d", sec)
        var newMS: String
        if (ms < 10) {
            newMS = String(format: "%02d", ms)
        } else {
            newMS = String(ms)
        }
        self.timeLabel.text = "\(newMin):\(newSec):\(newMS)"
    }
    
    // Start or stop the timer
    @IBAction func startOrStopPressed(sender: AnyObject) {
        
        // If the timer was not running, start it
        if !(stopwatch.timer.valid) {
            stopwatch.startTimer()
            sender.setTitle("Stop", forState: .Normal)
            resetButton.hidden = true
            saveButton.hidden = true
            startOrStopLabel.setTitleColor(UIColor.redColor(), forState: .Normal)
        }
            
        // If the timer was running, stop it
        else {
            stopwatch.stopTimer()
            sender.setTitle("Start", forState: .Normal)
            resetButton.hidden = false
            saveButton.hidden = false
            startOrStopLabel.setTitleColor(UIColor.greenColor(), forState: .Normal)
            startOrStopLabel.hidden = true
        }
    }
    
    // Reset the timer to 00:00
    @IBAction func resetPressed(sender: AnyObject) {
        stopwatch.time = 0.0
        updateTimer(0, sec: 0, ms: 0)
        startOrStopLabel.hidden = false
        resetButton.hidden = true
        saveButton.hidden = true
        self.scramble = nil
        self.scrambleAlgorithm.text = "Slide to choose scramble length, then press Scramble."
    }
    
    // Saves current time to core data
    @IBAction func savePressed(sender: AnyObject) {
        if (stopwatch.time != 0) {
            // If a scramble has been
            if scramble != nil {
                saveSolve(stopwatch.time, scramble: scramble!)
            } else {
                saveSolve(stopwatch.time, scramble: "No scramble used.")
            }
            self.saveButton.hidden = true
            self.startOrStopLabel.hidden = true
        }
    }
    
    //-------------------------//
    //------- Core Data -------//
    //-------------------------//
    
    var solves = [NSManagedObject]()
    
    // Saves a solve to Core Data, along with relevant data
    func saveSolve(time: Double, scramble: String) {
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
        
        do {
            try managedContext.save()
            solves.append(solve)
            print("Saved solve")
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    //---------------------------------//
    //------- Default Functions -------//
    //---------------------------------//
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Scrambler Prep
        self.scrambleAlgorithm.text = "Slide to choose scramble length, then press Scramble."
        updateValueLabel()
        
        // Timer Prep
        stopwatch.delegate = self
        self.startOrStopLabel.setTitle("Start", forState: .Normal)
        startOrStopLabel.setTitleColor(UIColor.greenColor(), forState: .Normal)
        self.timeLabel.text = "00:00:00"
        
        // Core Data Prep
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Solve")
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            solves = results as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


