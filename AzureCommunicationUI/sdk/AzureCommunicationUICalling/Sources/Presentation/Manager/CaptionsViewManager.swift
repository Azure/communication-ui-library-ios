//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit

class CaptionsViewManager: NSObject, ObservableObject, UITableViewDelegate, UITableViewDataSource {

    private var captionData = [CallCompositeCaptionsData]()
    private let avatarViewManager: AvatarViewManagerProtocol
    private weak var tableView: UITableView?
    private let callingSDKWrapper: CallingSDKWrapperProtocol
    private var lastCaptionFinalized = true
    private let subscription = CancelBag()

    init(avatarViewManager: AvatarViewManagerProtocol, callingSDKWrapper: CallingSDKWrapperProtocol) {
        self.avatarViewManager = avatarViewManager
        self.callingSDKWrapper = callingSDKWrapper
    }

    func startReceivingCaptionUpdates(tableView: UITableView) {
        self.tableView = tableView
        callingSDKWrapper.callingEventsHandler.captionsReceived.sink { [weak self] newData in
            DispatchQueue.main.async {
                guard let self = self else {
                    return
                }
                if !self.lastCaptionFinalized && self.captionData.last?.speakerRawId == newData.speakerRawId {
                    self.updatePartialCaptionData(newCaption: newData)
                } else {
                    self.addCaptionData(newCaption: newData)
                }
                self.lastCaptionFinalized = newData.resultType == .final
            }
        }
        .store(in: subscription)
    }

    func stopReceivingCaptionUpdates() {
        subscription.cancel()
    }

    func updatePartialCaptionData(newCaption: CallCompositeCaptionsData) {
        guard let tableView = tableView else {
            return
        }

        let tableViewAtBottom = tableView.contentOffset.y >=
            (tableView.contentSize.height - tableView.frame.size.height)

        tableView.performBatchUpdates {
            captionData.removeLast()
            captionData.append(newCaption)
            let insertIndexPath = IndexPath(row: captionData.count - 1, section: 0)
            tableView.reloadRows(at: [insertIndexPath], with: .fade)
        }

        if tableViewAtBottom {
            scrollToBottom(tableView: tableView)
        }
    }

    func addCaptionData(newCaption: CallCompositeCaptionsData) {
        guard let tableView = tableView else {
            return
        }

        let tableViewAtBottom = tableView.contentOffset.y >=
            (tableView.contentSize.height - tableView.frame.size.height)

        tableView.performBatchUpdates {
            captionData.append(newCaption)
            let insertIndexPath = IndexPath(row: captionData.count - 1, section: 0)
            tableView.insertRows(at: [insertIndexPath], with: .top)
        }

        tableView.performBatchUpdates {
            while self.captionData.count > 50 {
                self.captionData.removeFirst()
                let deleteIndexPath = IndexPath(row: 0, section: 0)
                tableView.deleteRows(at: [deleteIndexPath], with: .top)
            }
        }

        if tableViewAtBottom {
            scrollToBottom(tableView: tableView)
        }
    }

    private func scrollToBottom(tableView: UITableView) {
        let lastRowIndex = tableView.numberOfRows(inSection: 0) - 1
        if lastRowIndex > 0 {
            let lastIndexPath = IndexPath(row: lastRowIndex, section: 0)
            tableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: true)
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return captionData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: CaptionsInfoCell.identifier,
            for: indexPath
        )
        if let captionsListCell = cell as? CaptionsInfoCell,
           let avatarViewManager = avatarViewManager as? AvatarViewManager {
            let viewModel = captionData[indexPath.row]
            captionsListCell.setup(title: viewModel.speakerName,
                                                subtitle: viewModel.spokenText
            )
        }
        return cell
    }
}
