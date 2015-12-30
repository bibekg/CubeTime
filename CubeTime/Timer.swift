//
//  Timer.swift
//  CubeTime
//
//  Created by Bibek Ghimire on 12/14/15.
//  Copyright © 2015 Bibek. All rights reserved.
//

import Foundation

protocol TimerResponder: class {
    func updateTimer(min: Int, sec: Int, ms: Int)
}

// FIX: Adapt class to computed variable convention in Swift
class Stopwatch {
    var delegate: TimerResponder?
    
    let inspectionTime = 15.0
    let timeInterval = 0.01
    var inspectionWanted: Bool = false
    
    var timer = NSTimer()
    var downTimer = NSTimer()
    
    var time: Double = 0
    
    var minutes: Int {
        get {
            var minutes = 0
            if time >= 60 {
                minutes = Int(time / 60)
            }
            return minutes
        }
    }
    
    var seconds: Int {
        get {
            var seconds = 0
            if time >= 1 {
                seconds = Int(time % 60)
            }
            return seconds
        }
    }
    
    var milliseconds: Int {
        get {
            return Int((time % 1) * 100)
        }
    }

    func startTimer() {
        timer = NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: self, selector: Selector("trackTime"), userInfo: nil, repeats: true)
    }
    
    func startDownTimer() {
        time = inspectionTime
        downTimer = NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: self, selector: Selector("trackDownTime"), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        timer.invalidate()
    }
    
    func stopDownTimer() {
        downTimer.invalidate()
    }
    
    // Called by timer every (timeInterval) seconds, then uses MVCDelegate to update time label
    @objc private func trackTime() {
        time = time + timeInterval
        delegate?.updateTimer(minutes, sec: seconds, ms: milliseconds)
    }
    
    @objc private func trackDownTime() {
        time = time - timeInterval
        delegate?.updateTimer(minutes, sec: seconds, ms: milliseconds)
        if (time < 0.01) {
            downTimer.invalidate()
            startTimer()
        }
    }
}