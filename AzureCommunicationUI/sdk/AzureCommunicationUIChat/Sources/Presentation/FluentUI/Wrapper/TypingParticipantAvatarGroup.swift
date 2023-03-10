//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import FluentUI
import UIKit

class TypingParticipantAvatarGroup: UIView {

    private var group: MSFAvatarGroup?
    private var lastSeen: [ParticipantInfoModel]?
    private var avatarCount: Int = 0

    private enum Constants {
        static let avatarWidth: CGFloat = 16.0
        static let maxAvatarAllowed: Int = 2
        static let overflowCount: Int = 0
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initAvatarGroup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initAvatarGroup()
    }
}

extension TypingParticipantAvatarGroup {
    private func initAvatarGroup() {
        group = MSFAvatarGroup(style: .stack, size: .size16)
        guard let group = group else {
            return
        }
        group.state.overflowCount = Constants.overflowCount
        // total avatar shown would be 3
        // (max allowed 2 + 1 to show number of remaining participants)
        group.state.maxDisplayedAvatars = Constants.maxAvatarAllowed
        group.isAccessibilityElement = false
        addSubview(group)
        group.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            group.leftAnchor.constraint(equalTo: self.leftAnchor),
            group.rightAnchor.constraint(equalTo: self.rightAnchor),
            group.topAnchor.constraint(equalTo: self.topAnchor),
            group.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }

    func setAvatars(to newData: [ParticipantInfoModel]) {
        guard let group = group,
              lastSeen != newData else {
            return
        }
        for _ in 0..<avatarCount {
            group.state.removeAvatar(at: 0)
        }
        avatarCount = 0
        for participant in newData {
            avatarCount += 1
            let newAvatar = group.state.createAvatar()
            newAvatar.primaryText = participant.displayName
            newAvatar.isTransparent = false
            newAvatar.isRingVisible = false
        }
        lastSeen = newData
    }
}
