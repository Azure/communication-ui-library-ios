//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import FluentUI
import UIKit

class CallInfoListViewController: DrawerContainerViewController<CallInfoListCellViewModel> {
    private enum SectionConstants {
        static let headerHeight: CGFloat = 36.0
    }
    private lazy var callInfoListTableView: UITableView? = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = backgroundColor
        tableView.sectionHeaderHeight = SectionConstants.headerHeight
        tableView.sectionFooterHeight = 0
        tableView.separatorStyle = .none
        tableView.allowsSelection = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CallInfoListCell.self,
                           forCellReuseIdentifier: CallInfoListCell.identifier)
        return tableView
    }()

    override var drawerTableView: UITableView? {
        get { return callInfoListTableView }
        set { callInfoListTableView = newValue }
    }
}

extension CallInfoListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section == 0 else {
            return nil
        }
        let headerView = UIView.init(frame: CGRect.init(x: 0,
                                                        y: 0,
                                                        width: tableView.frame.width,
                                                        height: SectionConstants.headerHeight))

        let label = UILabel()
        label.frame = headerView.frame
        label.text = headerName
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = StyleProvider.color.onSurface
        label.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(label)
        NSLayoutConstraint.activate([
            headerView.leadingAnchor.constraint(equalTo: label.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: label.trailingAnchor),
            headerView.topAnchor.constraint(equalTo: label.topAnchor),
            headerView.bottomAnchor.constraint(equalTo: label.bottomAnchor)
        ])
        return headerView
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < self.items.count,
              let cell = tableView.dequeueReusableCell(
                  withIdentifier: CallInfoListCell.identifier,
                  for: indexPath) as? CallInfoListCell else {
            return UITableViewCell()
        }
        let viewModel = self.items[indexPath.row]

        cell.setup(viewModel: viewModel)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return SectionConstants.headerHeight
    }
}
