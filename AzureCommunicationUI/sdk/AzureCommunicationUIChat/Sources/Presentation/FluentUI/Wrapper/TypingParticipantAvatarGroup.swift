//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import FluentUI
import UIKit

class TypingParticipantAvatarGroup: UIView {

    private var group: MSFAvatarGroup?
    private var lastSeen: [ParticipantInfoModel]?

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
        group = MSFAvatarGroup(style: .stack, size: .xsmall)
        guard let group = group else {
            return
        }
        group.state.overflowCount = Constants.overflowCount
        group.state.style = .stack
        // Max avatar shown would be 3
        group.state.maxDisplayedAvatars = Constants.maxAvatarAllowed
        group.isAccessibilityElement = false
        addSubview(group.view)
        group.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            group.view.leftAnchor.constraint(equalTo: self.leftAnchor),
            group.view.rightAnchor.constraint(equalTo: self.rightAnchor),
            group.view.topAnchor.constraint(equalTo: self.topAnchor),
            group.view.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }

    func setAvatars(from oldData: [ParticipantInfoModel], newData: [ParticipantInfoModel]) {
        // prevent removing the same avatars mutiple times
        guard let group = group,
                oldData != newData,
                oldData != lastSeen else {
            return
        }
        for _ in oldData.indices {
            group.state.removeAvatar(at: 0)
        }
        for participant in newData {
            let newAvatar = group.state.createAvatar()
            newAvatar.primaryText = participant.displayName
            newAvatar.isTransparent = false
            newAvatar.isRingVisible = false
        }
        lastSeen = oldData
    }
}
