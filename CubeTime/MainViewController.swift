//
//  MainViewController.swift
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

class MainViewController: UIViewController, TimerResponder {
    
//    var solves = Solves()
    var delegate: TableViewResponder?
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    //-------------------------//
    //------- Scrambler -------//
    //-------------------------//
    
    // Scrambler Connections and Data
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var sliderTitle: UILabel!
    @IBOutlet var slider: UISlider!
    @IBOutlet var scrambleAlgorithm: UILabel!
    
    @IBOutlet weak var inspectionControlLabel: UILabel!
    @IBOutlet weak var inspectionControl: UISegmentedControl!
    var scramble = String()
    let algorithm = Algorithm()
    
    
    // Generates and outputs a new algorithm based on slider value
    @IBAction func scramblePressed(sender: AnyObject) {
    }
    
    // Updates the value label when the slider is used
    @IBAction func scrambleSliderUsed(sender: AnyObject) {
        createScramble()
    }
    
    func createScramble() {
        scramble = algorithm.createAlgorithm(Int(slider.value))
        scrambleAlgorithm.text = scramble
    }
    
    //---------------------//
    //------- Timer -------//
    //---------------------//
    
    // Timer Connections and Data
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var view4: UIView!
    @IBOutlet var startOrStopLabel: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var resetView: UIView!
    @IBOutlet var resetButton: UIButton!
    @IBOutlet weak var saveView: UIView!
    @IBOutlet var saveButton: UIButton!
    
    // Constraints for Animations
    var resetButtonYPositionConstraint: NSLayoutConstraint?
    var scrambleSliderYPositionConstraint: NSLayoutConstraint?
    var messageLabelXPositionConstraint: NSLayoutConstraint?
    
    let stopwatch = Stopwatch()
    var message: String? = nil
    
