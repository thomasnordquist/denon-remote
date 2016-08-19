//
//  Amplifier.swift
//  Denon Remote
//
//  Created by Thomas Nordquist on 18.08.16.
//  Copyright © 2016 Thomas Nordquist. All rights reserved.
//

import Cocoa

class Amplifier: NSObject {
    static let sharedInstance = Amplifier()

    let host : String! = "192.168.0.211"
}