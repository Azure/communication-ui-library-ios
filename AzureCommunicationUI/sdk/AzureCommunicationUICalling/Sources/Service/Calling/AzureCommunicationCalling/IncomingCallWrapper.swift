//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationCalling

internal class IncomingCallWrapper: CallsUpdatedProtocol {
    private let logger: Logger
    private let events: CallComposite.Events

    init(logger: Logger,
         events: CallComposite.Events) {
        self.logger = logger
        self.events = events
    }

    func onIncomingCall(incomingCall: IncomingCall) {
    }

    func onCallsUpdated() {
    }

    public func answer() {
    }

    public func reject() {
    }

    public func handlePushNotification() {
    }
}
