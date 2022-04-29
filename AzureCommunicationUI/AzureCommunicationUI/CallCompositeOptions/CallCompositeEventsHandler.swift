//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//
import Foundation
import UIKit
import AzureCommunicationCalling

protocol CallCompositeEventsHandling: AnyObject {
    var didFail: CompositeErrorHandler? { get set }
    var didRemoteParticipantsJoin: RemoteParticipantsJoinedHandler? { get set }
}

class CallCompositeEventsHandler: CallCompositeEventsHandling {
    var didFail: CompositeErrorHandler?
    var didRemoteParticipantsJoin: RemoteParticipantsJoinedHandler?
}
