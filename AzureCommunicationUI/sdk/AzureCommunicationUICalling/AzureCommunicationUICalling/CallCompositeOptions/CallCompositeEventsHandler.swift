//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//
import Foundation
import UIKit
import AzureCommunicationCalling

protocol CallCompositeEventsHandling: AnyObject {
    var didFail: ((CallCompositeErrorEvent) -> Void)? { get set }
    var didRemoteParticipantsJoin: (([CommunicationIdentifier]) -> Void)? { get set }
}

class CallCompositeEventsHandler: CallCompositeEventsHandling {
    var didFail: ((CallCompositeErrorEvent) -> Void)?
    var didRemoteParticipantsJoin: (([CommunicationIdentifier]) -> Void)?
}
