//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class UITestSettingsOverlayViewModel: OverlayViewModelProtocol, ObservableObject {

    @Published var isDisplayed: Bool = true
    var participantInfoViewModels: [ParticipantInfoModel] = []

    var title: String {
        return "UITest Settings Page"
    }
    var action: ((Action) -> Void)

    init(store: Store<AppState>,
         action: @escaping (Action) -> Void) {
        self.action = action
    }

    func toggleDisplayrIfNeeded() {
        self.isDisplayed ? hide() : show()
    }

    private func hide() {
        self.isDisplayed = false
    }

    private func show() {
        self.isDisplayed = true
    }

    func addParticipant() {
        let count = participantInfoViewModels.count
        let newParticipant = ParticipantInfoModel(displayName: "New User \(count + 1)",
                                                  isSpeaking: false,
                                                  isMuted: true,
                                                  isRemoteUser: true,
                                                   userIdentifier: "userIdentifier\(count + 1)",
                                                  status: .connected,
                                                  recentSpeakingStamp: Date(),
                                                  screenShareVideoStreamModel: nil,
                                                  cameraVideoStreamModel: nil)
        participantInfoViewModels.append(newParticipant)
    }

    func addParticipants(number: Int) {
        let count = participantInfoViewModels.count
        for i in 1...number {
            let newParticipant = ParticipantInfoModel(displayName: "New User \(count + i)",
                                                      isSpeaking: false,
                                                      isMuted: true,
                                                      isRemoteUser: true,
                                                       userIdentifier: "userIdentifier\(count + i)",
                                                      status: .connected,
                                                      recentSpeakingStamp: Date(),
                                                      screenShareVideoStreamModel: nil,
                                                      cameraVideoStreamModel: nil)
            participantInfoViewModels.append(newParticipant)
        }
    }

    func removeLastPartiicpant() {
        guard !participantInfoViewModels.isEmpty else {
            return
        }

        participantInfoViewModels.removeLast()
    }

    func removeAllRemoteParticipants() {
        participantInfoViewModels.removeAll()
    }

    func updateParticipantSpeakStatus(isSpeaking: Bool) {
        guard !participantInfoViewModels.isEmpty else {
            return
        }
        if let first = participantInfoViewModels.first {
            let newParticipant = ParticipantInfoModel(displayName: first.displayName,
                                                      isSpeaking: isSpeaking,
                                                      isMuted: !isSpeaking,
                                                      isRemoteUser: first.isRemoteUser,
                                                      userIdentifier: first.userIdentifier,
                                                      status: first.status,
                                                      recentSpeakingStamp: Date(),
                                                      screenShareVideoStreamModel: first.screenShareVideoStreamModel,
                                                      cameraVideoStreamModel: first.cameraVideoStreamModel)
            participantInfoViewModels.removeFirst()
            participantInfoViewModels.insert(newParticipant, at: 0)
        }
    }

    func updateParticipantHoldStatus(isHold: Bool) {
        guard !participantInfoViewModels.isEmpty else {
            return
        }
        if let first = participantInfoViewModels.first {
            let newParticipant = ParticipantInfoModel(displayName: first.displayName,
                                                      isSpeaking: first.isSpeaking,
                                                      isMuted: first.isMuted,
                                                      isRemoteUser: first.isRemoteUser,
                                                      userIdentifier: first.userIdentifier,
                                                      status: isHold ? .hold : .connected,
                                                      recentSpeakingStamp: first.recentSpeakingStamp,
                                                      screenShareVideoStreamModel: first.screenShareVideoStreamModel,
                                                      cameraVideoStreamModel: first.cameraVideoStreamModel)
            participantInfoViewModels.removeFirst()
            participantInfoViewModels.insert(newParticipant, at: 0)
        }
    }
}
