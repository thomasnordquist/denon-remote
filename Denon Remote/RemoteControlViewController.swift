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

    @IBOutlet var displayView: StyledView!

    @IBOutlet var line1 : NSTextField!
    @IBOutlet var line2 : NSTextField!
    @IBOutlet var line3 : NSTextField!
    @IBOutlet var line4 : NSTextField!
    @IBOutlet var line5 : NSTextField!
    @IBOutlet var line6 : NSTextField!
    @IBOutlet var line7 : NSTextField!

    @IBOutlet var buttonUp : NSButton!
    @IBOutlet var buttonRight : NSButton!
    @IBOutlet var buttonDown : NSButton!
    @IBOutlet var buttonLeft : NSButton!
    @IBOutlet var buttonEnter : NSButton!
    @IBOutlet var buttonPageDown : NSButton!
    @IBOutlet var buttonPageUp : NSButton!

    @IBAction func pressButton(sender: NSButton) {
        guard let cmd = commandForButton(sender) else {
            return;
        }
        TaskSheduler.sharedSheduler().stop()

        cmd.execute().then{ _ -> Void in
            DenonCommand.INFO.DISPLAY.execute().then{ command -> Void in
                let info = ResponseParser.parseDisplayResponse(command.response)
                self.setDisplay(info)
            }
        }.always({
            TaskSheduler.sharedSheduler().start()
        })
    }

    func commandForButton(button: NSButton) -> CommandType? {
        var cmd : CommandType?

        if (button == buttonUp) {
            cmd = DenonCommand.CONTROL.UP
        } else if (button == buttonRight) {
            cmd = DenonCommand.CONTROL.RIGHT
        } else if (button == buttonDown) {
            cmd = DenonCommand.CONTROL.DOWN
        } else if (button == buttonLeft) {
            cmd = DenonCommand.CONTROL.LEFT
        } else if (button == buttonEnter) {
            cmd = DenonCommand.CONTROL.ENTER
        } else if (button == buttonPageUp) {
            cmd = DenonCommand.CONTROL.PAGE_PREVIOUS
        } else if (button == buttonPageDown) {
            cmd = DenonCommand.CONTROL.PAGE_NEXT
        }
        return cmd
    }

    var lines : [NSTextField?]!

    override func viewDidLoad() {
        super.viewDidLoad()

        initializeLines()
        tweakStyles()
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        addTasks()
    }


    override func viewWillDisappear() {
        super.viewWillDisappear()
        TaskSheduler.sharedSheduler().removeTask(.DISPLAY)
    }

    func initializeLines() {
        lines = [nil, line1, line2, line3, line4, line5, line6, line7]
    }

    func tweakStyles() {
        view.layer?.backgroundColor = Theme.backgroundColor.CGColor
        lines.forEach({ $0?.textColor = Theme.fontColor })

        displayView.sublayer.cornerRadius = 10
        displayView.sublayer.backgroundColor = Theme.foregroundColor.CGColor
    }

    func addTasks() {
        let displayTask = Task(identifier: .DISPLAY, onScreenInterval: 2, offScreenInterval: 10, parallel: false, task:{
            return DenonCommand.INFO.DISPLAY.execute().then{ command -> Promise<AnyObject> in
                let info = ResponseParser.parseDisplayResponse(command.response)
                self.setDisplay(info)
                return Promise(command)
            }
        })

        TaskSheduler.sharedSheduler().addTask(displayTask)
    }

    func setDisplay(info: DisplayResponse?) {
        guard let info = info else {
            return;
        }

        for i in 0...7 {
            if let line = lines[i] {
                //show active line
                if( info.response[i].mask & DisplayInformationBitMask.CURSOR > 0) {
                    line.layer?.backgroundColor = Theme.backgroundColor.CGColor
                } else {
                    line.layer?.backgroundColor = Theme.foregroundColor.CGColor
                }

                line.cell?.stringValue = info.response[i].text
            }
        }
    }



}
