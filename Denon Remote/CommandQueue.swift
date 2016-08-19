//
//  Commands.swift
//  Denon Remote
//
//  Created by Thomas Nordquist on 12.08.16.
//  Copyright © 2016 Thomas Nordquist. All rights reserved.
//

import Cocoa
import PromiseKit
import SwiftSockets

class CommandToOld : ErrorType {}

struct CommandPromiseQueueElement {
    let promise : Promise<Command>
    let fulfill : (Command) -> Void
    let reject : (ErrorType) -> Void
    let priority: QueuePriority
    let command : Command
    var age = 0

    init(promise: Promise<Command>, fulfill: (Command) -> Void, reject: (ErrorType)->Void, priority: QueuePriority, command:Command) {
        self.promise = promise
        self.fulfill = fulfill
        self.reject = reject
        self.priority = priority
        self.command = command

    }
}

enum QueuePriority : Int {
    case VERY_LOW = 0
    case LOW = 1
    case MEDIUM = 2
    case HIGH = 3
    case VERY_HIGH = 4
}

class CommandQueue: NSObject {
    static let MAX_QUEUE_AGE = 5
    static var free = true
    static var commandQueue : [CommandPromiseQueueElement] = []

    static var currentTransaction : NSHashTable = NSHashTable()

    static internal func startTransaction(command: Command) -> TcpTransaction {
        let transaction = TcpTransaction(command: command)
        currentTransaction.addObject(transaction)

        return transaction
    }

    static internal func handleElementsInQueue() {
        if(commandQueue.count > 1) {
            print("queue size:" + String(commandQueue.count))
        }
        
        if(commandQueue.count > 0) {
            free = false
            NSThread.sleepForTimeInterval(0.3)
            let queueElement = nextQueueElement()
            removeElementFromQueue(queueElement)
            let transaction = startTransaction(queueElement.command)
            resolvePromise(queueElement, transaction: transaction)
        }
        cleanQueue()
    }

    static internal func nextQueueElement() -> CommandPromiseQueueElement {
        let prioritizedQueue = commandQueue.sort { $0.priority.rawValue > $1.priority.rawValue }
        let priority = prioritizedQueue.first?.priority.rawValue
        let oldestFirst = prioritizedQueue.filter{ $0.priority.rawValue == priority }.sort{$0.age > $1.age}

        for i in 0 ..< commandQueue.count {
            commandQueue[i].age += 1
            print(commandQueue[i].age)
        }

        return oldestFirst.first!
    }

    static internal func cleanQueue() {
        // reject old promises
        commandQueue
            .filter{ $0.age >= MAX_QUEUE_AGE }
            .forEach{ queueElement in
                queueElement.reject(CommandToOld())
            }

        commandQueue = commandQueue
            .filter{ $0.age < MAX_QUEUE_AGE }
    }

    static internal func resolvePromise(queueElement: CommandPromiseQueueElement, transaction: TcpTransaction) {

        transaction.promise.then { command -> Void in
            ResponseParser.parseCommand(command)
            queueElement.fulfill(command)
            validateCommandResponse(command)
        }.always {
            // release the transaction
            currentTransaction.removeObject(transaction)
            free = true
            handleElementsInQueue()
        }.error{ error in
            queueElement.reject(error)
        }
    }

    static internal func removeElementFromQueue(queueElement: CommandPromiseQueueElement) {
        commandQueue = commandQueue.filter({ (a) -> Bool in
            a.command !== queueElement.command
        })
    }

    static func sendCommand(command: CommandType) -> Promise<Command> {
        return self.sendCommand(command, priority: QueuePriority.MEDIUM)
    }

    static func sendCommand(command: CommandType, priority: QueuePriority) -> Promise<Command> {
        var queueElement : CommandPromiseQueueElement
        let cmd = Command(command: command)

        // preparing promise to be passed to commandQueue
        var tmpFulfill : ((Command) -> Void)! = nil
        var tmpReject : ((ErrorType) -> Void)! = nil

        let promise = Promise<Command>{fulfill, reject -> Void in
            tmpFulfill = fulfill
            tmpReject = reject
        }

        queueElement = CommandPromiseQueueElement(promise: promise, fulfill: tmpFulfill, reject: tmpReject, priority: priority, command: cmd)

        commandQueue.append(queueElement)

        if(free) {
            handleElementsInQueue()
        }


        return promise;
    }

    static internal func validateCommandResponse(command: Command) {
        let diff = command.expectedLines - command.response.count
        if(command.expectedLines > 0 && command.response.count == 0) {
            print("missing information" + command.operation + ":" + String(diff))
        } else if (diff != 0) {
            print("there is some difference " + command.operation + ":" + String(diff))
            print(command.response)
        }
    }

}
