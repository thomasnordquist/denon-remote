//
//  ImageProvider.swift
//  Denon Remote
//
//  Created by Thomas Nordquist on 13.08.16.
//  Copyright © 2016 Thomas Nordquist. All rights reserved.
//

import Cocoa
import PromiseKit
import Alamofire
import AlamofireImage

class ImageProvider: NSObject {
    static let defaultImage : NSImage? = NSImage(named: "photo")?.withTemplateColor(Colors.flatWhite)

    static func currentImage() -> Promise<NSImage?> {
        return Promise { fulfill, reject in
            guard let source = DataHub.getString("SI") else {
                fulfill(defaultImage)
                return
            }

            print(source)

            switch source {
            case "BT":
                fulfill(NSImage(named: "bluetooth")!.withTemplateColor(Theme.bluetoothBlue))
                break
            case "IRADIO":
                loadArtwork()
                    .then{fulfill($0)}
                    .error{_ in fulfill(NSImage(named: "input-net"))}
                break
            case "NET":
                loadArtwork()
                    .then{fulfill($0)}
                    .error{_ in fulfill(NSImage(named: "input-net"))}
                break

            case "USB/IPOD":
                loadArtwork()
                    .then{fulfill($0)}
                    .error{_ in fulfill(NSImage(named: "usb"))}
                break
            default:
                fulfill(defaultImage)
            }

        }
    }

    static func loadArtwork() -> Promise<NSImage?> {
        return Promise{ fulfill, reject -> Void in
            let host = Amplifier.sharedInstance.host
            Alamofire.request(.GET, "http://" + host + "/NetAudio/art.asp-jpg")
                .responseImage { response in
                    if(nil != response.result.error) {
                        reject(response.result.error!)
                    } else {
                        fulfill(response.result.value)
                    }
            }

        }
    }
}
