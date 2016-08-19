//
//  Command.swift
//  Denon Remote
//
//  Created by Thomas Nordquist on 12.08.16.
//  Copyright © 2016 Thomas Nordquist. All rights reserved.
//

import Cocoa
import PromiseKit

struct DenonCommand {
    struct SIGNAL {
        static let QUERY = CommandType(prefix: "SI", parameter: "?", lines: 2)
        static func PARAMETER(source : InputSource) -> CommandType {
            return CommandType(prefix: "SI", parameter: source.name, lines: 1)
        }
    }

    struct SLEEP {
        static let QUERY = CommandType(prefix: "SLP", parameter: "?", lines: 2)
        static let OFF = CommandType(prefix: "SLP", parameter: "OFF", lines: 2)
        static func PARAMETER(minutes : Int) -> CommandType {
            let clippedMinutes = min(max(0, minutes), 120)
            let minutesPrefixedWithZeros = String(format: "%03d", clippedMinutes)
            return CommandType(prefix: "SLP", parameter: minutesPrefixedWithZeros, lines: 1)
        }
    }

    struct POWER {
        static let ON = CommandType(prefix: "PW", parameter: "ON", lines: 0)
        static let OFF = CommandType(prefix: "PW", parameter: "STANDBY", lines: 0)
        static let QUERY = CommandType(prefix: "PW", parameter: "?", lines: 3)
    }

    struct MUSIC_CONTROL {
        static let PLAY = CommandType(prefix: "NS", parameter: "9A", lines: 0)
        static let PAUSE = CommandType(prefix: "NS", parameter: "9B", lines: 0)
        static let NEXT = CommandType(prefix: "NS", parameter: "9D", lines: 0)
        static let PREVIOUS = CommandType(prefix: "NS", parameter: "9E", lines: 0)
    }

    struct MUTE {
        static let ON = CommandType(prefix: "MU", parameter: "ON", lines: 1)
        static let OFF = CommandType(prefix: "MU", parameter: "OFF", lines: 1)
    }

    struct VOLUME {
        static let QUERY = CommandType(prefix: "MV", parameter: "?", lines: 2)
        static let UP = CommandType(prefix: "MV", parameter: "UP", lines: 0)
        static let DOWN = CommandType(prefix: "MV", parameter: "DOWN", lines: 0)
        static func PARAMETER(volume : Double) -> CommandType {
            // only accepts volumes
            let newVolume = ParameterValidator.volumeParameter(0, max: 70, step: 0.5, value: volume)
            return CommandType(prefix: "MV", parameter: newVolume, lines: 0)
        }
    }

    struct CONTROL {
        static let UP = CommandType(prefix: "NS", parameter: "90", lines: 0)
        static let DOWN = CommandType(prefix: "NS", parameter: "91", lines: 0)
        static let LEFT = CommandType(prefix: "NS", parameter: "92", lines: 0)
        static let RIGHT = CommandType(prefix: "NS", parameter: "93", lines: 0)
        static let ENTER = CommandType(prefix: "NS", parameter: "94", lines: 0)
        static let PAGE_PREVIOUS = CommandType(prefix: "NS", parameter: "9Y", lines: 0)
        static let PAGE_NEXT = CommandType(prefix: "NS", parameter: "9X", lines: 0)
    }

    struct INFO {
        static let DISPLAY = CommandType(prefix: "NS", parameter: "E", lines: 9) //UTF8
    }
}

class ParameterValidator : NSObject {
    static func volumeParameter(min: Double, max: Double, step: Double, value: Double) -> String {

        if(value < min) {
            return valueToFixedDecimal(min);
        } else if(value > max) {
            return valueToFixedDecimal(max);
        } else {
            // makes sure only whole steps are returned
            var valuex10 = Int(floor(value * 10))
            let stepx10 = Int(step*10)
            let remainderx10 = (valuex10 % stepx10)
            valuex10 -= remainderx10

            return valueToFixedDecimal(Double(valuex10/10))
        }
    }

    static func valueToFixedDecimal(value: Double) -> String {
        let remainder = Int((value*10)) % 10
        let val = Int(floor(value))
        let remainderStr = (remainder != 0)
            ? String(remainder)
            : ""
        let fixedDecimal = String(format: "%02d", val) + remainderStr
        return fixedDecimal
    }
}

class CommandType : NSObject {
    let prefix : String
    let parameter : String
    let expectedLines : Int

    init(prefix: String, parameter: String, lines: Int) {
        self.prefix = prefix
        self.parameter = parameter
        self.expectedLines = lines
    }

    func execute() -> Promise<Command> {
        return CommandQueue.sendCommand(self)
    }

    func executeWithPriority(priority: QueuePriority) -> Promise<Command> {
        return CommandQueue.sendCommand(self, priority: priority)
    }
}

class Command: AnyObject {
    let operation : String
    let expectedLines : Int
    var response : [String] = []

    init(command: CommandType) {
        self.operation = command.prefix + command.parameter
        self.expectedLines = command.expectedLines
    }
}
