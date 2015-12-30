//
//  Timer.swift
//  CubeTime
//
//  Created by Bibek Ghimire on 12/14/15.
//  Copyright © 2015 Bibek. All rights reserved.
//

import Foundation
import AVFoundation

protocol TimerResponder: class {
    func updateTimer(min: Int, sec: Int, ms: Int)
}

// FIX: Adapt class to computed variable convention in Swift
class Stopwatch {
    var delegate: TimerResponder?
    
    var countdownSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("countdown", ofType: "wav")!)
    var countdown = AVAudioPlayer()
    var beepSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("beep", ofType: "wav")!)
    var beep = AVAudioPlayer()
    var clapSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("clapping", ofType: "mp3")!)
    var clap = AVAudioPlayer()
    
    var inspectionTime = Int()
    let timeInterval = 0.01
    var inspectionWanted: Bool = false
    
    var timer = NSTimer()
    var downTimer = NSTimer()
    
    var elapsedTime: Double = 0
    var baseTime = NSTimeInterval()
    
    var minutes: Int {
        get {
            var minutes = 0
            if elapsedTime >= 60 {
                minutes = Int(elapsedTime / 60)
            }
            return minutes
        }
    }
    
    var seconds: Int {
        get {
            var seconds = 0
            if elapsedTime >= 1 {
                seconds = Int(elapsedTime % 60)
            }
            return seconds
        }
    }
    
    var milliseconds: Int {
        get {
            return Int((elapsedTime % 1) * 100)
        }
    }
    
    func getTime() -> Double {
        return (Double(Int(elapsedTime*100)) / 100.0)
    }
    
    func startTimer() {
        baseTime = NSDate.timeIntervalSinceReferenceDate()
        timer = NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: self, selector: Selector("trackTime"), userInfo: nil, repeats: true)
    }
    func stopTimer() {
        timer.invalidate()
    }
    @objc private func trackTime() {
        let currentTime = NSDate.timeIntervalSinceReferenceDate()
        elapsedTime = currentTime - baseTime
        delegate?.updateTimer(minutes, sec: seconds, ms: milliseconds)
    }
    
    func startDownTimer() {
        baseTime = NSDate.timeIntervalSinceReferenceDate()
        elapsedTime = Double(inspectionTime)
        downTimer = NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: self, selector: Selector("trackDownTime"), userInfo: nil, repeats: true)
    }
    func stopDownTimer() {
        downTimer.invalidate()
    }
    @objc private func trackDownTime() {
        let currentTime = NSDate.timeIntervalSinceReferenceDate()
        elapsedTime = Double(inspectionTime) - (currentTime - baseTime)
        delegate?.updateTimer(minutes, sec: seconds, ms: milliseconds)
        
        if elapsedTime < 4.02 && elapsedTime > 3.98 {
            playCountdownSound()
        }
        if elapsedTime < 0.01 {
            beep.play()
            stopDownTimer()
            startTimer()
        }
    }
    
    func prepareToPlaySounds() {
        do {
            try countdown = AVAudioPlayer(contentsOfURL: countdownSound, fileTypeHint: nil)
            try beep = AVAudioPlayer(contentsOfURL: beepSound, fileTypeHint: nil)
            try clap = AVAudioPlayer(contentsOfURL: clapSound, fileTypeHint: nil)
        } catch {
            print("Audio failed")
        }
        countdown.prepareToPlay()
        beep.prepareToPlay()
        clap.prepareToPlay()
    }
    
    func playCountdownSound() {
        countdown.play()
    }
    
    func stopCountdownSound() {
        if countdown.playing {
            countdown.stop()
        }
    }
    
    func playClapSound() {
        clap.play()
    }
}