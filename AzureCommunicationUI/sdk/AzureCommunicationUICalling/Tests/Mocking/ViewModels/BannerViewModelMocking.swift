//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import AzureCommunicationUICalling

class BannerViewModelMocking: BannerViewModel {
    private let updateState: ((CallingState, VisibilityState) -> Void)?

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         dispatchAction: @escaping ActionDispatch,
         updateState: ((CallingState, VisibilityState) -> Void)? = nil) {
        self.updateState = updateState
        super.init(compositeViewModelFactory: compositeViewModelFactory, dispatchAction: dispatchAction)
    }

    override func update(callingState: CallingState, visibilityState: VisibilityState) {
        updateState?(callingState, visibilityState)
    }
}
