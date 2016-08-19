//
//  EventTextField.swift
//  Denon Remote
//
//  Created by Thomas Nordquist on 19.08.16.
//  Copyright © 2016 Thomas Nordquist. All rights reserved.
//

import Cocoa

class EventTextField: NSTextField {
    var event: String?
    var renderer: ((String) -> String)?

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        Swift.print("init event text fiel")
    }

    override func setValue(value: AnyObject?, forKey key: String) {
        super.setValue(value, forKey: key)

        if key == "event" {
            NSNotificationCenter.defaultCenter().removeObserver(self)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.updateMyText(_:)), name: event!, object: nil)
        }

    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func updateMyText(notification: NSNotification) {
        guard let data = notification.userInfo else {
            resetString()
            return
        }

        if let str = data["data"] as? String {
            handleString(str)
            return
        }

        if let double = data["data"] as? Double {
            handleString(String(double))
            return
        }

        if let int = data["data"] as? Int {
            handleString(String(int))
            return
        }

    }

    func handleString(str: String) {
        if(nil != renderer) {
            stringValue = renderer!(str)
        } else {
            stringValue = str
        }
    }

    func resetString() {
        stringValue = ""
    }

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
}
