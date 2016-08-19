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
    var inputMenu : NSMenu?
    var overlayController : NSViewController?
    @IBOutlet var sourceLabel : NSTextField!

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
    @IBOutlet var navIRadio: NSButton!

    var iRadioController : NSViewController?
    var mainViewController : NSViewController?
    var remoteViewController : NSViewController?


    override func viewDidLoad() {
        super.viewDidLoad()
        tweakStyles()
        overlayController = MainViewController(nibName: "MainViewController", bundle: nil)
        displayCurrentViewController()
    }

    override func viewWillAppear() {
        addTasks()
    }

    override func viewWillDisappear() {
        let sheduler = TaskSheduler.sharedSheduler()
        sheduler.offScreen(.INPUT, offScreen: true)
    }

    func addTasks() {
        let sheduler = TaskSheduler.sharedSheduler()
        let inputTask = Task(identifier: .INPUT, onScreenInterval: 5, offScreenInterval: 15, parallel: false, task:{
            return DenonCommand.SIGNAL.QUERY.execute().then{ command -> Promise<AnyObject> in
                return Promise(command)
            }
        })
        sheduler.addTask(inputTask)
    }

    @IBAction func navigate(sender: StyledButton) {
        [navPlayer, navRemote, navSettings, navSpeakers, navIRadio].forEach {
            $0.layer?.backgroundColor = NSColor.clearColor().CGColor
        }

        sender.layer?.backgroundColor = Theme.backgroundColor.CGColor
        sender.layer?.opaque = true

        if(nil != overlayController) {
            overlayController!.dismissController(self)
            overlayController!.view.removeFromSuperview()
            overlayController = nil
        }

        switch sender {
        case navPlayer:
            if(nil == mainViewController) {
                mainViewController = MainViewController(nibName: "MainViewController", bundle: nil)
            }
            overlayController = mainViewController

            break
        case navRemote:
            if(nil == remoteViewController) {
                remoteViewController = RemoteControlViewController(nibName: "RemoteControlViewController", bundle: nil)
            }
            overlayController = remoteViewController

            break
        case navIRadio:
            if(nil == iRadioController) {
                iRadioController = IRadioViewController(nibName: "IRadioViewController", bundle: nil)
            }
            overlayController = iRadioController
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
        sourceLabel.backgroundColor = NSColor.clearColor()
        sourceLabel.textColor = Theme.fontColor

        view.layer?.backgroundColor = Theme.backgroundColor.CGColor
    }

    @IBAction func selectInput(sender: AnyObject) {
        inputMenu = NSMenu()


        InputSources.sharedInstance.sources.forEach({ source in
            let item = NSMenuItem(title: source.label, action: #selector(self.setInput), keyEquivalent: "")
            item.representedObject = source.name
            inputMenu?.addItem(item)
        })
        inputMenu?.popUpMenuPositioningItem(nil, atLocation: NSEvent.mouseLocation(), inView: nil)
    }

    func setInput(menuItem: NSMenuItem) {
        // get the source name
        if let sourceName = menuItem.representedObject as? String {
            //find source with this name
            if let source = InputSources.sharedInstance.sources.filter({$0.name == sourceName}).first {
                //switch to source
                DenonCommand.SIGNAL.PARAMETER(source).execute()
            }
        }
    }
}
