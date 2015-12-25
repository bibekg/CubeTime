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
    let timeInterval = 0.01
    var time = 0.0
    var timer = NSTimer()

    func startTimer() {
            timer = NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: self, selector: Selector("trackTime"), userInfo: nil, repeats: true)
    }
    func stopTimer() {
        timer.invalidate()
    }
    
    // Returns elapsed time as a double in the form (seconds.milliseconds) without rounding
    func getTime() -> Double {
        return (Double(Int(time*100))/100)
    }
    // Returns number of minutes as an integer
    func getMinutes() -> Int {
        return toMSM(time).min
    }
    // Returns number of seconds as an integer
    func getSeconds() -> (Int) {
        return toMSM(time).sec
    }
    // Returns number of milliseconds as an integer
    func getMilliseconds() -> (Int) {
        return toMSM(time).ms
    }
    
    // Called by timer every (timeInterval) seconds, then uses FVCDelegate to update time label
    @objc private func trackTime() {
        time += timeInterval
        delegate?.updateTimer(getMinutes(), sec: getSeconds(), ms: getMilliseconds())
    }
    
    // Returns the minute, second, and millisecond components of a time
    private func toMSM(time: Double) -> (min: Int, sec: Int, ms: Int) {
        var min: Int = 0
        var sec: Int = 0
        if time >= 60 {
            min = Int(time / 60)
        }
        if time >= 1 {
            sec = Int(time % 60)
        }
        let ms: Int = Int((time % 1)*100)
        
        return (min, sec, ms)
    }
}