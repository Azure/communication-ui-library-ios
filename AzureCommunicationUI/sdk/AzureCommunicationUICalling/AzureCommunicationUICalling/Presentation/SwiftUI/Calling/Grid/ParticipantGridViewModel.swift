//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

class ParticipantGridViewModel: ObservableObject {
    private let compositeViewModelFactory: CompositeViewModelFactoryProtocol
    private let localizationProvider: LocalizationProviderProtocol
    private let accessibilityProvider: AccessibilityProviderProtocol
    private let isIpadInterface: Bool
    private var maximumParticipantsDisplayed: Int {
        return isIpadInterface ? 9 : 6
    }

    private var lastUpdateTimeStamp = Date()
    private(set) var participantsCellViewModelArr: [ParticipantGridCellViewModel] = []

    @Published var gridsCount: Int = 0
    @Published var displayedParticipantInfoModelArr: [ParticipantInfoModel] = []

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         localizationProvider: LocalizationProviderProtocol,
         accessibilityProvider: AccessibilityProviderProtocol,
         isIpadInterface: Bool) {
        self.compositeViewModelFactory = compositeViewModelFactory
        self.localizationProvider = localizationProvider
        self.accessibilityProvider = accessibilityProvider
        self.isIpadInterface = isIpadInterface
    }

    func update(callingState: CallingState,
                remoteParticipantsState: RemoteParticipantsState) {
        guard lastUpdateTimeStamp != remoteParticipantsState.lastUpdateTimeStamp else {
            return
        }
        lastUpdateTimeStamp = remoteParticipantsState.lastUpdateTimeStamp

        let remoteParticipants = remoteParticipantsState.participantInfoList
        let newDisplayedInfoModelArr = getDisplayedInfoViewModels(remoteParticipants)
        let removedModels = getRemovedInfoModels(for: newDisplayedInfoModelArr)
        let addedModels = getAddedInfoModels(for: newDisplayedInfoModelArr)
        let orderedInfoModelArr = sortDisplayedInfoModels(newDisplayedInfoModelArr,
                                                          removedModels: removedModels,
                                                          addedModels: addedModels)
        updateCellViewModel(for: orderedInfoModelArr)

        displayedParticipantInfoModelArr = orderedInfoModelArr
        if callingState.status == .connected {
            // announce participants list changes only if the user is already connected to the call
            postParticipantsListUpdateAccessibilityAnnouncements(removedModels: removedModels,
                                                                 addedModels: addedModels)
        }
        if gridsCount != displayedParticipantInfoModelArr.count {
            gridsCount = displayedParticipantInfoModelArr.count
        }
    }

    private func getDisplayedInfoViewModels(_ infoModels: [ParticipantInfoModel]) -> [ParticipantInfoModel] {
        if let presentingParticipant = infoModels.first(where: { $0.screenShareVideoStreamModel != nil }) {
            return [presentingParticipant]
        }

        if infoModels.count <= maximumParticipantsDisplayed {
            return infoModels
        }

        let sortedInfoList = infoModels.sorted(by: {
            $0.recentSpeakingStamp.compare($1.recentSpeakingStamp) == .orderedDescending
        })
        let newDisplayRemoteParticipant = sortedInfoList.prefix(maximumParticipantsDisplayed)
        // Need to filter if the user is on the lobby or not
        return Array(newDisplayRemoteParticipant)
    }

    private func getRemovedInfoModels(for newInfoModels: [ParticipantInfoModel]) -> [ParticipantInfoModel] {
        return displayedParticipantInfoModelArr.filter { old in
            !newInfoModels.contains(where: { new in
                new.userIdentifier == old.userIdentifier
            })
        }
    }

    private func getAddedInfoModels(for newInfoModels: [ParticipantInfoModel]) -> [ParticipantInfoModel] {
        return newInfoModels.filter { new in
            !displayedParticipantInfoModelArr.contains(where: { old in
                new.userIdentifier == old.userIdentifier
            })
        }
    }

    private func sortDisplayedInfoModels(_ newInfoModels: [ParticipantInfoModel],
                                         removedModels: [ParticipantInfoModel],
                                         addedModels: [ParticipantInfoModel]) -> [ParticipantInfoModel] {
        var localCacheInfoModelArr = displayedParticipantInfoModelArr
        guard removedModels.count == addedModels.count else {
            // when there is a gridType change
            // we just directly update the order based on the latest sorting
            return newInfoModels
        }

        var replacedIndex = [Int]()
        // Otherwise, we keep those existed participant in same position when there is any update
        for (index, item) in removedModels.enumerated() {
            if let removeIndex = localCacheInfoModelArr.firstIndex(where: {
                $0.userIdentifier == item.userIdentifier
            }) {
                localCacheInfoModelArr[removeIndex] = addedModels[index]
                replacedIndex.append(removeIndex)
            }
        }

        // To update existed participantInfoModel
        for (index, item) in localCacheInfoModelArr.enumerated() {
            if !replacedIndex.contains(index),
               let newItem = newInfoModels.first(where: {$0.userIdentifier == item.userIdentifier}) {
                localCacheInfoModelArr[index] = newItem
            }
        }

        return localCacheInfoModelArr
    }

    private func updateCellViewModel(for displayedRemoteParticipants: [ParticipantInfoModel]) {
        if participantsCellViewModelArr.count == displayedRemoteParticipants.count {
            updateOrderedCellViewModels(for: displayedRemoteParticipants)
        } else {
            updateAndReorderCellViewModels(for: displayedRemoteParticipants)
        }
    }

    private func updateOrderedCellViewModels(for displayedRemoteParticipants: [ParticipantInfoModel]) {
        guard participantsCellViewModelArr.count == displayedRemoteParticipants.count else {
            return
        }
        for (index, infoModel) in displayedRemoteParticipants.enumerated() {
            let cellViewModel = participantsCellViewModelArr[index]
            cellViewModel.update(participantModel: infoModel)
        }
    }

    private func updateAndReorderCellViewModels(for displayedRemoteParticipants: [ParticipantInfoModel]) {
        var newCellViewModelArr = [ParticipantGridCellViewModel]()
        for infoModel in displayedRemoteParticipants {
            if let viewModel = participantsCellViewModelArr.first(where: {
                $0.participantIdentifier == infoModel.userIdentifier
            }) {
                viewModel.update(participantModel: infoModel)
                newCellViewModelArr.append(viewModel)
            } else {
                let cellViewModel = compositeViewModelFactory
                    .makeParticipantCellViewModel(participantModel: infoModel)
                newCellViewModelArr.append(cellViewModel)
            }
        }

        participantsCellViewModelArr = newCellViewModelArr
    }

    private func postParticipantsListUpdateAccessibilityAnnouncements(removedModels: [ParticipantInfoModel],
                                                                      addedModels: [ParticipantInfoModel]) {
        if !removedModels.isEmpty {
            if removedModels.count == 1 {
                accessibilityProvider.postQueuedAnnouncement(
                    localizationProvider.getLocalizedString(.onePersonLeft, removedModels.first!.displayName))
            } else {
                accessibilityProvider.postQueuedAnnouncement(
                    localizationProvider.getLocalizedString(.multiplePeopleLeft, removedModels.count))
            }
        }
        if !addedModels.isEmpty {
            if addedModels.count == 1 {
                accessibilityProvider.postQueuedAnnouncement(
                    localizationProvider.getLocalizedString(.onePersonJoined, addedModels.first!.displayName))
            } else {
                accessibilityProvider.postQueuedAnnouncement(
                    localizationProvider.getLocalizedString(.multiplePeopleJoined, addedModels.count))
            }
        }
    }
}
