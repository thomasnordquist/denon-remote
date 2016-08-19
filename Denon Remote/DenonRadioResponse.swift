//
//  DenonRadioResponse.swift
//  Denon Remote
//
//  Created by Thomas Nordquist on 18.08.16.
//  Copyright © 2016 Thomas Nordquist. All rights reserved.
//

import Cocoa
import SWXMLHash

struct DenonRadioResponse: XMLIndexerDeserializable {
    let count : Int?
    let items : [DenonRadioItem]?

    static func deserialize(node: XMLIndexer) throws -> DenonRadioResponse {
        return try DenonRadioResponse(
            count: node["ItemCount"].value(),
            items: node["Item"].value().filter({nil != $0}).map({$0!})
        )
    }
}