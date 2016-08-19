//
//  MediaControlView.swift
//  Denon Remote
//
//  Created by Thomas Nordquist on 11.08.16.
//  Copyright © 2016 Thomas Nordquist. All rights reserved.
//

import Cocoa

class StyledView: NSView {
    let sublayer = CALayer()

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        tweakStyles(Theme.MediaControls)
    }


    func tweakStyles(style : ViewStyle) {
        wantsLayer = true

        self.layer?.addSublayer(sublayer)
        sublayer.frame = self.bounds
        sublayer.cornerRadius = style.borderRadius
        sublayer.borderWidth = style.borderWidth

        //sublayer.backgroundColor = style.backgroundColor.CGColor
    }

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        subviews.forEach({ view in
            if let textField = view as? NSTextField {
                textField.backgroundColor = NSColor.clearColor()
                textField.textColor = Theme.fontColor
            }
        })

        // Drawing code here.
    }
    
}
