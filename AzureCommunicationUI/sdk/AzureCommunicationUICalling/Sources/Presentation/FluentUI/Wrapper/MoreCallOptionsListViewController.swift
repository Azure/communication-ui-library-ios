//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

class MoreCallOptionsListViewController: DrawerContainerViewController<DrawerListItemViewModel> {
    private enum SectionConstants {
        static let headerHeight: CGFloat = 36.0
    }
    private lazy var callInfoListTableView: UITableView? = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = backgroundColor
        tableView.sectionHeaderHeight = 0
        tableView.sectionFooterHeight = 0
        tableView.separatorStyle = .none
        tableView.allowsSelection = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MoreCallOptionsListCell.self,
                           forCellReuseIdentifier: MoreCallOptionsListCell.identifier)
        return tableView
    }()

    override var drawerTableView: UITableView? {
        get { return callInfoListTableView }
        set { callInfoListTableView = newValue }
    }
}

extension MoreCallOptionsListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < self.items.count,
              let cell = tableView.dequeueReusableCell(
                  withIdentifier: MoreCallOptionsListCell.identifier,
                  for: indexPath) as? MoreCallOptionsListCell else {
            return UITableViewCell()
        }
        let viewModel = self.items[indexPath.row]

        cell.setup(viewModel: viewModel)
        cell.accessibilityIdentifier = viewModel.accessibilityIdentifier
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.items[indexPath.row].action()
        dismissDrawer(animated: true)
    }
}
