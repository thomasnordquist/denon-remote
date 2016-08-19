//
//  TaskSheduler.swift
//  Denon Remote
//
//  Created by Thomas Nordquist on 13.08.16.
//  Copyright © 2016 Thomas Nordquist. All rights reserved.
//

import Cocoa
import PromiseKit

enum TaskIdentifier : StringLiteralType {
    case VOLUME
    case IMAGE
    case POWER
    case MUTE
    case DISPLAY
    case INPUT
}

class Task {
    let identifier : TaskIdentifier
    let onScreenInterval : Double
    let offScreenInterval: Double
    let parallel : Bool
    let task : () -> Promise<AnyObject?>
    var timePassed : Double = Double.infinity // time since last execution (aproximation by sheduler)
    var offScreen = false

    func due() -> Double { return (offScreen ? offScreenInterval : onScreenInterval) - timePassed }
    func isDue() -> Bool { return due() < 0}

    init(identifier: TaskIdentifier, onScreenInterval: Double, offScreenInterval: Double, parallel: Bool, task: () -> Promise<AnyObject?>) {
        self.identifier = identifier
        self.onScreenInterval = onScreenInterval
        self.offScreenInterval = offScreenInterval
        self.parallel = parallel
        self.task = task
    }
}


/*
 The Taskrunner identifies task by it's identifier, is another task with same identifier is added, the previous will be removed.
 
 The timer is energy optimized and calculates the next time to wake up depending on the next task to perform. The timer might reset when an new task has been added (depending when the task is sheduled)
 
 
 
 */
class TaskSheduler: NSObject {
    var tasks: [Task] = []
    var timer : NSTimer? = nil
    static let defaultTimerInterval = 0.5
    var timerInterval = TaskSheduler.defaultTimerInterval

    func addTask(task: Task) {
        removeTask(task.identifier)
        tasks.append(task)

        resetTimerIfIdle()
        
        if(nil == timer) {
            start()
        }
    }

    func resetTimerIfIdle() {
        if let timeToFire = timer?.fireDate.timeIntervalSinceNow {
            if(timeToFire > TaskSheduler.defaultTimerInterval) {
                reset()
            }
        }
    }

    func offScreen(identifier: TaskIdentifier, offScreen: Bool) {

        if let task = tasks.filter({$0.identifier == identifier}).first {
            task.offScreen = offScreen
        }
    }

    func removeTask(identifier: TaskIdentifier) {
        let idx = tasks.indexOf { t -> Bool in
            t.identifier == identifier
        }

        if(nil != idx)  {
            tasks.removeAtIndex(idx!)
        }
    }

    internal func start() {
        if(timer == nil) {
            timer = NSTimer.scheduledTimerWithTimeInterval(timerInterval, target: self, selector: #selector(self.run), userInfo: nil, repeats: true)
            timer?.tolerance = 0.1+timerInterval*0.1
        }
    }

    internal func stop() {
        timer?.invalidate()
        timer = nil
    }

    func nextDueTask() -> Task? {
        //increase the time passed for all tasks

        for i in 0..<tasks.count {
            tasks[i].timePassed += timerInterval
        }
        return tasks.sort{$0.due() < $1.due()}.first
    }

    // will be called by the timer
    func run() {
        stopTaskRunnerIfEmpty()

        if let task = nextDueTask() {
            if(task.isDue()) {
                task.timePassed = 0
                timerInterval = TaskSheduler.defaultTimerInterval
                print("execute " + task.identifier.rawValue)
                runTask(task)
            } else {
                // prevents unnecessary wakes and preserves power
                timerInterval = task.due() + TaskSheduler.defaultTimerInterval
                print("nothing to do, next action in " + String(timerInterval))
                restart()
            }
        }
    }

    // will execute the given task
    func runTask(task : Task) {
        if(!task.parallel) {
            stop()
        }

        task.task().always {
            if(!task.parallel) {
                self.start()
            }
        }
    }

    func stopTaskRunnerIfEmpty() {
        if(tasks.isEmpty) {
            stop()
        }
    }

    func reset() {
        timerInterval = TaskSheduler.defaultTimerInterval
        restart()
    }

    func restart() {
        stop()
        start()
    }

}

extension TaskSheduler {
    @nonobjc static private var _sharedSheduler : TaskSheduler! = nil
    @nonobjc static var onceToken : dispatch_once_t = 0

    static func sharedSheduler() -> TaskSheduler {

        dispatch_once(&onceToken) { 
            _sharedSheduler = TaskSheduler()
        }
        return _sharedSheduler;
    }
}
