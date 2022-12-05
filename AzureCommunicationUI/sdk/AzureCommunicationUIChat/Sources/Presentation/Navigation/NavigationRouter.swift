//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//
import Foundation
import Combine

enum ViewType {
    case chatView
}

class NavigationRouter: ObservableObject {
    private let store: Store<AppState>
    private let logger: Logger
    private var isDismissed: Bool = false
    private let eventsHandler: ChatUIClient.Events
    @Published var currentView: ViewType = .chatView

    var cancellables = Set<AnyCancellable>()
    private var dismissCompositeHostingVC: (() -> Void)?

    init(store: Store<AppState>,
         logger: Logger,
         chatCompositeEventsHandler: ChatUIClient.Events) {
        self.store = store
        self.logger = logger
        self.eventsHandler = chatCompositeEventsHandler

        store.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.receive(state)
            }.store(in: &cancellables)
    }

    func receive(_ state: AppState) {
        var viewToNavigateTo: ViewType?

        switch state.navigationState.status {
        case .inChat:
            viewToNavigateTo = .chatView
            isDismissed = false
        case .headless:
            dismiss()
        case .exit:
            dismiss()
        }

        if let view = viewToNavigateTo,
           view != currentView {
            logger.debug("Navigating to: \(view)" )
            currentView = view
        }
    }

    func dismiss() {
        guard !self.isDismissed else {
            return
        }
        dismissCompositeHostingVC?()
        isDismissed = true
    }
}
