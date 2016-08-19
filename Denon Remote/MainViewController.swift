//
//  MediaViewController.swift
//  Denon Remote & Control
//
//  Created by Thomas Nordquist on 10.08.16.
//  Copyright © 2016 Thomas Nordquist. All rights reserved.
//

import Cocoa
import Alamofire
import PromiseKit

class MainViewController: NSViewController {
    var overlayController : NSViewController?

    @IBOutlet var songLabel : NSTextField!
    @IBOutlet var artistLabel : NSTextField!
    @IBOutlet var albumLabel : NSTextField!

    //MARK: Media Controls
    @IBOutlet var mediaControlsView: StyledView!
    @IBOutlet var playButton: NSButton!
    @IBOutlet var pauseButton: NSButton!
    @IBOutlet var nextButton: NSButton!
    @IBOutlet var previousButton: NSButton!

    @IBOutlet var ecoButton: NSButton!
    @IBOutlet var ecoLabel : NSTextField!
    @IBOutlet var volumeSlider: NSSlider!
    @IBOutlet var imageView: NSImageView!
    @IBOutlet var mediaInfo: StyledView!

    @IBAction func pauseAction(sender: AnyObject) {
        DenonCommand.MUSIC_CONTROL.PAUSE.executeWithPriority(QueuePriority.HIGH)
    }

    @IBAction func playAction(sender: AnyObject) {
        DenonCommand.MUSIC_CONTROL.PLAY.executeWithPriority(QueuePriority.HIGH)
    }

    @IBAction func nextAction(sender: AnyObject) {
        DenonCommand.MUSIC_CONTROL.NEXT.executeWithPriority(QueuePriority.HIGH)
    }

    @IBAction func previousAction(sender: AnyObject) {
        DenonCommand.MUSIC_CONTROL.PREVIOUS.executeWithPriority(QueuePriority.HIGH)
    }

    @IBAction func volumeUpAction(sender: AnyObject) {
        DenonCommand.VOLUME.UP.executeWithPriority(QueuePriority.HIGH)
    }

    @IBAction func volumeDownAction(sender: AnyObject) {
        DenonCommand.VOLUME.DOWN.executeWithPriority(QueuePriority.HIGH)
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

    @IBAction func updateVolumeAction(sender: NSSlider) {
        DenonCommand.VOLUME.PARAMETER(sender.doubleValue).executeWithPriority(QueuePriority.VERY_HIGH)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tweakStyles()
        registerObserver()
    }

    override func viewWillAppear() {
        updateInfo()
    }

    override func viewWillDisappear() {
        let sheduler = TaskSheduler.sharedSheduler()
        sheduler.removeTask(.IMAGE)
        sheduler.offScreen(.DISPLAY, offScreen: true)
        sheduler.offScreen(.VOLUME, offScreen: true)

    }

    func updateInfo() {
        let sheduler = TaskSheduler.sharedSheduler()

        let imageTask = Task(identifier: .IMAGE, onScreenInterval: 2, offScreenInterval: 10, parallel: true, task:{
            return ImageProvider.currentImage().then{ image -> Promise<AnyObject?> in
                self.imageView.image = image
                return Promise(image)
            }
        })
        sheduler.addTask(imageTask)

        let volumeTask = Task(identifier: .VOLUME, onScreenInterval: 3, offScreenInterval: 10, parallel: false, task:{
            return DenonCommand.VOLUME.QUERY.execute().then{ command -> Promise<AnyObject> in
                return Promise(command)
            }
        })
        sheduler.addTask(volumeTask)

        let displayTask = Task(identifier: .DISPLAY, onScreenInterval: 2, offScreenInterval: 30, parallel: false, task:{
            return DenonCommand.INFO.DISPLAY.execute().then{ command -> Promise<AnyObject> in
                guard let info = ResponseParser.parseMusicDisplay(command.response) else {
                    return Promise(command)
                }
                self.showMediaInformation(info)
                return Promise(command)
            }
        })

        sheduler.addTask(displayTask)
    }

    func showMediaInformation(info: MusicDisplayInformation) {
        if(nil != info.song) {
            songLabel.cell!.stringValue = info.song!
        }

        if(nil != info.album) {
            albumLabel.cell!.stringValue = info.album!
        }

        if(nil != info.artist) {
            artistLabel.cell!.stringValue = info.artist!
        }
    }

    func registerObserver() {
        let notifications = NSNotificationCenter.defaultCenter()
        notifications.addObserver(self, selector: #selector(self.updateMaxVolume), name: "MVMAX", object: nil)
        notifications.addObserver(self, selector: #selector(self.updateVolume), name: "MV", object: nil)
    }

    func updateMaxVolume() {
        guard let newValue = DataHub.getDouble("MVMAX") else {
            return
        }
        if(newValue != volumeSlider.maxValue) {
            dispatch_async(dispatch_get_main_queue()) {
                self.volumeSlider.maxValue = newValue
            }
        }
    }

    func updateVolume() {
        guard let newValue = DataHub.getDouble("MV") else {
            return
        }
        if(newValue != self.volumeSlider.doubleValue) {
            dispatch_async(dispatch_get_main_queue()) {
                self.volumeSlider.doubleValue = newValue
            }
        }
    }

    func tweakStyles() {
        volumeSlider.altIncrementValue = 0.5
        imageView.layer?.backgroundColor = NSColor.clearColor().CGColor
        imageView.image = NSImage(named: "album")

        mediaInfo.sublayer.borderWidth = 1
        mediaInfo.sublayer.backgroundColor = Theme.foregroundColor.CGColor

        view.layer?.backgroundColor = Theme.backgroundColor.CGColor

        //mediaControlsView.sublayer.backgroundColor = Theme.backgroundColor.CGColor
        albumLabel.textColor = Colors.flatWhite
        songLabel.textColor = Colors.flatWhite
        artistLabel.textColor = Colors.flatWhite
        ecoLabel.textColor = Colors.flatWhite
        ecoButton.image? = (ecoButton.image?.withTemplateColor(Theme.ecoGreen))!
    }
}
