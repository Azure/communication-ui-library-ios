//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import FluentUI

class AudioDevicesListViewController: DrawerContainerViewController<AudioDevicesListCellViewModel> {
    private lazy var audioDevicesListTableView: UITableView? = {
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

    override var drawerTableView: UITableView? {
        get { return audioDevicesListTableView }
        set { audioDevicesListTableView = newValue }
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
