//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import AzureCommunicationUI

class ErrorInfoViewModelMocking: ErrorInfoViewModel {
    private let updateState: ((ErrorState) -> Void)?

    init(updateState: ((ErrorState) -> Void)? = nil) {
        self.updateState = updateState
        super.init(with: LocalizationProviderMocking())
    }

    override func update(errorState: ErrorState) {
        updateState?(errorState)
    }
}
