//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

@_spi(CallCompositeUITest) public struct CallInfoModel {
    let status: CallingStatus
    let internalError: CallCompositeInternalError?

    public init(status: CallingStatus, internalError: CallCompositeInternalError?) {
        self.status = status
        self.internalError = internalError
    }
}
