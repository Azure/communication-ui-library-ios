//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

/// The main class representing the entry point for the Call Composite.
public extension CallComposite {
    func getCallingSDKWrapper() -> CallingSDKWrapper? {
        let callingSDKWrapperProtocol = self.dependencyContainer.resolve() as CallingSDKWrapperProtocol
        return callingSDKWrapperProtocol as? CallingSDKWrapper
    }
}
