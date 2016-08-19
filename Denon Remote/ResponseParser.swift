//
//  ResponseParser.swift
//  Denon Remote
//
//  Created by Thomas Nordquist on 12.08.16.
//  Copyright © 2016 Thomas Nordquist. All rights reserved.
//

import Cocoa
enum ResponseDataType : StringLiteralType {
    case DECIMAL_FIXED // fixed decimal (10.5 will be received as 105)
    case DECIMAL
    case INTEGER_POSITIVE
    case STATE // boolean on/off
    case DISPLAY
    case STRING
}

struct DisplayInformationBitMask {
    static let MUSIC : uint32 = 0b0000_0001
    static let DIRECTORY : uint32 = 0b0000_0010
    static let CURSOR : uint32 = 0b0000_1000
    static let PICTURE : uint32 = 0b0100_0000
}

enum ResponseState: String {
    case ON = "ON"
    case OFF = "OFF"
    case STANDBY = "STANDBY"
    case AUTO = "AUTO"
}

let NOW_PLAYING = "Now Playing "

class ResponseParser: NSObject {
    static let prefixes : [(String, ResponseDataType)] = [
        ("MV", .DECIMAL_FIXED),
        ("MVMAX ", .DECIMAL),
        ("SLP", .INTEGER_POSITIVE),
        ("PW", .STATE),
        ("MU", .STATE),
        ("NSE", .DISPLAY),
        ("SI", .STRING),
        // sort them by length so longest prefixes are prefered over shorter ones
        ].sort { (a, b) -> Bool in
            return (a.0).characters.count > (b.0).characters.count
        }

    static func parseCommand(command: Command) {
        command.response.forEach { s in
            parse(s)
        }
    }

    static func parse(response: String) {
        let trimmedResponse = response.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())

        let matchinPrefixes = prefixes.filter { prefix, _ -> Bool in
            return trimmedResponse.hasPrefix(prefix)
        }

        guard let prefix = matchinPrefixes.first else {
            return
        }

        let idx = trimmedResponse.startIndex.advancedBy(prefix.0.characters.count)
        let valueStr = trimmedResponse.substringFromIndex(idx)
        let prefixStr = prefix.0

        switch prefix.1 {
        case .DECIMAL:
            if let double = Double(valueStr) {
                DataHub.setData(prefixStr, double: double)
            }
            break
        case .INTEGER_POSITIVE:
            if let int = Int(valueStr) {
                DataHub.setData(prefixStr, int: int)
            } else {
                DataHub.setData(prefixStr, int: -1)
            }
            break
        case .DECIMAL_FIXED:
            DataHub.setData(prefixStr, double: parse3DigitsFixedDecimal(valueStr))
            break
        case .STATE:
            guard let state = parseState(valueStr) else {
                return
            }
            DataHub.setData(prefixStr, state: state)
            break
        case .DISPLAY:
            // don't handle via the datahub, will be handled by promises
            break;
        case .STRING:
            //print(valueStr)
            DataHub.setData(prefixStr, string: valueStr)
            break;
        default:
            print("Shouldn't have happened")
        }
    }

    static internal func parseState(state: String) -> ResponseState? {
        return ResponseState(rawValue: state)
    }

    static func parseDisplayResponse(response: [String]) -> DisplayResponse? {
        //list of strings like "NSE2"
        var displayLines : [[String]] = []
        response.forEach { (s: String) in
            do {
                let expr = try NSRegularExpression(pattern: "NSE([0-9])(.)(.*)", options: .DotMatchesLineSeparators)
                let matches = expr.matchesInString(s, options: .WithoutAnchoringBounds, range: NSMakeRange(0, s.characters.count))

                let str = s as NSString
                guard let match = matches.first else {
                    return
                }

                let result = (1..<match.numberOfRanges).map{ i -> String in
                    str.substringWithRange(match.rangeAtIndex(i))
                }
                displayLines.append(result)
            } catch { error
                
            }
        }
        return DisplayResponse.factory(displayLines)

    }

    static func parseMusicDisplay(input: [String]) -> MusicDisplayInformation? {
        guard let displayResponse = parseDisplayResponse(input) else {
            return nil
        }

        let source = displayResponse.response[0].text
        let song = displayResponse.response[1].text
        let artist = displayResponse.response[2].text
        let album = displayResponse.response[4].text

        return MusicDisplayInformation(source: source, song: song, artist: artist, album: album)
    }

    /*
     * examples:
     * 055 => 05.5
     * 105 => 10.5
     * 50  => 50.0
     */
    static func parse3DigitsFixedDecimal(str: String) -> Double {
        let characters = str.characters.count
        let isDigit = nil != Int(str)

        if( isDigit && (characters < 2 || characters > 3) ) {
            print("Illegal argument, returning 0")
            return 0
        } else {
            let a = Double(str.substringToIndex(str.startIndex.advancedBy(2)))!
            if(characters == 3) {
                let afterDecimalPoint = Double(str.substringFromIndex(str.startIndex.advancedBy(2)))! / 10.0
                return a+afterDecimalPoint
            } else {
                return a
            }
        }
    }
}
