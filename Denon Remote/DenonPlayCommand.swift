//
//  DenonPlayCommand.swift
//  Denon Remote
//
//  Created by Thomas Nordquist on 18.08.16.
//  Copyright © 2016 Thomas Nordquist. All rights reserved.
//

import Cocoa
import AEXML

struct DenonRadioPlayCommand {
    let title: String
    let url: String
    let mime: String
    let cmd: String = "SetvTunerPlay"

    init(item: DenonRadioItem) {
        self.title = item.title!
        self.url = item.url!
        self.mime = item.mime!
    }

    func toString() -> String {
        let root = AEXMLDocument()
        let tx = root.addChild(name: "tx")
        tx.addChild(name: "cmd", value: cmd, attributes: ["id": "1"])
        tx.addChild(name: "url", value: url)
        tx.addChild(name: "mime", value: mime)
        tx.addChild(name: "title", value: title)

        return root.xmlString
    }
}