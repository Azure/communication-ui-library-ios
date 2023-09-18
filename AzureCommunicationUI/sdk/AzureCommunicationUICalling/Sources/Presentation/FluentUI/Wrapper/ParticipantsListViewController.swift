//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import FluentUI

class ParticipantsListViewController: DrawerContainerViewController<ParticipantsListCellViewModel> {
    private let avatarViewManager: AvatarViewManager
    private lazy var participantsListTableView: UITableView? = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = backgroundColor
        tableView.sectionHeaderHeight = 40
        tableView.sectionFooterHeight = 0
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.register(CompositeParticipantsListCell.self,
                           forCellReuseIdentifier: CompositeParticipantsListCell.identifier)
        return tableView
    }()

    override var drawerTableView: UITableView? {
        get { return participantsListTableView }
        set { participantsListTableView = newValue }
    }

    private var allParticipants: [ParticipantsListCellViewModel] = []
    private var inCallParticipants: [ParticipantsListCellViewModel] = []
    private var lobbyParticipants: [ParticipantsListCellViewModel] = []

    override var items: [ParticipantsListCellViewModel] {
        get {
            return allParticipants
        }
        set {
            allParticipants = newValue

            inCallParticipants = allParticipants.filter { participantsListCellViewModel in
                !participantsListCellViewModel.isInLobby
            }

            lobbyParticipants = allParticipants.filter { participantsListCellViewModel in
                participantsListCellViewModel.isInLobby
            }
        }
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

    override func shouldUpdateLayout(items updatedItems: [ParticipantsListCellViewModel]) -> Bool {
        return allParticipants != updatedItems
        || allParticipants.count != updatedItems.count
        || inCallParticipants.count != updatedItems.filter { participantsListCellViewModel in
            !participantsListCellViewModel.isInLobby
        }.count
        || lobbyParticipants.count != updatedItems.filter { participantsListCellViewModel in
            participantsListCellViewModel.isInLobby
        }.count
    }
}

extension ParticipantsListViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return lobbyParticipants.count == 0 ? 1 : 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return participants(section: section).count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let items = participants(section: indexPath.section)

        guard indexPath.row < items.count,
              let cell = tableView.dequeueReusableCell(
                withIdentifier: CompositeParticipantsListCell.identifier,
                for: indexPath) as? CompositeParticipantsListCell else {
            return UITableViewCell()
        }
        let participantViewModel = items[indexPath.row]

        cell.setup(viewModel: participantViewModel,
                   avatarViewManager: avatarViewManager)
        cell.bottomSeparatorType = .none
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let hStackView = UIStackView()
        hStackView.axis = .horizontal
        hStackView.distribution = .equalSpacing
        hStackView.isLayoutMarginsRelativeArrangement = true
        hStackView.directionalLayoutMargins = .init(top: 0, leading: 12, bottom: 0, trailing: 15)

        let isLobbySection = lobbyParticipants.count != 0 && section == 0

        let label = UILabel()
        label.text = isLobbySection
                        ? "Waiting in lobby (\(lobbyParticipants.count))"
                        : "In the call (\(inCallParticipants.count))"

        label.font = .systemFont(ofSize: 14)
        label.textColor = StyleProvider.color.onHoldLabel

        hStackView.addArrangedSubview(label)

        if isLobbySection {
            let admitAllButton = UIButton()
            admitAllButton.setTitle("Admit all", for: .normal)
            admitAllButton.titleLabel?.font = .systemFont(ofSize: 14)
            admitAllButton.sizeToFit()
            admitAllButton.translatesAutoresizingMaskIntoConstraints = false
            admitAllButton.setTitleColor(.systemBlue, for: .normal)
            hStackView.addArrangedSubview(admitAllButton)
        }

        return hStackView
    }

    private func participants(section: Int) -> [ParticipantsListCellViewModel] {
        if lobbyParticipants.count != 0 && section == 0 {
            return lobbyParticipants
        }
        return inCallParticipants
    }
}
