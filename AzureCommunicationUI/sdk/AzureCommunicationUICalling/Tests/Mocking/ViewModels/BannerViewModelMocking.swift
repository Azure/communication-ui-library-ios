//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import AzureCommunicationUICalling

class BannerViewModelMocking: BannerViewModel {
    private let updateState: ((CallingState) -> Void)?

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         updateState: ((CallingState) -> Void)? = nil) {
        self.updateState = updateState
        super.init(compositeViewModelFactory: compositeViewModelFactory)
    }

    override func update(callingState: CallingState) {
        updateState?(callingState)
    }
}
