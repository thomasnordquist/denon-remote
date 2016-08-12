//
//  MusicDisplayInformation.swift
//  Denon Remote
//
//  Created by Thomas Nordquist on 12.08.16.
//  Copyright © 2016 Thomas Nordquist. All rights reserved.
//

import Cocoa

class MusicDisplayInformation: NSObject {
    let source : String?
    let song : String?
    let artist : String?
    let album : String?

    init(source: String?, song : String?, artist: String?, album: String?) {
        self.source = source
        self.song = song
        self.artist = artist
        self.album = album
    }
}
