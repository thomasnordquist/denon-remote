//
//  NSImage+TemplateColor.swift
//  
//
//  Created by Thomas Nordquist on 13.08.16.
//
//

import Cocoa

extension NSImage {
    func withTemplateColor(color: NSColor) -> NSImage {
        let image = self
        var rect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue)
        let context = CGBitmapContextCreate(
            nil,
            Int(image.size.width),
            Int(image.size.height),
            8,
            0,
            colorSpace,
            bitmapInfo.rawValue)

        let cgImage = image.CGImageForProposedRect(&rect, context: nil, hints: nil)

        CGContextDrawImage(context, rect, cgImage)
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextSetBlendMode(context, CGBlendMode.SourceAtop)
        CGContextFillRect(context, rect);

        return NSImage(CGImage: CGBitmapContextCreateImage(context)!, size: image.size)
    }

    func scaledToCenter() -> NSImage {
        let image = self
        var rect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue)
        let context = CGBitmapContextCreate(
            nil,
            Int(image.size.width),
            Int(image.size.height),
            8,
            0,
            colorSpace,
            bitmapInfo.rawValue)

        let cgImage = image.CGImageForProposedRect(&rect, context: nil, hints: nil)

        CGContextDrawImage(context, rect, cgImage)
        CGContextScaleCTM(context, 0.8, 0.8)
        CGContextSetBlendMode(context, CGBlendMode.SourceAtop)
        CGContextFillRect(context, rect);

        return NSImage(CGImage: CGBitmapContextCreateImage(context)!, size: image.size)
    }
}
