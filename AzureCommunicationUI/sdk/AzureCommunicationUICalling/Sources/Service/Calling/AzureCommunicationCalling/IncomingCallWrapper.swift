//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationCalling

internal class IncomingCallWrapper: NSObject, CallsUpdatedProtocol {
    private let logger: Logger
    private let events: CallComposite.Events
    private var incomingCall: IncomingCall?

    init(logger: Logger,
         events: CallComposite.Events) {
        self.logger = logger
        self.events = events
    }

    func onIncomingCall(incomingCall: IncomingCall) {
        logger.debug("LogTestTest: onIncomingCall success -- calls received")
        self.incomingCall = incomingCall
        self.incomingCall?.delegate = self
        updateIncomingCallEventHandler(incomingCallInfo: CallCompositeIncomingCallInfo(
            callId: incomingCall.id,
            callerDisplayName: incomingCall.callerInfo.displayName,
            callerIdentifierRawId: incomingCall.callerInfo.identifier.rawId))
    }

    private func updateIncomingCallEventHandler(incomingCallInfo: CallCompositeIncomingCallInfo) {
//        guard let onIncomingCallEventHandler = events.onIncomingCall else {
//            return
//        }
//        onIncomingCallEventHandler(incomingCallInfo)
   }

    func dispose() {
        self.incomingCall?.delegate = nil
        self.incomingCall = nil
    }
}

extension IncomingCallWrapper: IncomingCallDelegate {
    func incomingCall(_ incomingCall: IncomingCall, didEnd args: PropertyChangedEventArgs) {
//        guard let onIncomingCallEnded = events.onIncomingCallEnded,
//              let callEndReason = incomingCall.callEndReason else {
//            return
//        }
//        let callEndInfo = CallCompositeIncomingCallEndedInfo(
//            code: Int(callEndReason.code),
//            subCode: Int(callEndReason.subcode)
//        )
//        onIncomingCallEnded(callEndInfo)
    }
}
