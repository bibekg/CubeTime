//
//  MainViewController.swift
//  CubeTime
//
//  Created by Bibek Ghimire on 7/29/15.
//  Copyright (c) 2015 Bibek. All rights reserved.
//

import UIKit

protocol TableViewResponder: class {
    func refreshTable()
}

class MainViewController: UIViewController, TimerResponder {
    
    var solves = Solves()
    var delegate: TableViewResponder?
    
    //-------------------------//
    //------- Scrambler -------//
    //-------------------------//
    
    // Scrambler Connections and Data
    @IBOutlet var slider: UISlider!
    @IBOutlet weak var scrambleButton: UIButton!
    @IBOutlet var scrambleAlgorithm: UILabel!
    
    var scramble: String?
    let algorithm = Algorithm()
    
    // Generates and outputs a new algorithm based on slider value
    @IBAction func scramblePressed(sender: AnyObject) {
        scramble = algorithm.createAlgorithm(Int(self.slider.value))
        self.scrambleAlgorithm.text = scramble
    }
    
    // Updates the value label when the slider is used
    @IBAction func scrambleSliderUsed(sender: AnyObject) {
        let value = Int(self.slider.value)
        self.scrambleButton.setTitle("Scramble (\(value)) ", forState: .Normal)
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
        
        // User hit START
        if !(stopwatch.timer.valid) {
            stopwatch.startTimer()
            self.startOrStopLabel.setTitle("Tap anywhere to stop", forState: .Normal)
            self.startOrStopLabel.titleLabel!.font = UIFont(name: (self.startOrStopLabel.titleLabel!.font?.fontName)!, size: 30.0)
            hide("Start")
        }
            
        // User hit STOP
        else {
            stopwatch.stopTimer()
            self.startOrStopLabel.setTitle("Start", forState: .Normal)
            self.startOrStopLabel.titleLabel!.font = UIFont(name: (self.startOrStopLabel.titleLabel!.font?.fontName)!, size: 60.0)
            hide("Stop")
        }
    }
    
    // Hides UI elements based on which button was tapped
    func hide(situation: String) {
        switch situation {
        case "Start":
            self.resetButton.hidden = true
            self.saveButton.hidden = true
            self.scrambleButton.hidden = true
        case "Stop":
            self.resetButton.hidden = false
            self.resetButton.hidden = false
            self.saveButton.hidden = false
            self.startOrStopLabel.hidden = true
        case "Reset":
            self.startOrStopLabel.hidden = false
            self.resetButton.hidden = true
            self.saveButton.hidden = true
            self.scrambleButton.hidden = false
        case "Save Time":
            self.saveButton.hidden = true
            self.startOrStopLabel.hidden = true
            self.scrambleButton.hidden = false
        case "Load":
            self.resetButton.hidden = true
            self.saveButton.hidden = true
        default: break
        }
    }
    
    // Reset the timer to 00:00
    @IBAction func resetPressed(sender: AnyObject) {
        stopwatch.time = 0.0
        updateTimer(0, sec: 0, ms: 0)
                self.scramble = nil
        hide("Reset")
        self.scrambleAlgorithm.text = "Slide to choose scramble length, then press Scramble."
    }
    
    // Saves current time to core data
    @IBAction func savePressed(sender: AnyObject) {
        if (stopwatch.time != 0) {
            if scramble != nil {
                solves.saveSolve(stopwatch.getTime(), scramble: scramble!)
            } else {
                solves.saveSolve(stopwatch.getTime(), scramble: "No scramble used")
            }
            hide("Save Time")
        }
    }
    
    //---------------------------------//
    //------- Default Functions -------//
    //---------------------------------//
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Scrambler Prep
        self.scrambleAlgorithm.text = "Slide to choose scramble length, then press Scramble."
        self.scrambleButton.setTitle("Scramble (\(Int(self.slider.value)))", forState: .Normal)
        
        // Timer Prep
        stopwatch.delegate = self
        self.startOrStopLabel.setTitle("Start", forState: .Normal)
        self.startOrStopLabel.titleLabel!.font = UIFont(name: (self.startOrStopLabel.titleLabel!.font?.fontName)!, size: 60.0)

        hide("Load")
        self.timeLabel.text = "00:00:00"
        
        solves.downloadByDate()

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}