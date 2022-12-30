//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

class ParticipantsListViewController: DrawerContainerViewController<ParticipantsListCellViewModel> {
    private let avatarViewManager: AvatarViewManager
    private lazy var participantsListTableView: UITableView? = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = backgroundColor
        tableView.sectionHeaderHeight = 0
        tableView.sectionFooterHeight = 0
        tableView.allowsSelection = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CompositeParticipantsListCell.self,
                           forCellReuseIdentifier: CompositeParticipantsListCell.identifier)
        return tableView
    }()

    override var drawerTableView: UITableView? {
        get { return participantsListTableView }
        set { participantsListTableView = newValue }
    }

    init(sourceView: UIView,
         avatarViewManager: AvatarViewManager,
         isRightToLeft: Bool
    ) {
        self.avatarViewManager = avatarViewManager
        super.init(sourceView: sourceView, isRightToLeft: isRightToLeft)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ParticipantsListViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < self.items.count,
              let cell = tableView.dequeueReusableCell(
                  withIdentifier: CompositeParticipantsListCell.identifier,
                  for: indexPath) as? CompositeParticipantsListCell else {
            return UITableViewCell()
        }
        let participantViewModel = self.items[indexPath.row]

        cell.setup(viewModel: participantViewModel,
                   avatarViewManager: avatarViewManager)
        return cell
    }
}
