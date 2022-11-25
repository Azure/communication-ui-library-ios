//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@_spi(CallCompositeUITest) import AzureCommunicationUICalling

class CallingSDKEventsHandlerMocking: CallingSDKEventsHandler {
    override init(logger: Logger) {
        super.init(logger: logger)
    }
    func joinCall() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.callInfoSubject.send(CallInfoModel(status: .connected,
                                                     internalError: nil))
        }
    }

    func joinLobby() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.callInfoSubject.send(CallInfoModel(status: .inLobby,
                                                     internalError: nil))
        }
    }

    func endCall() {
        DispatchQueue.main.async { [weak self] in
            self?.callInfoSubject.send(CallInfoModel(status: .disconnected,
                                               internalError: nil))
        }
    }

    func holdCall() {
        DispatchQueue.main.async { [weak self] in
            self?.callInfoSubject.send(CallInfoModel(status: .localHold,
                                               internalError: nil))
        }
    }

    func resumeCall() {
        DispatchQueue.main.async { [weak self] in
            self?.callInfoSubject.send(CallInfoModel(status: .connected,
                                               internalError: nil))
        }
    }

    func muteLocalMic() {
        DispatchQueue.main.async { [weak self] in
            self?.isLocalUserMutedSubject.send(true)
        }
    }

    func unmuteLocalMic() {
        DispatchQueue.main.async { [weak self] in
            self?.isLocalUserMutedSubject.send(false)
        }
    }
}
