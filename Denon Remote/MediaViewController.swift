//
//  MediaViewController.swift
//  Denon Remote & Control
//
//  Created by Thomas Nordquist on 10.08.16.
//  Copyright © 2016 Thomas Nordquist. All rights reserved.
//

import Cocoa
import AlamofireImage
import Alamofire
import PromiseKit


class NavigationViewController: NSViewController {
    var overlayController : NSViewController?
    @IBOutlet var overlayView : NSView!
    @IBOutlet var navigationView : StyledView!

    @IBOutlet var songLabel : NSTextField!
    @IBOutlet var artistLabel : NSTextField!
    @IBOutlet var albumLabel : NSTextField!

    //MARK: Navigation
    @IBOutlet var navPlayer: NSButton!
    @IBOutlet var navRemote: NSButton!
    @IBOutlet var navSpeakers: NSButton!
    @IBOutlet var navSettings: NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        tweakStyles()

        overlayController = MainViewController(nibName: "MainViewController", bundle: nil)
        displayCurrentViewController()
    }

    @IBAction func navigate(sender: StyledButton) {
        [navPlayer, navRemote, navSettings, navSpeakers].forEach {
            $0.layer?.backgroundColor = NSColor.clearColor().CGColor
        }

        sender.layer?.backgroundColor = Theme.backgroundColor.CGColor
        sender.layer?.opaque = true

        if(nil != overlayController) {
            overlayController!.view.removeFromSuperview()
            overlayController = nil
        }

        switch sender {
        case navPlayer:
            overlayController = MainViewController(nibName: "MainViewController", bundle: nil)
            break
        case navRemote:
            overlayController = RemoteControlViewController(nibName: "RemoteControlViewController", bundle: nil)
            break
        default:
            break
        }
        displayCurrentViewController()

    }

    func displayCurrentViewController() {
        if(nil != overlayController) {
            print("add subview")
            overlayView.addSubview(overlayController!.view)
        }
    }

    @IBAction func muteAction(sender: AnyObject) {
        guard let state = DataHub.getState("MU") else {
            return
        }

        if(state == ResponseState.ON) {
            DenonCommand.MUTE.OFF.executeWithPriority(QueuePriority.HIGH)
        } else {
            DenonCommand.MUTE.ON.executeWithPriority(QueuePriority.VERY_HIGH)
        }
    }

    @IBAction func powerAction(sender: AnyObject) {
        DenonCommand.POWER.QUERY.executeWithPriority(QueuePriority.VERY_HIGH).then {_ -> Void in
            guard let state = DataHub.getState("PW") else {
                return
            }
            
            if(state == ResponseState.ON) {
                DenonCommand.POWER.OFF.executeWithPriority(QueuePriority.VERY_HIGH)
            } else {
                DenonCommand.POWER.ON.executeWithPriority(QueuePriority.VERY_HIGH)
            }
        }
    }

    func tweakStyles() {
        navigationView.sublayer.backgroundColor = Theme.foregroundColor.CGColor
        navigationView.sublayer.cornerRadius = 0

        view.layer?.backgroundColor = Theme.backgroundColor.CGColor
    }
}
