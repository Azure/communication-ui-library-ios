//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

class ChatViewModel: ObservableObject {
    private let compositeViewModelFactory: CompositeViewModelFactoryProtocol
    private let logger: Logger

    private var cancellables = Set<AnyCancellable>()

    var participantsLastUpdatedTimestamp = Date()

    @Published var participants: [ParticipantInfoModel] = []

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         logger: Logger) {
        self.compositeViewModelFactory = compositeViewModelFactory
        self.logger = logger
    }
}
