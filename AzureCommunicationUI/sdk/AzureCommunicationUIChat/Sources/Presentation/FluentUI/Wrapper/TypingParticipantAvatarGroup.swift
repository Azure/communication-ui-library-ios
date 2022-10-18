//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import FluentUI

class TypingParticipantAvatarGroup: UIView {

    private var group = MSFAvatarGroup(style: .stack, size: .xsmall)

    var avatars: [ParticipantInfoModel] = [] {
        didSet {
            setAvatars(data: avatars)
        }
    }

    private enum Constants {
        static let avatarWidth: CGFloat = 16.0
        static let maxAvatarAllowed: Int = 3
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
        group.state.overflowCount = Constants.overflowCount
        group.state.style = .stack
        // Max avatar shown would be 4
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

    private func setAvatars(data: [ParticipantInfoModel]) {
        for participant in data {
            let newAvatar = group.state.createAvatar()
            newAvatar.primaryText = participant.displayName
            newAvatar.isTransparent = false
            newAvatar.isRingVisible = false
        }
    }
}
