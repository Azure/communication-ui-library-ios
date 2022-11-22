//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class UITestSettingsOverlayViewModel: OverlayViewModelProtocol, ObservableObject {

    @Published var isDisplayed: Bool = true
    var participantInfoViewModel: [ParticipantInfoModel] = []

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
        let count = participantInfoViewModel.count
        let newParticipant = ParticipantInfoModel(displayName: "New User \(count + 1)",
                                                  isSpeaking: false,
                                                  isMuted: true,
                                                  isRemoteUser: true,
                                                   userIdentifier: "userIdentifier\(count + 1)",
                                                  status: .connected,
                                                  recentSpeakingStamp: Date(),
                                                  screenShareVideoStreamModel: nil,
                                                  cameraVideoStreamModel: nil)
        participantInfoViewModel.append(newParticipant)
    }

    func addParticipants(number: Int) {
        let count = participantInfoViewModel.count
        for i in 0...number {
            let newParticipant = ParticipantInfoModel(displayName: "New User \(count + i)",
                                                      isSpeaking: false,
                                                      isMuted: true,
                                                      isRemoteUser: true,
                                                       userIdentifier: "userIdentifier\(count + i)",
                                                      status: .connected,
                                                      recentSpeakingStamp: Date(),
                                                      screenShareVideoStreamModel: nil,
                                                      cameraVideoStreamModel: nil)
            participantInfoViewModel.append(newParticipant)
        }
    }

    func removeLastPartiicpant() {
        guard !participantInfoViewModel.isEmpty else {
            return
        }

        participantInfoViewModel.removeLast()
    }

    func removeAllRemoteParticipants() {
        participantInfoViewModel.removeAll()
    }
}
