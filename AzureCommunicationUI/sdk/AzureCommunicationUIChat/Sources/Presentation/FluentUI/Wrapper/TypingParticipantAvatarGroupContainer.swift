//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct TypingParticipantAvatarGroupContainer: UIViewRepresentable {

    var participantList: [ParticipantInfoModel]
    var participantListOld: [ParticipantInfoModel]
    var avatarGroup: TypingParticipantAvatarGroup

    func makeUIView(context: Context) -> TypingParticipantAvatarGroup {
        avatarGroup.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return avatarGroup
    }

    func updateUIView(_ uiView: TypingParticipantAvatarGroup, context: Context) {
        avatarGroup.setAvatars(from: participantListOld, newData: participantList)
    }
}
