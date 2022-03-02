//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

class ParticipantGridViewModel: ObservableObject {
    private let maximumParticipantsDisplayed: Int = 6
    private var lastUpdateTimeStamp = Date()
    private let compositeViewModelFactory: CompositeViewModelFactory
    private(set) var participantsCellViewModelArr: [ParticipantGridCellViewModel] = []

    @Published var gridsCount: Int = 0
    @Published var displayedParticipantInfoModelArr: [ParticipantInfoModel] = []
    @Published var isAppInForeground: Bool = true

    init(compositeViewModelFactory: CompositeViewModelFactory) {
        self.compositeViewModelFactory = compositeViewModelFactory
    }

    func update(remoteParticipantsState: RemoteParticipantsState, lifeCycleState: LifeCycleState) {
        guard lastUpdateTimeStamp != remoteParticipantsState.lastUpdateTimeStamp else {
            if isAppInForeground != (lifeCycleState.currentStatus == .foreground) {
                isAppInForeground = lifeCycleState.currentStatus == .foreground
            }
            return
        }
        lastUpdateTimeStamp = remoteParticipantsState.lastUpdateTimeStamp

        let remoteParticipants = remoteParticipantsState.participantInfoList
        let newDisplayedInfoModelArr = getDisplayedInfoViewModels(remoteParticipants)
        let orderedInfoModelArr = sortDisplayedInfoModels(newDisplayedInfoModelArr)
        updateCellViewModel(for: orderedInfoModelArr)

        displayedParticipantInfoModelArr = orderedInfoModelArr

        if gridsCount != displayedParticipantInfoModelArr.count {
            gridsCount = displayedParticipantInfoModelArr.count
        }

        isAppInForeground = lifeCycleState.currentStatus == .foreground
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

    private func sortDisplayedInfoModels(_ newInfoModels: [ParticipantInfoModel]) -> [ParticipantInfoModel] {
        var localCacheInfoModelArr = displayedParticipantInfoModelArr
        let infoModelToRemove = localCacheInfoModelArr.filter { old in
            !newInfoModels.contains(where: { new in
                new.userIdentifier == old.userIdentifier
            })
        }
        let infoModelToAdd = newInfoModels.filter { new in
            !localCacheInfoModelArr.contains(where: { old in
                new.userIdentifier == old.userIdentifier
            })
        }

        guard infoModelToRemove.count == infoModelToAdd.count else {
            // when there is a gridType change
            // we just directly update the order based on the latest sorting
            return newInfoModels
        }

        var replacedIndex = [Int]()
        // Otherwise, we keep those existed participant in same position when there is any update
        for (index, item) in infoModelToRemove.enumerated() {
            if let removeIndex = localCacheInfoModelArr.firstIndex(where: {
                $0.userIdentifier == item.userIdentifier
            }) {
                localCacheInfoModelArr[removeIndex] = infoModelToAdd[index]
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

}
