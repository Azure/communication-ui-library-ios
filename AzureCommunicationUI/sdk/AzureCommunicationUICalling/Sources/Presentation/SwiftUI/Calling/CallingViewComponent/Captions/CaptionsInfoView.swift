//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import FluentUI
import SwiftUI

struct CaptionsInfoView: UIViewControllerRepresentable {
    let captionTableViewController: UITableViewController
    private let captionsViewManager: CaptionsViewManager

    private static func getCaptionsListTableViewController() -> UITableViewController {
        let tableViewController = CaptionsInfoViewController(style: .plain)
        tableViewController.loadViewIfNeeded()
        tableViewController.tableView.separatorStyle = .none
        tableViewController.tableView.register(CompositeParticipantsListCell.self,
                           forCellReuseIdentifier: CompositeParticipantsListCell.identifier)
        return tableViewController
    }

    init(captionsViewManager: CaptionsViewManager) {
        self.captionsViewManager = captionsViewManager
        self.captionTableViewController = CaptionsInfoView.getCaptionsListTableViewController()
        self.captionTableViewController.tableView.delegate = captionsViewManager
        self.captionTableViewController.tableView.dataSource = captionsViewManager
    }

    func makeUIViewController(context: Context) -> some UIViewController {
        return captionTableViewController
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        return
    }

}
