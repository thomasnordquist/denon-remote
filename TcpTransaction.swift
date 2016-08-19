//
//  TcpTransaction.swift
//  Denon Remote
//
//  Created by Thomas Nordquist on 13.08.16.
//  Copyright © 2016 Thomas Nordquist. All rights reserved.
//

import Cocoa
import PromiseKit
import CocoaAsyncSocket


class NoConnectionError : ErrorType {}

class TcpTransaction {
    let promise : Promise<Command>
    let command : Command
    let fulfill : (Command) -> Void
    let reject : (ErrorType) -> Void
    var asyncSocket : GCDAsyncSocket! = nil

    init(command: Command) {
        self.command = command


        // save promises closures in object
        // this allows them to be called by delegates
        var tmpFullfill : ((Command) -> Void)! = nil
        var tmpReject: ((ErrorType) -> Void)! = nil
        self.promise = Promise{
            fulfill, reject in
            tmpFullfill = fulfill
            tmpReject = reject
        }
        self.fulfill = tmpFullfill
        self.reject = tmpReject

        beginTransaction()
    }

    func beginTransaction() {
        asyncSocket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        do {
            let host = Amplifier.sharedInstance.host
            try asyncSocket.connectToHost(host, onPort: 23, withTimeout: 0.2)
        } catch {
            reject(NoConnectionError())
        }
    }
}

extension TcpTransaction : GCDAsyncSocketDelegate{
    //MARK: Connection Lifecycle
    @objc func socket(sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        let operation = (command.operation + "\r").dataUsingEncoding(NSUTF8StringEncoding)!
        asyncSocket.writeData(operation, withTimeout: 0.05, tag: 0)
        asyncSocket.readDataWithTimeout(0.2, tag: 0)
    }

    @objc func socket(sock: GCDAsyncSocket, didReadData data: NSData, withTag tag: Int) {
        asyncSocket.readDataWithTimeout(0.1, tag: 0)
        let s = String(NSString(data: data, encoding: NSUTF8StringEncoding)!)
        command.response.appendContentsOf(responseLines(s))
    }

    @objc func socketDidDisconnect(sock: GCDAsyncSocket, withError err: NSError?) {
        //print(err?.code)
        fulfill(command)
    }

    // splits a response by the <CR> character and trims the result
    // only returns lines with possible response
    func responseLines(response: String) -> [String] {
        return response.characters.split("\r")
            .map(String.init)
            .map{ $0.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) }
            .filter { !$0.isEmpty }
    }
}
