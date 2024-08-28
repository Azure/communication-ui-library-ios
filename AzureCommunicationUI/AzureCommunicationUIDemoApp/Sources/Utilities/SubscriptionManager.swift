//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine
#if DEBUG
@testable import AzureCommunicationUICalling
#else
import AzureCommunicationUICalling
#endif
class SubscriptionManager {
    private var cancellables = Set<AnyCancellable>()
    func bind(firstViewModel: CallDurationManager, secondViewModel: CallScreenHeaderOptions) {
        firstViewModel.$timerTickStateFlow
            .sink { newValue in
                secondViewModel.subtitle = newValue
            }
            .store(in: &cancellables)
    }
}
