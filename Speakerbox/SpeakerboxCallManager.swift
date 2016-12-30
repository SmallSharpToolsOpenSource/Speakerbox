/*
	Copyright (C) 2016 Apple Inc. All Rights Reserved.
	See LICENSE.txt for this sample’s licensing information
	
	Abstract:
	Manager of SpeakerboxCalls, which demonstrates using a CallKit CXCallController to request actions on calls
*/

import UIKit
import CallKit

final class SpeakerboxCallManager: NSObject {

    var callController: Any?
    
    override init() {
        super.init()
        if #available(iOS 10.0, *) {
            callController = CXCallController()
        } else {
            // TODO: Fallback on earlier versions
            callController = nil
        }
    }

    // MARK: Actions

    func startCall(handle: String, video: Bool = false) {
        if #available(iOS 10.0, *) {
            let handle = CXHandle(type: .phoneNumber, value: handle)
            let startCallAction = CXStartCallAction(call: UUID(), handle: handle)
            
            startCallAction.isVideo = video
            
            let transaction = CXTransaction()
            transaction.addAction(startCallAction)
            
            requestTransaction(transaction)
        } else {
            // TODO: Fallback on earlier versions
        }
    }

    func end(call: SpeakerboxCall) {
        if #available(iOS 10.0, *) {
            let endCallAction = CXEndCallAction(call: call.uuid)
            let transaction = CXTransaction()
            transaction.addAction(endCallAction)
            
            requestTransaction(transaction)
        } else {
            // TODO: Fallback on earlier versions
        }
    }

    func setHeld(call: SpeakerboxCall, onHold: Bool) {
        if #available(iOS 10.0, *) {
            let setHeldCallAction = CXSetHeldCallAction(call: call.uuid, onHold: onHold)
            let transaction = CXTransaction()
            transaction.addAction(setHeldCallAction)
            
            requestTransaction(transaction)
        } else {
            // TODO: Fallback on earlier versions
        }
    }

    @available(iOS 10.0, *)
    private func requestTransaction(_ transaction: CXTransaction) {
        if let callController = callController as? CXCallController {
            callController.request(transaction) { error in
                if let error = error {
                    print("Error requesting transaction: \(error)")
                } else {
                    print("Requested transaction successfully")
                }
            }
        }
    }

    // MARK: Call Management

    static let CallsChangedNotification = Notification.Name("CallManagerCallsChangedNotification") 

    private(set) var calls = [SpeakerboxCall]()

    func callWithUUID(uuid: UUID) -> SpeakerboxCall? {
        guard let index = calls.index(where: { $0.uuid == uuid }) else {
            return nil
        }
        return calls[index]
    }

    func addCall(_ call: SpeakerboxCall) {
        calls.append(call)

        call.stateDidChange = { [weak self] in
            self?.postCallsChangedNotification()
        }

        postCallsChangedNotification()
    }

    func removeCall(_ call: SpeakerboxCall) {
        calls.removeFirst(where: { $0 === call })
        postCallsChangedNotification()
    }

    func removeAllCalls() {
        calls.removeAll()
        postCallsChangedNotification()
    }

    private func postCallsChangedNotification() {
        NotificationCenter.default.post(name: type(of: self).CallsChangedNotification, object: self)
    }

    // MARK: SpeakerboxCallDelegate

    func speakerboxCallDidChangeState(_ call: SpeakerboxCall) {
        postCallsChangedNotification()
    }

}
