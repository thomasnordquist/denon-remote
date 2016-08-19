//
//  IRadioViewController.swift
//  Denon Remote
//
//  Created by Thomas Nordquist on 17.08.16.
//  Copyright © 2016 Thomas Nordquist. All rights reserved.
//

import Cocoa
import SWXMLHash

//import OpenSSL

class IRadioViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    @IBOutlet var tableView: NSTableView!
    @IBOutlet var stationImage: NSImageView!

    @IBOutlet var stationName: NSTextField!
    @IBOutlet var stationQuality: NSTextField!
    @IBOutlet var stationEncoding: NSTextField!
    var currentItem : DenonRadioItem?

    var items : [DenonRadioItem] = []
    override func viewDidLoad() {
        tableView.backgroundColor = Theme.backgroundColor
        showItem(DenonRadioItem.emptyItem)
        loadItems(nil)
    }

    func showItem(item: DenonRadioItem) {
        currentItem = item

        stationName.stringValue = item.title!
        stationQuality.stringValue = item.bandwidth!
        stationEncoding.stringValue = item.mime!
        if(item.itemType == .STATION) {
            DenonRadio.logo(item).then({ _, image in
                if(self.currentItem!.id == item.id) {
                    self.stationImage.image = image
                }
            })
        } else {
            stationImage.image = NSImage(named: "radio")?.withTemplateColor(Theme.buttonColor)
        }
    }

    func loadItems(item: DenonRadioItem?) {
        DenonRadio.list(item).then{ items -> Void in
            guard let newItems = items.items else {
                return
            }
            self.items = newItems
            self.tableView.reloadData()
        }.error { _ in
            // if the call fails it will fallback on the initial path, but only if a path was specified, this prevents an endless loop of requests
            if(nil != item) {
                self.loadItems(nil)
            }
        }
    }

    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        print("items" + String(items.count))
        return items.count;
    }

    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let cell = tableView.makeViewWithIdentifier("station", owner: nil) as? NSTableCellView! {
            let item = items[row]

            if item.title != nil {
                title = items[row].title
            } else {
                title = ""
            }
            cell.textField?.backgroundColor = NSColor.clearColor()
            cell.textField?.textColor = Theme.fontColor
            //cell.imageView?.layer?.backgroundColor = NSColor.whiteColor().CGColor

            switch item.itemType {
            case .DIR:
                cell.imageView?.image = NSImage(named: "folder")?.withTemplateColor(NSColor.whiteColor())
                break
            case .PREVIOUS:
                cell.imageView?.image = NSImage(named: "arrow-left")?.withTemplateColor(NSColor.whiteColor())
                break
            case .STATION:
                cell.imageView?.image = NSImage(named: "radio")?.withTemplateColor(NSColor.whiteColor())
                break
            default:
                break
            }

            if(item.itemType == .STATION) {
                DenonRadio.logo(item).then({ (item, image) in
                    if(cell.textField?.stringValue == item.title) { // TODO: Fix me
                        cell.imageView?.image = image
                    }
                })
            }

            cell.textField?.stringValue = title!
            return cell
        }
        return nil
    }

    func tableView(tableView: NSTableView, shouldSelectRow row: Int) -> Bool {

        if(row >= items.count || row < 0) {
            return false
        }

        let item = items[row]
        if(item.itemType == .STATION) {
            showItem(item)
        }
        return true
    }

    @IBAction func performClick(sender: AnyObject) {
        print("click")
        let row = tableView.selectedRow
        if(row >= items.count || row < 0) {
            return
        }
        let item = items[row]

        if(item.itemType != .STATION) {
            loadItems(item)
        }

    }

    @IBAction func play(sender:NSButton) {
        DenonRadio.play(currentItem)
    }

    func blowFishDecrypt() {
       // Blow
    }

}
