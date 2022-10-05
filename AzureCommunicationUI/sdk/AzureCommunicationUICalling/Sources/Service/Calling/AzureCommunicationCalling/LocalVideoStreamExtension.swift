//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationCalling
import Foundation

extension CompositeLocalVideoStream {
    static func nativeAccMediaStreamType(type: CompositeMediaStreamType)
    -> AzureCommunicationCalling.MediaStreamType {
        switch type {
        case .cameraVideo:
            return AzureCommunicationCalling.MediaStreamType.video
        case .screenSharing:
            return AzureCommunicationCalling.MediaStreamType.screenSharing
        }
    }
}
