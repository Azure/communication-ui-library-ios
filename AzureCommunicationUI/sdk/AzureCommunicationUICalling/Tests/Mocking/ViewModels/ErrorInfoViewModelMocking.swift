//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import AzureCommunicationUICalling
@_spi(CallCompositeUITest) import AzureCommunicationUICalling

class ErrorInfoViewModelMocking: ErrorInfoViewModel {
    private let updateState: ((ErrorState) -> Void)?

    init(updateState: ((ErrorState) -> Void)? = nil) {
        self.updateState = updateState
        super.init(localizationProvider: LocalizationProviderMocking())
    }

    override func update(errorState: ErrorState) {
        updateState?(errorState)
    }
}
