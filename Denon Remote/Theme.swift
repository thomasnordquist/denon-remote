//
//  Theme.swift
//  Denon Remote
//
//  Created by Thomas Nordquist on 11.08.16.
//  Copyright © 2016 Thomas Nordquist. All rights reserved.
//

import Cocoa
struct ViewStyle {
    let borderRadius : CGFloat
    let borderWidth : CGFloat
    let backgroundColor : NSColor
}

// https://flatuicolors.com/
class Colors {
    static let flatWhite = NSColor(colorLiteralRed: 0.925, green: 0.941, blue: 0.945, alpha: 1) // clouds
    static let beliezeHole = NSColor(colorLiteralRed: 0.161, green: 0.502, blue: 0.725, alpha: 1) // belieze hole

    static let midnightBlue = NSColor(colorLiteralRed: 0.173, green: 0.243, blue: 0.314, alpha: 1) //	17.3, 24.3, 31.4

    static let emerald = NSColor(colorLiteralRed: 0.1267, green: 0.5620, blue: 0.3113, alpha: 1)

    static let bluetoothBlue = NSColor(colorLiteralRed: 0.0, green: 0.3394, blue: 0.6606, alpha: 1)
}

class Theme: NSObject {
    static let bluetoothBlue = Colors.bluetoothBlue

    static let ecoGreen = Colors.emerald

    static let buttonPowerColorOff = NSColor(colorLiteralRed: 0.9, green: 0.9, blue: 0.9, alpha: 1)
    static let buttonPowerColorOn = NSColor(colorLiteralRed: 0.9, green: 0.9, blue: 0.9, alpha: 1)

    static let buttonColor = Colors.flatWhite
    static let buttonActiveColor = Colors.beliezeHole
    static let backgroundColor = Colors.midnightBlue
    static let foregroundColor = Colors.beliezeHole
    static let MediaControls = ViewStyle(
        borderRadius: 5.0,
        borderWidth: 0.0,
        backgroundColor: NSColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.3)
    )

}
