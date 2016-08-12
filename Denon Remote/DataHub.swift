//
//  DataHub.swift
//  Denon Remote
//
//  Created by Thomas Nordquist on 12.08.16.
//  Copyright © 2016 Thomas Nordquist. All rights reserved.
//

import Cocoa

class DataHub: NSObject {
    static var dataDouble : [String : Double] = Dictionary()
    static var dataBool : [String : Bool] = Dictionary()
    static var dataString : [String : String] = Dictionary()
    static var dataState : [String : ResponseState] = Dictionary()

    static func setData(prefix: String, double: Double) {
        let path = prefix.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        dataDouble[path] = double
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: path, object: nil))
    }

    static func setData(prefix: String, string: String) {
        let path = prefix.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        dataString[path] = string
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: path, object: nil))
    }

    static func setData(prefix: String, bool: Bool) {
        let path = prefix.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        dataBool[path] = bool
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: path, object: nil))
    }

    static func setData(prefix: String, state: ResponseState) {
        let path = prefix.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        dataState[path] = state
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: path, object: nil))
    }

    static func getBool (path: String) -> Bool? {
        let result = dataBool[path]
        return nil != result ? result! : false
    }

    static func getDouble (path: String) -> Double? {
        let result = dataDouble[path]
        return nil != result ? result! : 0.0
    }

    static func getString (path: String) -> String? {
        let result = dataString[path]
        return result
    }

    static func getState (path: String) -> ResponseState? {
        let result = dataState[path]
        return result
    }
}
