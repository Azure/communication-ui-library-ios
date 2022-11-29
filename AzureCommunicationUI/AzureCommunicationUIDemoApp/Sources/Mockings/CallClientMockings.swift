//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationCalling
import Combine

class CallClientOptionsMocking {
    var diagnostics: CallDiagnosticsOptionsMocking?
}
class CallDiagnosticsOptionsMocking {
    var appName: String = ""
    var appVersion: String = ""
    var tags: [String] = []
}

class CallClientMocking {
    var options: CallClientOptionsMocking?

    init(options: CallClientOptionsMocking) {
        self.options = options
    }

    func createCallAgentMocking() async throws -> CallAgentMocking? {
        return try await Task<CallAgentMocking, Error> {
            return CallAgentMocking()
        }.value
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

class JoinCallOptionsMocking {
    var audioOptions: AudioOptionsMocking?
    public init(isAudioPreferred: Bool) {
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

class AudioOptionsMocking {
    var muted: Bool = false
}
