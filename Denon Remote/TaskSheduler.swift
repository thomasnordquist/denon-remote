//
//  TaskSheduler.swift
//  Denon Remote
//
//  Created by Thomas Nordquist on 13.08.16.
//  Copyright © 2016 Thomas Nordquist. All rights reserved.
//

import Cocoa
import PromiseKit

struct Task {
    let identifier : String
    let onScreenInterval : Double
    let offScreenInterval: Double
    let parallel : Bool
    let task : () -> Promise<AnyObject?>
}

class TaskSheduler: NSObject {
    var tasks: [Task] = []
    var timer : NSTimer? = nil

    func addTask(task: Task) {
        removeTask(task.identifier)

        tasks.append(task)

        if(nil == timer) {
            start()
        }
    }

    func removeTask(identifier: String) {
        let idx = tasks.indexOf { t -> Bool in
            t.identifier == identifier
        }

        if(nil != idx)  {
            tasks.removeAtIndex(idx!)
        }
    }

    internal func start() {
        if(timer == nil) {
            timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(self.run), userInfo: nil, repeats: true)
        }
    }

    internal func stop() {
        timer?.invalidate()
        timer = nil
    }

    func run() {
        handleEmptyTaskRunner()

        let task = rotateTasks()

        if(!task.parallel) {
            stop()
        }

        task.task().always {
            if(!task.parallel) {
                self.start()
            }
        }
    }

    func handleEmptyTaskRunner() {
        if(tasks.isEmpty) {
            stop()
            return
        }
    }

    func rotateTasks() -> Task {
        let task = tasks.removeFirst()
        tasks.append(task)
        return task
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
