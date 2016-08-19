//
//  TemplateImageView.swift
//  Denon Remote
//
//  Created by Thomas Nordquist on 18.08.16.
//  Copyright © 2016 Thomas Nordquist. All rights reserved.
//

import Cocoa

class TemplateImageView: NSImageView {

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.image = self.image?.withTemplateColor(Theme.buttonColor)
    }

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        // Drawing code here.
    }
    
}
