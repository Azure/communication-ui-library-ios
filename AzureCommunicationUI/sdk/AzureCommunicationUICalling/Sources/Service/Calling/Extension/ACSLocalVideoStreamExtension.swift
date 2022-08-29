//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationCalling

extension LocalVideoStream {

    var asVideoStream: VideoStreamInfoModel? {
        VideoStreamInfoModel(
            videoStreamIdentifier: source.id,
            mediaStreamType: mediaStreamType.converted()
        )
    }
}
