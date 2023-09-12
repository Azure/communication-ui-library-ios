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
        return  self.visibilityStatus == .pipModeEntered ? 1 : isIpadInterface ? 9 : 6
    }

    private var lastUpdateTimeStamp = Date()
    private var lastDominantSpeakersUpdatedTimestamp = Date()
    private var visibilityStatus: VisibilityStatus = .visible
    private var appStatus: AppStatus = .foreground
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
                remoteParticipantsState: RemoteParticipantsState,
                visibilityState: VisibilityState,
                lifeCycleState: LifeCycleState) {

        if visibilityState.currentStatus == .pipModeRequested {
            // When enterin system PiP, need to remove video from rendering,
            // so it will be rendered properly after view is placed in PiP
            updateCellViewModel(for: [], lifeCycleState: lifeCycleState)
            return
        }

        guard lastUpdateTimeStamp != remoteParticipantsState.lastUpdateTimeStamp
                || lastDominantSpeakersUpdatedTimestamp != remoteParticipantsState.dominantSpeakersModifiedTimestamp
                || visibilityStatus != visibilityState.currentStatus
                || appStatus != lifeCycleState.currentStatus
        else {
            return
        }
        lastUpdateTimeStamp = remoteParticipantsState.lastUpdateTimeStamp
        lastDominantSpeakersUpdatedTimestamp = remoteParticipantsState.dominantSpeakersModifiedTimestamp
        visibilityStatus = visibilityState.currentStatus
        appStatus = lifeCycleState.currentStatus

        let remoteParticipants = remoteParticipantsState.participantInfoList
            .filter { participanInfoModel in
                participanInfoModel.status != .inLobby
            }
        let dominantSpeakers = remoteParticipantsState.dominantSpeakers
        var newDisplayedInfoModelArr = getDisplayedInfoViewModels(remoteParticipants, dominantSpeakers, visibilityState)
        let removedModels = getRemovedInfoModels(for: newDisplayedInfoModelArr)
        let addedModels = getAddedInfoModels(for: newDisplayedInfoModelArr)
        let orderedInfoModelArr = sortDisplayedInfoModels(newDisplayedInfoModelArr,
                                                          removedModels: removedModels,
                                                          addedModels: addedModels)
        updateCellViewModel(for: orderedInfoModelArr, lifeCycleState: lifeCycleState)

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

    private func getDisplayedInfoViewModels(_ infoModels: [ParticipantInfoModel],
                                            _ dominantSpeakers: [String],
                                            _ pipState: VisibilityState) -> [ParticipantInfoModel] {
        if let presentingParticipant = infoModels.first(where: { $0.screenShareVideoStreamModel != nil }) {
            return [presentingParticipant]
        }

        if infoModels.count <= maximumParticipantsDisplayed {
            return infoModels
        }
        var dominantSpeakersOrder = [String: Int]()
        for i in 0..<min(maximumParticipantsDisplayed, dominantSpeakers.count) {
            dominantSpeakersOrder[dominantSpeakers[i]] = i
        }
        let sortedInfoList = infoModels.sorted(by: {
            if let order1 = dominantSpeakersOrder[$0.userIdentifier],
                let order2 = dominantSpeakersOrder[$1.userIdentifier] {
                return order1 < order2
            }
            if dominantSpeakersOrder[$0.userIdentifier] != nil {
                return true
            }
            if dominantSpeakersOrder[$1.userIdentifier] != nil {
                return false
            }
            if ($0.cameraVideoStreamModel != nil && $1.cameraVideoStreamModel != nil)
                || ($0.cameraVideoStreamModel == nil && $1.cameraVideoStreamModel == nil) {
                return true
            }
            if $0.cameraVideoStreamModel != nil {
                return true
            } else {
                return false
            }
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

    private func updateCellViewModel(for displayedRemoteParticipants: [ParticipantInfoModel],
                                     lifeCycleState: LifeCycleState) {
        if participantsCellViewModelArr.count == displayedRemoteParticipants.count {
            updateOrderedCellViewModels(for: displayedRemoteParticipants, lifeCycleState: lifeCycleState)
        } else {
            updateAndReorderCellViewModels(for: displayedRemoteParticipants, lifeCycleState: lifeCycleState)
        }
    }

    private func updateOrderedCellViewModels(for displayedRemoteParticipants: [ParticipantInfoModel],
                                             lifeCycleState: LifeCycleState) {
        guard participantsCellViewModelArr.count == displayedRemoteParticipants.count else {
            return
        }
        for (index, infoModel) in displayedRemoteParticipants.enumerated() {
            let cellViewModel = participantsCellViewModelArr[index]
            cellViewModel.update(participantModel: infoModel, lifeCycleState: lifeCycleState)
        }
    }

    private func updateAndReorderCellViewModels(for displayedRemoteParticipants: [ParticipantInfoModel],
                                                lifeCycleState: LifeCycleState) {
        var newCellViewModelArr = [ParticipantGridCellViewModel]()
        for infoModel in displayedRemoteParticipants {
            if let viewModel = participantsCellViewModelArr.first(where: {
                $0.participantIdentifier == infoModel.userIdentifier
            }) {
                viewModel.update(participantModel: infoModel, lifeCycleState: lifeCycleState)
                newCellViewModelArr.append(viewModel)
            } else {
                let cellViewModel = compositeViewModelFactory
                    .makeParticipantCellViewModel(participantModel: infoModel, lifeCycleState: lifeCycleState)
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
