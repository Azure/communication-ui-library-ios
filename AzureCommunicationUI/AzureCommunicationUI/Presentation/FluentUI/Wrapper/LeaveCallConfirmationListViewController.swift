//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import FluentUI

class LeaveCallConfirmationListViewController: DrawerContainerViewController<LeaveCallConfirmationViewModel> {
    private lazy var audioDevicesListTableView: UITableView? = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = backgroundColor
        tableView.sectionHeaderHeight = 0
        tableView.sectionFooterHeight = 0
        tableView.allowsSelection = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CompositeLeaveCallConfirmationListCell.self,
                           forCellReuseIdentifier: CompositeLeaveCallConfirmationListCell.identifier)
        return tableView
    }()

    override var drawerTableView: UITableView? {
        get { return audioDevicesListTableView }
        set { audioDevicesListTableView = newValue }
    }
}

extension LeaveCallConfirmationListViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section == 0 else {
            return nil
        }
        let uiview = UIView()
        let label = UILabel()
        label.text = "Leave Call ?"
        label.textAlignment = .center
        // label.text = "\(localizationProvider.getLocalizedString(.leaveCall)) ?"
        return uiview
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < self.items.count,
              let cell = tableView.dequeueReusableCell(
                  withIdentifier: CompositeLeaveCallConfirmationListCell.identifier,
                  for: indexPath) as? CompositeLeaveCallConfirmationListCell else {
            return UITableViewCell()
        }
        let viewModel = self.items[indexPath.row]

        cell.setup(displayName: viewModel.title)
        cell.accessibilityValue = "\(indexPath.row + 1) of \(indexPath.count)"
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.items[indexPath.row].action()
        dismissDrawer(animated: true)
    }
}
