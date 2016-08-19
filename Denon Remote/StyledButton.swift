//
//  StyledButton.swift
//  Denon Remote
//
//  Created by Thomas Nordquist on 11.08.16.
//  Copyright © 2016 Thomas Nordquist. All rights reserved.
//

import Cocoa

class StyledButton: NSButton {
    let sublayer: CALayer = CALayer()
    var originalImage : NSImage!

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        originalImage = image
        tweakStyles()
    }

    func tweakStyles() {
        self.wantsLayer = true

        self.layer?.addSublayer(sublayer)
        sublayer.frame = self.bounds

        setColor(Theme.buttonColor)
        setAlternateColor(Theme.buttonActiveColor)
    }

    func setColor(color: NSColor) {
        image = originalImage.withTemplateColor(color)
    }


    func setAlternateColor(color: NSColor) {
        alternateImage = originalImage.withTemplateColor(color)
    }

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
    }
    
}
