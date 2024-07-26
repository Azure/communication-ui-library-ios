//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/* Handles detection of Participants added/removed, and returns what to announce */
internal class ParticipantsChangedHook: AccessibilityAnnouncementHookProtocol {
    func shouldAnnounce(oldState: AppState, newState: AppState) -> Bool {
        let callingState = newState.callingState
        if !(callingState.status == .connected
            || callingState.status == .remoteHold
             || (callingState.callType == .oneToNOutgoing
                 && ( callingState.status == .connecting || callingState.status == .ringing))) {
            return false
        }

        let oldParticipants = oldState.remoteParticipantsState.participantInfoList
        let newParticipants = newState.remoteParticipantsState.participantInfoList
        let oldParticipantIDs = Set(oldParticipants.map { $0.userIdentifier })
        let newParticipantIDs = Set(newParticipants.map { $0.userIdentifier })

        return oldParticipantIDs != newParticipantIDs
    }

    func announcement(oldState: AppState,
                      newState: AppState,
                      localizationProvider: LocalizationProviderProtocol) -> String {
        let oldParticipants = oldState.remoteParticipantsState.participantInfoList
        let newParticipants = newState.remoteParticipantsState.participantInfoList

        let oldParticipantIDs = Set(oldParticipants.map { $0.userIdentifier })
        let newParticipantIDs = Set(newParticipants.map { $0.userIdentifier })

        let removedParticipantIDs = oldParticipantIDs.subtracting(newParticipantIDs)
        let addedParticipantIDs = newParticipantIDs.subtracting(oldParticipantIDs)

        let removedParticipants = oldParticipants.filter { removedParticipantIDs.contains($0.userIdentifier) }
        let addedParticipants = newParticipants.filter { addedParticipantIDs.contains($0.userIdentifier) }

        var announcements = [String]()

        if !removedParticipants.isEmpty {
            if removedParticipants.count == 1 {
                let removedParticipant = removedParticipants.first!
                announcements.append(
                    localizationProvider
                        .getLocalizedString(
                            .onePersonLeft,
                            removedParticipant.displayName))
            } else {
                announcements.append(
                    localizationProvider
                        .getLocalizedString(
                            .multiplePeopleLeft,
                            removedParticipants.count))
            }
        }

        if !addedParticipants.isEmpty {
            if addedParticipants.count == 1 {
                let addedParticipant = addedParticipants.first!
                announcements.append(
                    localizationProvider
                        .getLocalizedString(
                            .onePersonJoined,
                            addedParticipant.displayName))
            } else {
                announcements.append(
                    localizationProvider
                        .getLocalizedString(
                            .multiplePeopleJoined,
                            addedParticipants.count))
            }
        }

        return announcements.joined(separator: " ")
    }
}
