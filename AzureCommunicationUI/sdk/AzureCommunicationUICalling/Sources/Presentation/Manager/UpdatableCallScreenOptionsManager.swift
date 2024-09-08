/* <TIMER_TITLE_FEATURE> */
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

class UpdatableCallScreenOptionsManager {
    private let store: Store<AppState, Action>
    private var subscriptions = Set<AnyCancellable>()
    init(store: Store<AppState, Action>, callScreenHeaderViewData: CallScreenHeaderViewData?) {
        self.store = store

        callScreenHeaderViewData?.$title
            .sink { [weak self] newTitle in
                self?.store.dispatch(action: .callScreenInfoHeaderAction(.updateTitle(title: newTitle)))
            }
            .store(in: &subscriptions)

        callScreenHeaderViewData?.$subtitle
            .sink { [weak self] newSubtitle in
                self?.store.dispatch(action: .callScreenInfoHeaderAction(.updateSubtitle(subtitle: newSubtitle)))
            }
            .store(in: &subscriptions)
    }
}
/* </TIMER_TITLE_FEATURE> */
