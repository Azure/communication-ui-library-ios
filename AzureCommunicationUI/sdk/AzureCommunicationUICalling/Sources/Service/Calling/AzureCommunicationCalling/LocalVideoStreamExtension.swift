//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationCalling
import Foundation

extension CompositeLocalVideoStream {
    static func nativeAccMediaStreamType(type: CompositeMediaStreamType)
    -> AzureCommunicationCalling.VideoStreamSourceType {
        switch type {
        case .cameraVideo:
            return AzureCommunicationCalling.VideoStreamSourceType .video
        case .screenSharing:
            return AzureCommunicationCalling.VideoStreamSourceType .screenSharing
        }
    }
}
