//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//
import Foundation
import UIKit
import AzureCommunicationCalling

protocol CallCompositeEventsHandling: AnyObject {
    var onError: ((CallCompositeErrorEvent) -> Void)? { get set }
    var onRemoteParticipantJoined: (([CommunicationIdentifier]) -> Void)? { get set }
}

class CallCompositeEventsHandler: CallCompositeEventsHandling {
    var onError: ((CallCompositeErrorEvent) -> Void)?
    var onRemoteParticipantJoined: (([CommunicationIdentifier]) -> Void)?
}
