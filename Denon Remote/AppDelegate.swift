//
//  AppDelegate.swift
//  Denon Remote & Control
//
//  Created by Thomas Nordquist on 09.08.16.
//  Copyright © 2016 Thomas Nordquist. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-2)
    let popover = NSPopover()
    var eventMonitor : AnyObject?

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        if let button = statusItem.button {
            button.image = NSImage(named: "amplifier")
            button.action = #selector(AppDelegate.togglePopover(_:))
        }

        popover.behavior = NSPopoverBehavior.Transient
        popover.animates = false
        popover.contentViewController = NavigationViewController(nibName: "NavigationViewController", bundle: nil)

        let mask : NSEventMask = NSEventMask(rawValue: NSEventMask.LeftMouseDownMask.rawValue | NSEventMask.RightMouseDownMask.rawValue)

        eventMonitor = NSEvent.addGlobalMonitorForEventsMatchingMask(mask) { _ in
            self.closePopover(nil)
        }

    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    func showPopover(sender: AnyObject?) {
        if let button = statusItem.button {
            popover.showRelativeToRect(button.bounds, ofView: button, preferredEdge: NSRectEdge.MinY)
        }
    }

    func closePopover(sender: AnyObject?) {
        popover.performClose(sender)
    }

    func togglePopover(sender: AnyObject?) {
        if popover.shown {
            closePopover(sender)
        } else {
            showPopover(sender)
        }
    }
}

