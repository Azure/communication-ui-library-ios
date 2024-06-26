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
    private var plusMoreMenuItem: ParticipantsListCellViewModel?

    private var admintAll: () -> Void
    private var declineAll: () -> Void
    private var admitParticipant: (_ participantId: String) -> Void
    private var declineParticipant: (_ participantId: String) -> Void
    private let waitingInLobby: String
    private let inTheCall: String
    private let confirmTitleAdmitParticipant: String
    private let admitAllButtonText: String
    private let confirmTitleAdmitAll: String
    private let confirmAdmit: String
    private let confirmDecline: String
    private var openParticipantMenu: (_ participantId: String, _ participantDisplayName: String) -> Void
    private let plusMoreText: String

    private var admitAlert: UIAlertController?

    override var items: [ParticipantsListCellViewModel] {
        get {
            return allParticipants
        }
        set {
            allParticipants = newValue

            inCallParticipants = newValue.filter { participantsListCellViewModel in
                !participantsListCellViewModel.isPlusMoreMenuItem &&
                !participantsListCellViewModel.isInLobby
            }

            lobbyParticipants = newValue.filter { participantsListCellViewModel in
                !participantsListCellViewModel.isPlusMoreMenuItem &&
                participantsListCellViewModel.isInLobby
            }

            plusMoreMenuItem = newValue.first { participantsListCellViewModel in
                participantsListCellViewModel.isPlusMoreMenuItem
            }
        }
    }

    init(sourceView: UIView,
         avatarViewManager: AvatarViewManager,
         isRightToLeft: Bool,
         admintAll: @escaping () -> Void,
         declineAll: @escaping () -> Void,
         admitParticipant: @escaping (_ participantId: String) -> Void,
         declineParticipant: @escaping (_ participantId: String) -> Void,
         waitingInLobby: String,
         inTheCall: String,
         admitAllButtonText: String,
         confirmTitleAdmitParticipant: String,
         confirmTitleAdmitAll: String,
         confirmAdmit: String,
         confirmDecline: String,
         openParticipantMenu: @escaping (_ participantId: String, _ participantDisplayName: String) -> Void,
         plusMoreText: String
    ) {
        self.avatarViewManager = avatarViewManager
        self.admintAll = admintAll
        self.declineAll = declineAll
        self.admitParticipant = admitParticipant
        self.declineParticipant = declineParticipant
        self.waitingInLobby = waitingInLobby
        self.inTheCall = inTheCall
        self.admitAllButtonText = admitAllButtonText
        self.confirmTitleAdmitParticipant = confirmTitleAdmitParticipant
        self.confirmTitleAdmitAll = confirmTitleAdmitAll
        self.confirmAdmit = confirmAdmit
        self.confirmDecline = confirmDecline
        self.openParticipantMenu = openParticipantMenu
        self.plusMoreText = plusMoreText
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
        var participantCount = participants(section: section).count
        if !isLobbySection(section: section),
           let plusMoreMenuItem = self.plusMoreMenuItem {
            participantCount += 1
        }
        return participantCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let participantsListCellViewModels = participants(section: indexPath.section)

        guard indexPath.row <= participantsListCellViewModels.count,
              let cell = tableView.dequeueReusableCell(
                withIdentifier: CompositeParticipantsListCell.identifier,
                for: indexPath) as? CompositeParticipantsListCell else {
            return UITableViewCell()
        }

        if indexPath.row == participantsListCellViewModels.count {
            // this is a plus more lable cell
            if let plusMoreMenuItem = self.plusMoreMenuItem,
               let plusMoreCount = plusMoreMenuItem.plusMoreCount {
                let title = String(format: self.plusMoreText, String(plusMoreCount))
                cell.setup(title: title)
            }

            cell.bottomSeparatorType = .none
            return cell
        } else {
            let participantCellViewModel = participantsListCellViewModels[indexPath.row]

            cell.setup(viewModel: participantCellViewModel,
                       avatarViewManager: avatarViewManager)
            cell.bottomSeparatorType = .none
            return cell
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let hStackView = UIStackView()
        hStackView.axis = .horizontal
        hStackView.distribution = .equalSpacing
        hStackView.isLayoutMarginsRelativeArrangement = true
        hStackView.directionalLayoutMargins = .init(top: 0, leading: 12, bottom: 0, trailing: 15)
        hStackView.backgroundColor = StyleProvider.color.drawerColor

        let isLobbySection = isLobbySection(section: section)

        let label = UILabel()
        label.text = isLobbySection
        ? String(format: waitingInLobby, lobbyParticipants.count)
        : String(format: inTheCall, inCallParticipants.count + (plusMoreMenuItem?.plusMoreCount ?? 0))

        label.font = .systemFont(ofSize: 14)
        label.textColor = StyleProvider.color.onHoldLabel

        hStackView.addArrangedSubview(label)

        if isLobbySection {
            let admitAllButton = Button(style: .borderless)
            admitAllButton.setTitle(admitAllButtonText, for: .normal)
            admitAllButton.titleLabel?.font = .systemFont(ofSize: 14)
            admitAllButton.sizeToFit()
            admitAllButton.translatesAutoresizingMaskIntoConstraints = false
            admitAllButton.setTitleColor(.systemBlue, for: .normal)
            admitAllButton.addTarget(self, action: #selector(onAdmitAllTap), for: .touchUpInside)

            hStackView.addArrangedSubview(admitAllButton)
        }

        return hStackView
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let participantsInSection = participants(section: indexPath.section)
        guard indexPath.row < participantsInSection.count else {
            // if row index beyond participant count, then it is plus more menu item
            return
        }
        let participantsListCellViewModel = participantsInSection[indexPath.row]
        if isLobbySection(section: indexPath.section) {
            onLobbyParticipantSelect(participantsListCellViewModel: participantsListCellViewModel)
        } else {
            onParticipantSelect(participantsListCellViewModel: participantsListCellViewModel)
        }
    }

    func onParticipantSelect(participantsListCellViewModel: ParticipantsListCellViewModel) {
        guard let participantId = participantsListCellViewModel.participantId else {
            return
        }
        dismissDrawer(animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let participantViewData = participantsListCellViewModel.getParticipantViewData(from: self.avatarViewManager)
            let displayName = participantsListCellViewModel.getParticipantName(with: participantViewData)
            self.openParticipantMenu(participantId, displayName)
        }
    }

    func onLobbyParticipantSelect(participantsListCellViewModel: ParticipantsListCellViewModel) {
        guard let participantId = participantsListCellViewModel.participantId else {
            return
        }

        let participantViewData = participantsListCellViewModel.getParticipantViewData(from: avatarViewManager)
        let avatarParticipantName = participantsListCellViewModel.getParticipantName(with: participantViewData)

        let title = String(format: confirmTitleAdmitParticipant, avatarParticipantName)
        confirmAdmitting(title: title,
                         onConfirmed: {
            self.admitParticipant(participantId)
        },
                         onDeclined: {
            self.declineParticipant(participantId)
        })
    }

    @objc func onAdmitAllTap() {
        confirmAdmitting(title: confirmTitleAdmitAll,
                         onConfirmed: self.admintAll,
                         onDeclined: self.declineAll)
    }

    private func confirmAdmitting(title: String,
                                  onConfirmed: @escaping () -> Void,
                                  onDeclined: @escaping () -> Void) {
        DispatchQueue.main.async {
            guard let topViewController = UIWindow.keyWindow?.topViewController else {
                return
            }

            let admitAlert = UIAlertController(title: title,
                                               message: nil,
                                               preferredStyle: .alert)
            admitAlert.addAction(UIAlertAction(title: self.confirmDecline, style: .cancel) { _ in
                onDeclined()
                self.admitAlert = nil
            })
            admitAlert.addAction(UIAlertAction(title: self.confirmAdmit, style: .default) { _ in
                onConfirmed()
                self.admitAlert = nil
            })
            topViewController.present(admitAlert, animated: true) { [weak self] in
                guard let self = self else {
                    return
                }

                self.addDismissControl(admitAlert.view)
            }

            self.admitAlert = admitAlert
        }
    }

    private func addDismissControl(_ toView: UIView) {
        let dismissControl = UIControl()
        dismissControl.addTarget(self, action: #selector(self.dismissAlertController), for: .touchDown)
        dismissControl.isUserInteractionEnabled = true
        let frame = toView.superview?.frame ?? CGRect.zero
        dismissControl.frame = frame
        toView.superview?.insertSubview(dismissControl, belowSubview: toView)
    }

    @objc private func dismissAlertController() {
        admitAlert?.dismiss(animated: true)
        self.admitAlert = nil
    }

    private func isLobbySection(section: Int) -> Bool {
        return lobbyParticipants.count != 0 && section == 0
    }

    private func participants(section: Int) -> [ParticipantsListCellViewModel] {
        if isLobbySection(section: section) {
            return lobbyParticipants
        }
        return inCallParticipants
    }
}
