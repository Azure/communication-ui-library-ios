//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import FluentUI

class AudioDevicesListViewController: DrawerContainerViewController<AudioDevicesListCellViewModel> {
    private weak var controller: DrawerController?
    override var drawerController: DrawerController? {
        return controller
    }

    var halfScreenHeight: CGFloat {
        UIScreen.main.bounds.height / 2
    }

    let drawerResizeBarHeight: CGFloat = 25
    let backgroundColor: UIColor = UIDevice.current.userInterfaceIdiom == .pad
        ? StyleProvider.color.popoverColor
        : StyleProvider.color.drawerColor

    lazy var audioDevicesListTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = backgroundColor
        tableView.sectionHeaderHeight = 0
        tableView.sectionFooterHeight = 0
        tableView.allowsSelection = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CompositeAudioDevicesListCell.self,
                           forCellReuseIdentifier: CompositeAudioDevicesListCell.identifier)
        return tableView
    }()

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        resizeAudioDevicesListDrawer()
    }

    override func updateDrawerList(items: [AudioDevicesListCellViewModel]) {
        super.updateDrawerList(items: items)
        resizeAudioDevicesListDrawer()
    }

    override func getDrawerController(from sourceView: UIView) -> DrawerController {
        let controller = DrawerController(
            sourceView: sourceView,
            sourceRect: sourceView.bounds,
            presentationDirection: .up)
        controller.delegate = self.delegate
        let contentView = audioDevicesListTableView
        controller.contentView = contentView
        controller.resizingBehavior = .dismiss
        controller.backgroundColor = backgroundColor

        self.controller = controller
        resizeAudioDevicesListDrawer()
        return controller
    }

    private func resizeAudioDevicesListDrawer() {
        let isiPhoneLayout = UIDevice.current.userInterfaceIdiom == .phone
        var isScrollEnabled = !isiPhoneLayout
        var drawerHeight = CGFloat(self.items.count * 44)

        if isiPhoneLayout {
            // workaround to adjust cell divider height for drawer resize
            let tableCellsDividerOffsetHeight = CGFloat(self.items.count * 3)
            drawerHeight += tableCellsDividerOffsetHeight + self.drawerResizeBarHeight
        } else {
            drawerHeight = CGFloat(self.items.count) * 48.5
        }
        if drawerHeight > self.halfScreenHeight {
            drawerHeight = self.halfScreenHeight
            isScrollEnabled = true
        }

        DispatchQueue.main.async {
            self.audioDevicesListTableView.reloadData()
            self.audioDevicesListTableView.isScrollEnabled = isScrollEnabled
            self.controller?.preferredContentSize = CGSize(width: 400, height: drawerHeight)
        }
    }
}

extension AudioDevicesListViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < self.items.count,
              let cell = tableView.dequeueReusableCell(
                  withIdentifier: CompositeAudioDevicesListCell.identifier,
                  for: indexPath) as? CompositeAudioDevicesListCell else {
            return UITableViewCell()
        }
        let audioDeviceViewModel = self.items[indexPath.row]

        cell.setup(viewModel: audioDeviceViewModel)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.items[indexPath.row].switchAudioDevice()
        dismissDrawer(animated: true)
    }
}
