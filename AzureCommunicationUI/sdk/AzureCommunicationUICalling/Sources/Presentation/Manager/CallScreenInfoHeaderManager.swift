//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

class CallScreenInfoHeaderManager {
    private let store: Store<AppState, Action>
    private let callScreenHeaderOptions: CallScreenHeaderOptions?
    private var subscriptions = Set<AnyCancellable>()
    init(store: Store<AppState, Action>, callScreenHeaderOptions: CallScreenHeaderOptions?) {
        self.store = store
        self.callScreenHeaderOptions = callScreenHeaderOptions
        callScreenHeaderOptions?.$title
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newTitle in
                self?.updateTitle(title: newTitle!)
            }
            .store(in: &subscriptions)

        callScreenHeaderOptions?.$subtitle
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newSubtitle in
                self?.updateSubtitle(subtitle: newSubtitle!)
            }
            .store(in: &subscriptions)
    }

    func updateTitle(title: String) {
        store.dispatch(action: .callScreenInfoHeaderAction(.updateTitle(title: title)))
    }

    func updateSubtitle(subtitle: String) {
        store.dispatch(action: .callScreenInfoHeaderAction(.updateSubtitle(subtitle: subtitle)))
    }
}
