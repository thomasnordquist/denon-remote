//
//  IRadioScrollView.swift
//  Denon Remote
//
//  Created by Thomas Nordquist on 18.08.16.
//  Copyright © 2016 Thomas Nordquist. All rights reserved.
//

import Cocoa

class IRadioScrollView: NSScrollView {
    var timer : NSTimer!
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        hasVerticalRuler = true
        hasVerticalScroller = true
        hasHorizontalScroller = false
        autohidesScrollers = false
        scrollerStyle = NSScrollerStyle.Legacy
        verticalScroller?.knobStyle = NSScrollerKnobStyle.Light
        verticalScroller?.wantsLayer=true
        verticalScroller?.updateLayer()
        verticalScroller?.layer?.backgroundColor = Theme.foregroundColor.CGColor
        verticalScroller?.controlTint = NSControlTint.BlueControlTint
        //verticalScroller?.layer?.backgroundColor = Colors.emerald.CGColor
        borderType = NSBorderType.NoBorder
    }

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }


}
