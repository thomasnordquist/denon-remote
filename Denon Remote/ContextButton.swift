//
//  ContextButton.swift
//  Denon Remote
//
//  Created by Thomas Nordquist on 19.08.16.
//  Copyright © 2016 Thomas Nordquist. All rights reserved.
//

import Cocoa

struct ContextButtonItem {
    let label: String
    let task: () -> Void
}

class ContextButtonTaskContainer : AnyObject {
    let task: () -> Void
    init(task: () -> Void) {
        self.task = task
    }
}

class ContextButton: StyledButton {
    var contextMenu = NSMenu()

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.action = #selector(self.showMenu(_:))
        self.target = self
    }

    func showMenu(sender: AnyObject) {
        contextMenu.popUpMenuPositioningItem(nil, atLocation: NSEvent.mouseLocation(), inView: nil)
    }

    func addItem(item: ContextButtonItem) -> ContextButton{
        let menuItem = NSMenuItem(title: item.label, action:#selector(handleTask(_:)), keyEquivalent: "")
        menuItem.representedObject = ContextButtonTaskContainer(task: item.task)
        menuItem.target = self
        contextMenu.addItem(menuItem)
        return self
    }

    func handleTask(sender: NSMenuItem) {
        if let taskContainer = sender.representedObject as? ContextButtonTaskContainer {
            taskContainer.task()
        }
    }
}
