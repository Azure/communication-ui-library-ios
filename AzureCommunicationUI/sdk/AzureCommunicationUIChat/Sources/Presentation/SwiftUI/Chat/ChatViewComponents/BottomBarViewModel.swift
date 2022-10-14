//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class BottomBarViewModel: ObservableObject {
    private let logger: Logger
    private let dispatch: ActionDispatch

    var sendButtonViewModel: IconButtonViewModel!

    init(compositeViewModelFactory: CompositeViewModelFactory,
         logger: Logger,
         dispatch: @escaping ActionDispatch) {
        self.logger = logger
        self.dispatch = dispatch

        sendButtonViewModel = compositeViewModelFactory.makeIconButtonViewModel(
            iconName: .send,
            buttonType: .sendButton,
            isDisabled: false) { [weak self] in
                guard let self = self else {
                    return
                }
                self.sendMessage()
        }
//        sendButtonViewModel.update(
//            accessibilityLabel: self.localizationProvider.getLocalizedString(.sendAccessibilityLabel))
    }

    @Published var message: String = ""
    @Published var hasFocus: Bool = true

    func sendMessage() {
        hasFocus = true
        guard !message.isEmpty else {
            return
        }
//        dispatch(.chatAction(.))
        message = ""
    }
}