    @IBAction func inspectionControlUsed(sender: UISegmentedControl) {
        stopwatch.inspectionTime = Int(inspectionControl.titleForSegmentAtIndex(inspectionControl.selectedSegmentIndex)!)!
        if inspectionControl.selectedSegmentIndex == 0 {
            stopwatch.inspectionWanted = false
        } else {
            stopwatch.inspectionWanted = true
        }
        updateTimer(0, sec: Int(stopwatch.inspectionTime), ms: 0)
    }
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
        timeLabel.text = "\(newMin):\(newSec):\(newMS)"
    }
    
    // Start or stop the timer
    @IBAction func startOrStopPressed(sender: UIButton) {
        
        // User hit START
        if (sender.titleLabel?.text == "Start") {
            if stopwatch.inspectionWanted {
                stopwatch.startDownTimer()
            } else {
                stopwatch.startTimer()
            }
            moveUI("Start")
            self.startOrStopLabel.setTitle("Stop", forState: .Normal)
        }
            
        // User hit STOP
        else {
            
            createUserMessage()
            if (stopwatch.downTimer.valid) {
                stopwatch.stopCountdownSound()
                moveUI("Down Time Stop")
            } else {
                moveUI("Stop")
            }
            stopwatch.stopTimer()
            stopwatch.stopDownTimer()
        }
    }
    
    // Reset the timer to 00:00
    @IBAction func resetPressed(sender: AnyObject) {
        stopwatch.elapsedTime = 0.0
        updateTimer(0, sec: 0, ms: 0)
        createScramble()
        moveUI("Reset")
    }
    
    // Saves current time to core data
    @IBAction func savePressed(sender: AnyObject) {
        if (stopwatch.elapsedTime != 0) {
            let solves = SolvesStore()
            solves.saveSolve(stopwatch.getTime(), scramble: scramble, inspectionTime: stopwatch.inspectionTime, moc: managedObjectContext)
            moveUI("Save Time")
            createScramble()
            stopwatch.elapsedTime = 0.0
            updateTimer(0, sec: 0, ms: 0)
        }
    }
    
    // Creates message for user based on solve time
    func createUserMessage() {
        if solveList.count > 1 && stopwatch.elapsedTime < solveList[0].time {
            message = "New best time!"
            stopwatch.playClapSound()
        }
            // If the current time will be a new top 3 time (unless there are less than 3 total times)
        else if solveList.count > 3 && stopwatch.elapsedTime < solveList[2].time {
            message = "You got a top 3 time!"
        }
    }
    
    //---------------------------------//
    //------- Default Functions -------//
    //---------------------------------//
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showResetButton()
        performConstraintLayout(true)
        
        // Scrambler Prep
        createScramble()
        scrambleAlgorithm.text = scramble
        
        // Timer Prep
        stopwatch.delegate = self
        timeLabel.text = "00:00:00"
        startOrStopLabel.setTitle("Start", forState: .Normal)
        stopwatch.inspectionWanted = false
        stopwatch.prepareToPlaySounds()

        moveUI("Load")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().idleTimerDisabled = true
    }
    
    //-------------------------//
    //------- Core Data -------//
    //-------------------------//
    
    var solveList: [Solve] {
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
    
    //--------------------------//
    //------- Animations -------//
    //--------------------------//
    
    let animationDuration = 0.5
    let grayedOutButonColor = UIColor(red: 150/255, green: 150/255, blue: 150/255, alpha: 1)
    
    // Hides or shows UI elements based on which button was tapped
    func moveUI(situation: String) {
            switch situation {
            case "Load", "Reset", "Save Time":
                // HIDE: reset button, save button
                // SET: scrambleSlider
 
                // Moves reset and save buttons below view
                removeThisConstraint(resetButtonYPositionConstraint)
                resetButtonYPositionConstraint = NSLayoutConstraint(item: resetButton, attribute: .Top, relatedBy: .Equal, toItem: resetView, attribute: .Bottom, multiplier: 1, constant: 0)
                
                // Moves slider, switch, and labels above view
                removeThisConstraint(scrambleSliderYPositionConstraint)
                scrambleSliderYPositionConstraint = NSLayoutConstraint(item: slider, attribute: .CenterY, relatedBy: .Equal, toItem: view1, attribute: .CenterY, multiplier: 1.3, constant: 0)
                
                // Moves message label off screen either left or right
                if situation == "Load" {
                    putMessageOnLeft()
                    view.addConstraint(messageLabelXPositionConstraint!)
                    performConstraintLayout(false)
                } else {
                    if message != nil {
                        putMessageOnRight()
                    }
                }
                
                message = nil
                
                view.addConstraints([resetButtonYPositionConstraint!,  scrambleSliderYPositionConstraint!, messageLabelXPositionConstraint!])
                
                if situation == "Load" {
                    performConstraintLayout(false)
                } else {
                    performConstraintLayout(true)
                }
                
                UIView.animateWithDuration(animationDuration, animations: {
                    self.scrambleAlgorithm.alpha = 1
                    self.startOrStopLabel.alpha = 1
                })
                
                UIView.performWithoutAnimation({
                    self.startOrStopLabel.setTitle("Start", forState: .Normal)
                })

            case "Start":
                // HIDE: slider, (if nil) algorithm
                removeThisConstraint(scrambleSliderYPositionConstraint)
                scrambleSliderYPositionConstraint = NSLayoutConstraint(item: slider, attribute: .CenterY, relatedBy: .Equal, toItem: view1, attribute: .CenterY, multiplier: -1, constant: 0)

                view.addConstraint(scrambleSliderYPositionConstraint!)
                performConstraintLayout(true)
                break
            case "Stop", "Down Time Stop":
                // SHOW: reset button, save button
                
                UIView.animateWithDuration(0, delay: 0.5, options: [], animations: {
                    self.saveButton.enabled = true
                    self.saveButton.setTitleColor(UIColor(red: 69/255, green: 190/255, blue: 255/255, alpha: 1), forState: .Normal)
                    }, completion: nil)

                removeThisConstraint(resetButtonYPositionConstraint)
                showResetButton()
                
                if message != nil {
                    messageLabel.text = message!
                    
                    removeThisConstraint(messageLabelXPositionConstraint)
                    putMessageOnLeft()
                    view.addConstraint(messageLabelXPositionConstraint!)
                    performConstraintLayout(false)
                    
                    removeThisConstraint(messageLabelXPositionConstraint)
                    
                    // messageLabel.CenterX = 1 * view.CenterX + 0
                    messageLabelXPositionConstraint = NSLayoutConstraint(item: messageLabel, attribute: .CenterX, relatedBy: .Equal, toItem: view4, attribute: .CenterX, multiplier: 1, constant: 0)
                    
                    view.addConstraint(messageLabelXPositionConstraint!)
                }
                
                UIView.animateWithDuration(animationDuration, animations: {
                    self.startOrStopLabel.alpha = 0})
                
                performConstraintLayout(true)
                
                if situation == "Down Time Stop" {
                    saveButton.enabled = false
                    saveButton.setTitleColor(grayedOutButonColor, forState: .Normal)
                }
            default: break
            }
    }
    
    // Lays out view with updated constraints
    func performConstraintLayout(animated: Bool) {
        if animated {
            UIView.animateWithDuration(animationDuration, animations:{ () -> Void in
                self.view.layoutIfNeeded()}, completion: nil)
        } else {
            view.layoutIfNeeded()
        }
    }
    
    func showResetButton() {
        // resetButton.CenterY = 1*resetView.CenterY + 0
        resetButtonYPositionConstraint = NSLayoutConstraint(item: resetButton, attribute: .CenterY, relatedBy: .Equal, toItem: resetView, attribute: .CenterY, multiplier: 1, constant: 0)
        view.addConstraints([resetButtonYPositionConstraint!])
    }
    
    func putMessageOnLeft() {
        removeThisConstraint(messageLabelXPositionConstraint)
        messageLabelXPositionConstraint = NSLayoutConstraint(item: messageLabel, attribute: .Trailing, relatedBy: .Equal, toItem: view4, attribute: .Leading, multiplier: 1, constant: 0)
    }

    func putMessageOnRight() {
        removeThisConstraint(messageLabelXPositionConstraint)
        messageLabelXPositionConstraint = NSLayoutConstraint(item: messageLabel, attribute: .Leading, relatedBy: .Equal, toItem: view4, attribute: .Trailing, multiplier: 1, constant: 0)
    }
    
    // Removes a constraint from the view
    func removeThisConstraint(var constraint: NSLayoutConstraint?) {
        if constraint != nil {
            view.removeConstraint(constraint!)
            constraint = nil
        }
    }
}