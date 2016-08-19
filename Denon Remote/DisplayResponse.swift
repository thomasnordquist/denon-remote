//
//  DisplayResponse.swift
//  Denon Remote
//
//  Created by Thomas Nordquist on 15.08.16.
//  Copyright © 2016 Thomas Nordquist. All rights reserved.
//

import Cocoa



struct DisplayResponseLine {
    let lineNumber : Int
    let mask : UInt32
    let text : String

    static func factory(input: [String]) -> DisplayResponseLine? {
        if(input.count < 3) {
            return nil
        }

        guard let lineNumber = Int(input[0]) else {
            return nil
        }

        let mask : UInt32 = input[1].unicodeScalars.first!.value

        return DisplayResponseLine(lineNumber: lineNumber, mask: mask, text: input[2])
    }
}

struct DisplayResponse {
    let response : [DisplayResponseLine]

    static func factory(input: [[String]]) -> DisplayResponse? {
        let lines = input.map { DisplayResponseLine.factory($0) }
        guard let firstLine = lines.indexOf({ $0?.lineNumber==0 }) else {
            return nil
        }

        // we start with the first line containing lineNumber 0
        // this way we can keep prefixed but intact data
        let result = lines.dropFirst(firstLine)
            .filter{ $0 != nil }
            .sort{ $0!.lineNumber < $1!.lineNumber }
            .map{ $0! }

        if(result.count != 9) {
            return nil
        } else {
            if(firstLine > 0) {
                print("Display response prefixed but was able to recover")
            }
            return DisplayResponse(response: result)
        }
    }
}

