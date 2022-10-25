//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class CallingSDKEventsHandlerMocking: CallingSDKEventsHandler {
    func joinCall() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.callInfoSubject.send(CallInfoModel(status: .connected,
                                                                          internalError: nil))
        }
    }

    func endCall() {
        DispatchQueue.main.async { [weak self] in
            self?.callInfoSubject.send(CallInfoModel(status: .disconnected,
                                               internalError: nil))
        }
    }
}
