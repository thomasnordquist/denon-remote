//
//  DenonRadioItem.swift
//  Denon Remote
//
//  Created by Thomas Nordquist on 18.08.16.
//  Copyright © 2016 Thomas Nordquist. All rights reserved.
//

import Cocoa
import SWXMLHash

enum DenonRadioItemTypes: String {
    case STATION = "Station"
    case DIR = "Dir"
    case PREVIOUS = "Previous"
    case UNKNOWN = ""
}

struct DenonRadioItem: XMLIndexerDeserializable {
    let title : String?
    let url: String?
    let urlBackup: String?
    let logo: String?
    let id: Int?
    let bandwidth: String?
    let mime: String?
    let itemType: DenonRadioItemTypes

    static let emptyItem = DenonRadioItem(itemType:.UNKNOWN, title: "", url: "", urlBackup:"", id: -1, logo: "", bandwidth:"",  mime:"")

    init(itemType: DenonRadioItemTypes, title: String?, url: String?, urlBackup: String?) {
        self.itemType = itemType
        self.title = title
        self.url = url
        self.urlBackup = urlBackup
        self.id = -1
        self.logo = nil
        self.bandwidth = ""
        self.mime = nil
    }

    init(itemType: DenonRadioItemTypes, title: String?, url: String?, urlBackup: String?, id: Int?, logo: String?, bandwidth: String?, mime: String?) {
        self.itemType = itemType
        self.title = title
        self.url = url
        self.urlBackup = urlBackup
        self.id = id
        self.logo = logo
        self.bandwidth = bandwidth
        self.mime = mime
    }

    static func deserialize(node: XMLIndexer) throws -> DenonRadioItem {
        var itemType : DenonRadioItemTypes? = try DenonRadioItemTypes(rawValue: node["ItemType"].value())
        if(nil == itemType) {
            itemType = DenonRadioItemTypes.UNKNOWN
        }

        switch itemType! {
        case .STATION:
            return try DenonRadioItem(
                itemType: DenonRadioItemTypes.STATION,
                title: node["StationName"].value(),
                url: node["StationUrl"].value(),
                urlBackup: nil,
                id: node["StationId"].value(),
                logo: node["Logo"].value(),
                bandwidth: node["StationBandWidth"].value(),
                mime: node["StationMime"].value())
        case .PREVIOUS:
            return try DenonRadioItem(
                itemType: DenonRadioItemTypes.PREVIOUS,
                title: "Previous",
                url: node["UrlPrevious"].value(),
                urlBackup: node["UrlPreviousBackup"].value()
            )
        case .DIR:
            return try DenonRadioItem(
                itemType: DenonRadioItemTypes.DIR,
                title: node["Title"].value(),
                url: node["UrlDir"].value(),
                urlBackup: node["UrlDirBackup"].value()
            )
        case .UNKNOWN:
            return try DenonRadioItem(
                itemType: DenonRadioItemTypes.UNKNOWN,
                title: node["Title"].value(),
                url: node["UrlDir"].value(),
                urlBackup: node["UrlDirBackup"].value()
            )
        }
    }
}