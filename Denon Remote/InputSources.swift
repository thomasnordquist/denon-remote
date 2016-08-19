//
//  InputSources.swift
//  Denon Remote
//
//  Created by Thomas Nordquist on 19.08.16.
//  Copyright © 2016 Thomas Nordquist. All rights reserved.
//

import Cocoa

struct InputSource {
    let label : String
    let name : String
}

struct Sources{
    static let BT = InputSource(label: "Bluetooth", name: "BT")
    static let NET = InputSource(label: "Network", name: "NET")
    static let DVD = InputSource(label: "DVD", name: "DVD")
    static let CD = InputSource(label: "CD", name: "CD")
    static let TV = InputSource(label: "TV", name: "TV")
    static let BD = InputSource(label: "BD", name: "BD")
    static let GAME = InputSource(label: "GAME", name: "GAME")
    static let PHONO = InputSource(label: "Phono", name: "PHONO")
    static let TUNER = InputSource(label: "Tuner", name: "Tuner")
    static let INTERNET_RADIO = InputSource(label: "Internet Radio", name: "IRADIO")
    static let INTERNET_RADIO_FAVORITES = InputSource(label: "iRadio Favorites", name: "FVP")
    static let INTERNET_RADIO_RECENTLY = InputSource(label: "iRadio Recent", name: "IRP")
    static let USB = InputSource(label: "USB-Storage", name: "USB")
    static let USB_IPOD = InputSource(label: "USB/iPod", name: "USB/IPOD")
}

class InputSources: NSObject {
    static let sharedInstance = InputSources()
    var sources : [InputSource] = [
        Sources.BT,
        Sources.NET,
        Sources.CD,
        Sources.DVD,
        Sources.BD,
        Sources.TV,
        Sources.GAME,
        Sources.INTERNET_RADIO,
        Sources.INTERNET_RADIO_FAVORITES,
        Sources.INTERNET_RADIO_RECENTLY,
        Sources.USB_IPOD
    ]
}
