//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCore
import Foundation
import AzureCommunicationCommon

extension Reducer where State == ParticipantsState,
                        Actions == Action {
    static var liveParticipantsReducer: Self = Reducer { participantsState, action in
        // MARK: Chat Participant
        var currentParticipants = participantsState.participants
        var participantsUpdatedTimestamp = participantsState.participantsUpdatedTimestamp
        let currentTimestamp = Date()

        // MARK: Typing Indicator
        var typingParticipants = participantsState.typingParticipants

        print("[test] reducer called")
        switch action {
        case .participantsAction(.participantsAdded(let participants)):
            var currentParticipants = participantsState.participants
            for participant in participants {
                currentParticipants[participant.id] = participant
            }
            let state = ParticipantsState(participants: currentParticipants)
            return state
        case .participantsAction(.participantsRemoved(let participants)):
            for participant in participants {
                guard currentParticipants[participant.id] != nil else {
                    continue
                }
                typingParticipants = typingParticipants.filter { $0.id != participant.id }
                currentParticipants.removeValue(forKey: participant.id)
            }
            participantsUpdatedTimestamp = currentTimestamp
            let state = ParticipantsState(participants: currentParticipants,
                                          participantsUpdatedTimestamp: participantsUpdatedTimestamp)
            return state
        case .participantsAction(.typingIndicatorReceived(let participant)):
            print("[test] \(participant.id) added")
            typingParticipants = typingParticipants.filter { $0.id != participant.id }
            typingParticipants.append(participant)
            currentParticipants = [
                "8:acs:b6aada1f-0b1d-47ac-866f-91aae00a1d01_00000014-c657-4e9f-c5a7-923a0d009572":
                    ParticipantInfoModel(identifier: CommunicationUserIdentifier(
                        "8:acs:b6aada1f-0b1d-47ac-866f-91aae00a1d01_00000014-c657-4e9f-c5a7-923a0d009572"),
                                            displayName: "Chris Lee"),
                "8:acs:b6aada1f-0b1d-47ac-866f-91aae00a1d01_00000014-c645-3b8d-5aad-923a0d009901":
                    ParticipantInfoModel(identifier: CommunicationUserIdentifier(
                        "8:acs:b6aada1f-0b1d-47ac-866f-91aae00a1d01_00000014-c645-3b8d-5aad-923a0d009901"),
                                            displayName: "Alex Choi"),
                "8:acs:b6aada1f-0b1d-47ac-866f-91aae00a1d01_00000014-c645-8a65-5aad-923a0d009903":
                    ParticipantInfoModel(identifier: CommunicationUserIdentifier(
                        "8:acs:b6aada1f-0b1d-47ac-866f-91aae00a1d01_00000014-c645-8a65-5aad-923a0d009903"),
                                        displayName: "John Smith")
            ]
        case .participantsAction(.removeTypingParticipants(let participants)):
            for p in participants {
                print("[test] \(p.id) removed.")
                typingParticipants = typingParticipants.filter { $0 != p }
            }
        case .participantsAction(.setTypingIndicator(let participant)):
            print("[test] participants updated to \(participant.count)")
            typingParticipants = participant
        case .repositoryAction(.chatMessageReceived(let message)):
            guard let participantId = message.senderId else {
                break
            }
            switch message.type {
            case .custom(_), .html, .text:
                typingParticipants = typingParticipants.filter { $0.id != participantId }
            default:
                break
            }
        default:
            return participantsState
        }

        return ParticipantsState(participants: currentParticipants,
                                 participantsUpdatedTimestamp: participantsUpdatedTimestamp,
                                 typingParticipants: typingParticipants)
    }
}
