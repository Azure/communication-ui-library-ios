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
    private var timer: Timer?

    init(avatarViewManager: AvatarViewManagerProtocol) {
        self.avatarViewManager = avatarViewManager
    }

    func startCaptionSimulationTimer(tableView: UITableView?) {
        print("Luke Caption simulation is started")
        self.tableView = tableView
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            let formatter = DateFormatter()
            formatter.timeStyle = .long
            formatter.dateStyle = .none
            let newCaption = CallCompositeCaptionsData(
                resultType: .final,
                speakerRawId: "001",
                speakerName: "Tester",
                spokenLanguage: "english",
                spokenText: formatter.string(from: Date()),
                timestamp: Date(),
                captionLanguage: "english",
                captionText: formatter.string(from: Date())
            )

            self.addCaptionData(newCaption: newCaption)
        }
    }

    func stopCaptionSimulationTimer() {
        print("Luke Caption simulation is stopped")
        timer?.invalidate()
        timer = nil
    }

    func addCaptionData(newCaption: CallCompositeCaptionsData) {
        guard let tableView = tableView else {
            return
        }

        let tableViewAtBottom = tableView.contentOffset.y >=
            (tableView.contentSize.height - tableView.frame.size.height)

        tableView.beginUpdates()

        captionData.append(newCaption)
        let insertIndexPath = IndexPath(row: captionData.count - 1, section: 0)
        tableView.insertRows(at: [insertIndexPath], with: .top)

        tableView.endUpdates()

        tableView.beginUpdates()

        while self.captionData.count > 5 {
            self.captionData.removeFirst()
            let deleteIndexPath = IndexPath(row: 0, section: 0)
            tableView.deleteRows(at: [deleteIndexPath], with: .top)
        }

        tableView.endUpdates()

        let lastRowIndex = tableView.numberOfRows(inSection: 0) - 1
        let lastIndexPath = IndexPath(row: lastRowIndex, section: 0)

        if tableViewAtBottom, lastRowIndex > 0 {
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
            withIdentifier: CompositeParticipantsListCell.identifier,
            for: indexPath
        )
        if let compositeParticipantsListCell = cell as? CompositeParticipantsListCell,
           let avatarViewManager = avatarViewManager as? AvatarViewManager {
            let viewModel = captionData[indexPath.row]
            compositeParticipantsListCell.setup(title: viewModel.spokenText)
        }
        return cell
    }
}
