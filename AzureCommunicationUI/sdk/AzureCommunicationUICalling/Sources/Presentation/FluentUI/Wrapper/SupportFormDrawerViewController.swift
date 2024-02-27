//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import SwiftUI

class SupportFormDrawerViewController: DrawerContainerViewController<SelectableDrawerListItemViewModel> {
    private lazy var supportFormListTableView: UITableView? = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = backgroundColor
        tableView.sectionHeaderHeight = 0
        tableView.sectionFooterHeight = 0
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        // tableView.register(CompositeAudioDevicesListCell.self,
        //                    forCellReuseIdentifier: CompositeAudioDevicesListCell.identifier)
        return tableView
    }()

    override var drawerTableView: UITableView? {
        get { return supportFormListTableView }
        set { supportFormListTableView = newValue }
    }

}

extension SupportFormDrawerViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "YourCellIdentifier",
                                                    for: indexPath) as? SwiftUIHostingTableViewCell {
            // Assuming you have a reference to your parent view controller
            cell.host(Text("test"), parentViewController: self)
            return cell
        } else {
            // Handle the failure to dequeue the cell properly, maybe return a default cell
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismissDrawer(animated: true)
    }
}

class SwiftUIHostingTableViewCell: UITableViewCell {
    private var hostingController: UIHostingController<AnyView>?

    func host<Content: View>(_ view: Content, parentViewController: UIViewController) {
        // Remove the previous hosting controller if there was one
        hostingController?.removeFromParent()
        hostingController?.view.removeFromSuperview()

        // Create a new hosting controller with the SwiftUI view
        let newHostingController = UIHostingController(rootView: AnyView(view))
        parentViewController.addChild(newHostingController)
        self.contentView.addSubview(newHostingController.view)

        // Set up the hosting controller's view to fill the cell
        newHostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            newHostingController.view.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            newHostingController.view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            newHostingController.view.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            newHostingController.view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor)
        ])

        newHostingController.didMove(toParent: parentViewController)

        // Keep a reference to the new hosting controller
        self.hostingController = newHostingController
    }
}
