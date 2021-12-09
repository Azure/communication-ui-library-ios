//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

class ParticipantCellViewModel: ObservableObject, Identifiable {
    let id = UUID()

    @Published var videoStreamId: String?
    @Published var displayName: String?
    @Published var isSpeaking: Bool
    var participantIdentifier: String

    init(compositeViewModelFactory: CompositeViewModelFactory,
         participantModel: ParticipantInfoModel) {
        self.videoStreamId = participantModel.getDisplayingVideoStreamId()
        self.displayName = participantModel.displayName
        self.isSpeaking = participantModel.isSpeaking
        self.participantIdentifier = participantModel.userIdentifier
    }

    func update(participantModel: ParticipantInfoModel) {
        self.participantIdentifier = participantModel.userIdentifier
        let videoIdentifier = participantModel.getDisplayingVideoStreamId()

        if self.videoStreamId != videoIdentifier {
            self.videoStreamId = videoIdentifier
        }

        if self.displayName != participantModel.displayName {
            self.displayName = participantModel.displayName
        }

        if self.isSpeaking != participantModel.isSpeaking {
            self.isSpeaking = participantModel.isSpeaking
        }

    }
}
