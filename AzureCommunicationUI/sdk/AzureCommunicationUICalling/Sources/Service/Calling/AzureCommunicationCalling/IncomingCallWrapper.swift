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
    private var lastIncomingCallID: String

    init(logger: Logger,
         events: CallComposite.Events) {
        logger.debug("IncomingCallWrapper init")
        self.logger = logger
        self.events = events
        self.lastIncomingCallID = ""
    }

    func getLastIncomingCallId() -> String {
        return lastIncomingCallID
    }

    func onIncomingCall(incomingCall: IncomingCall) {
        self.incomingCall = incomingCall
        lastIncomingCallID = incomingCall.id
        logger.debug("onIncomingCall call id \(self.lastIncomingCallID)")
        self.incomingCall?.delegate = self
        updateIncomingCallEventHandler(incomingCallInfo: CallCompositeIncomingCallInfo(
            callId: incomingCall.id,
            callerDisplayName: incomingCall.callerInfo.displayName,
            callerIdentifierRawId: incomingCall.callerInfo.identifier.rawId))
    }

    private func updateIncomingCallEventHandler(incomingCallInfo: CallCompositeIncomingCallInfo) {
        guard let onIncomingCallEventHandler = events.onIncomingCall else {
            return
        }
        onIncomingCallEventHandler(incomingCallInfo)
   }

    func dispose() {
        logger.debug("incoming call dispose")
        incomingCall?.delegate = nil
        incomingCall = nil
        lastIncomingCallID = ""
    }
}

extension IncomingCallWrapper: IncomingCallDelegate {
    func incomingCall(_ incomingCall: IncomingCall, didEnd args: PropertyChangedEventArgs) {
        guard let onIncomingCallEnded = events.onIncomingCallEnded,
              let callEndReason = incomingCall.callEndReason else {
            return
        }
        let callEndInfo = CallCompositeIncomingCallEndedInfo(
            code: Int(callEndReason.code),
            subCode: Int(callEndReason.subcode)
        )
        dispose()
        onIncomingCallEnded(callEndInfo)
    }
}
