//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

class CompositeSupportFormViewController: DrawerContainerViewController<SupportFormViewModel> {
    private lazy var supportFormTableView: UITableView? = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = backgroundColor
        tableView.sectionHeaderHeight = 0
        tableView.sectionFooterHeight = 0
        tableView.allowsSelection = true
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CompositeSupportFormCell.self,
                           forCellReuseIdentifier: CompositeSupportFormCell.identifier)
        return tableView
    }()

    override var drawerTableView: UITableView? {
        get { return supportFormTableView }
        set { supportFormTableView = newValue }
    }
}

extension CompositeSupportFormViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = CompositeSupportFormCell()
        let supportFormViewModel = self.items[indexPath.row]
        cell.setup(viewModel: supportFormViewModel)
        cell.accessibilityValue = "\(indexPath.row + 1) of \(indexPath.count)"
        cell.bottomSeparatorType = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismissDrawer(animated: true)
    }
}
