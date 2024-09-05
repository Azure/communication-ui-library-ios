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
                if newTitle != nil {
                    self?.titleDidUpdate(title: newTitle!)
                }
            }
            .store(in: &subscriptions)

        callScreenHeaderViewData?.$subtitle
            .sink { [weak self] newSubtitle in
                if newSubtitle != nil {
                    self?.subtitleDidUpdate(subtitle: newSubtitle!)
                }
            }
            .store(in: &subscriptions)

    }

    func titleDidUpdate(title: String) {
        store.dispatch(action: .callScreenInfoHeaderAction(.updateTitle(title: title)))
    }

    func subtitleDidUpdate(subtitle: String) {
        store.dispatch(action: .callScreenInfoHeaderAction(.updateSubtitle(subtitle: subtitle)))
    }
}
/* </TIMER_TITLE_FEATURE> */
