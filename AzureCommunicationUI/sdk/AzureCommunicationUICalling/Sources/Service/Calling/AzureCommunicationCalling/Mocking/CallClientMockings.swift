//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationCalling
import Combine

class CallClientOptionsMocking: CallClientOptions {}
class CallDiagnosticsOptionsMocking: CallDiagnosticsOptions {}

class CallClientMocking: CallClient {
    func createCallAgentMocking() async throws -> CallAgentMocking? {
        return try await Task<CallAgentMocking, Error> {
            return CallAgentMocking()
        }.value
    }

    func getDeviceManagerMocking() -> DeviceManagerMocking {
        return DeviceManagerMocking()
    }
}

class CallAgentMocking {
    func join() -> CallMocking? {
        return CallMocking()
    }
}

class CallMocking {
    weak var delegate: CallDelegate?
}

class JoinCallOptionsMocking: JoinCallOptions {
    public init(isAudioPreferred: Bool) {
        super.init()
        self.audioOptions = AudioOptionsMocking()
        audioOptions?.muted = isAudioPreferred
    }
}

class VideoDeviceInfoMocking {
    var name: String = "someDevice"
    var id: String = ""
    var cameraFacing: CameraFacing?
    var deviceType: VideoDeviceType?

    init(name: String = "",
         id: String = "",
         cameraFacing: CameraFacing,
         deviceType: VideoDeviceType? = nil) {
        self.name = name
        self.id = id
        self.cameraFacing = cameraFacing
        self.deviceType = deviceType
    }
}

class AudioOptionsMocking: AudioOptions {}
class VideoOptionsMocking: VideoOptions {}
class LocalVideoStreamMocking {}
