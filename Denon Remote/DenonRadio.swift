//
//  DenonRadio.swift
//  Denon Remote
//
//  Created by Thomas Nordquist on 17.08.16.
//  Copyright © 2016 Thomas Nordquist. All rights reserved.
//

import Cocoa
import Alamofire
import AlamofireImage
import PromiseKit
import SWXMLHash
import AEXML

class UnexpectedResponse: ErrorType {}
class XMLParsingError: ErrorType {}

class DenonRadio: NSObject {
    static func list() -> Promise<DenonRadioResponse>{
        return list(nil)
    }

    static func logo(item: DenonRadioItem) -> Promise<(DenonRadioItem, NSImage)>{
        return Promise{ fulfill, reject in
            if(nil != item.logo) {
            Alamofire.request(.GET, item.logo!)
                .validate()
                .responseImage({response in
                    if let image = response.result.value {
                        fulfill(item, image)
                    } else {
                        reject(UnexpectedResponse())
                    }
                })
            } else {
                reject(UnexpectedResponse())
            }
        }
    }

    static func play(radioStation: DenonRadioItem?) -> Promise<Void> {
        return Promise{ fulfill, reject in
            if let item = radioStation {
                if(item.itemType != .STATION) {
                    reject(UnexpectedResponse())
                }

                let command = DenonRadioPlayCommand(item: item)
                print(command.toString())
                let host = Amplifier.sharedInstance.host
                let url = "http://" + host + "/goform/AppCommand.xml"

                Alamofire.request(.POST, url, parameters: [:], encoding: .Custom({
                    (convertible, params) in
                    let mutableRequest = convertible.URLRequest.copy() as! NSMutableURLRequest

                    let data = command.toString().dataUsingEncoding(NSUTF8StringEncoding)
                    mutableRequest.HTTPBody = data
                    mutableRequest.setValue("text/xml; charset=\"utf-8\"", forHTTPHeaderField:"content-type")

                    return (mutableRequest, nil)
                }))
                    .validate()
                    .responseString { (response) in
                        fulfill()
                }
            } else {
                reject(UnexpectedResponse())
            }
            reject(UnexpectedResponse())
        }
    }

    static func list(item: DenonRadioItem?) -> Promise<DenonRadioResponse>{
        return Promise{ fulfill, reject in
            var url = "http://denon.vtuner.com/setupapp/denon/asp/browsexm2/navXML.asp?rLev=&gofile=Search"

            if(nil != item && nil != item!.url) {
                url = item!.url!
            }

            Alamofire.request(.GET, url)
                .validate()
                .responseString { (response) in
                    if let str = response.result.value {
                        let xml = SWXMLHash.parse(str)
                        do {
                            let denonResponse: DenonRadioResponse = try xml["ListOfItems"].value()
                            fulfill(denonResponse)
                        } catch {
                            reject(XMLParsingError())
                        }
                    } else {
                        reject(UnexpectedResponse())
                    }
                }
        }
    }
}
