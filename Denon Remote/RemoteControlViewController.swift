//
//  RemoteControlViewController.swift
//  Denon Remote
//
//  Created by Thomas Nordquist on 15.08.16.
//  Copyright © 2016 Thomas Nordquist. All rights reserved.
//

import Cocoa
import PromiseKit

class RemoteControlViewController: NSViewController {

    @IBOutlet var line1 : NSTextField!
    @IBOutlet var line2 : NSTextField!
    @IBOutlet var line3 : NSTextField!
    @IBOutlet var line4 : NSTextField!
    @IBOutlet var line5 : NSTextField!
    @IBOutlet var line6 : NSTextField!
    @IBOutlet var line7 : NSTextField!

    var lines : [NSTextField]!

    override func viewDidLoad() {
        super.viewDidLoad()

        initializeLines()
        tweakStyles()
        // Do view setup here.
        print("Where is it ?")
    }

    func initializeLines() {
        lines = [line1, line2, line3, line4, line5, line6, line7]
    }

    func tweakStyles() {
        view.layer?.backgroundColor = Theme.backgroundColor.CGColor
    }

    func observeDisplay() {
        let displayTask = Task(identifier: "display", onScreenInterval: 2, offScreenInterval: 10, parallel: false, task:{
            return DenonCommand.INFO.DISPLAY.execute().then{ command -> Promise<AnyObject> in
                let info = ResponseParser.parseDisplayResponse(command.response)
                //self.showMediaInformation(info)
                return Promise(command)
            }
        })

        TaskSheduler.sharedSheduler().addTask(displayTask)
    }



}
