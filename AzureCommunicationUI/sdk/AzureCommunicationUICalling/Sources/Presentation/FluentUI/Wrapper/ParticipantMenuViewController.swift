//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit

class ParticipantMenuViewController: DrawerContainerViewController<DrawerListItemViewModel> {
    private enum SectionConstants {
        static let headerHeight: CGFloat = 36.0
    }
    private lazy var tableView: UITableView? = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = backgroundColor
        tableView.sectionHeaderHeight = 0
        tableView.sectionFooterHeight = 0
        tableView.separatorStyle = .none
        tableView.allowsSelection = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ParticipantMenuCell.self,
                           forCellReuseIdentifier: ParticipantMenuCell.identifier)
        return tableView
    }()

    override var drawerTableView: UITableView? {
        get { return tableView }
        set { tableView = newValue }
    }

    init(sourceView: UIView,
         isRightToLeft: Bool,
         participantName: String
    ) {
        super.init(sourceView: sourceView, headerName: participantName, isRightToLeft: isRightToLeft)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension ParticipantMenuViewController: UITableViewDataSource, UITableViewDelegate {
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
        label.font = .preferredFont(forTextStyle: .headline)
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

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return SectionConstants.headerHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < self.items.count,
              let cell = tableView.dequeueReusableCell(
                  withIdentifier: ParticipantMenuCell.identifier,
                  for: indexPath) as? ParticipantMenuCell else {
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
