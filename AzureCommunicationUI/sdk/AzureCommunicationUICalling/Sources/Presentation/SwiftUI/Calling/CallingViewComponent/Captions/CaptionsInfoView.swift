//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import FluentUI
import SwiftUI

struct CaptionsInfoView: UIViewRepresentable {
    private func getCaptionsListTableView() -> UITableView {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .white
        tableView.sectionHeaderHeight = 40
        tableView.sectionFooterHeight = 0
        tableView.separatorStyle = .none
        tableView.register(CompositeParticipantsListCell.self,
                           forCellReuseIdentifier: CompositeParticipantsListCell.identifier)
        return tableView
    }

    func makeUIView(context: Context) -> some UIView {
        return self.getCaptionsListTableView()
    }
    func updateUIView(_ uiView: UIViewType, context: Context) {
        return
    }

}
