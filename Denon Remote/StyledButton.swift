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

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        tweakStyles()

    }

    func tweakStyles() {
        self.wantsLayer = true

        self.layer?.addSublayer(sublayer)
        sublayer.frame = self.bounds

        let _image : NSImage = image!.copy() as! NSImage

        image = _image.withTemplateColor(Theme.buttonColor)
        //image = image!.scaledToCenter()
        alternateImage = _image.withTemplateColor(Theme.buttonActiveColor)
    }

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
}
