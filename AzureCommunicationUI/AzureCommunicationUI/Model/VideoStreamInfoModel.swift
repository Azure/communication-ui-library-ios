//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

struct VideoStreamInfoModel: Hashable, Equatable {
    enum MediaStreamType {
        case cameraVideo
        case screenSharing
    }
    let videoStreamIdentifier: String
    let mediaStreamType: MediaStreamType
}
