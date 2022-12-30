//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import SwiftUI

enum CompositeIcon: String {
    case cameraSwitch = "ic_fluent_camera_switch_24_regular"
    case meetNow = "ic_fluent_meet_now_20_regular"
    case micOff = "ic_fluent_mic_off_24_filled"
    case micOffRegular = "ic_fluent_mic_off_24_regular"
    case micOn = "ic_fluent_mic_24_filled"
    case micOnRegular = "ic_fluent_mic_24_regular"
    case speakerFilled = "ic_fluent_speaker_2_24_filled"
    case speakerRegular = "ic_fluent_speaker_2_24_regular"
    case speakerBluetooth = "ic_fluent_speaker_bluetooth_24_regular"
    case videoOn = "ic_fluent_video_24_filled"
    case videoOff = "ic_fluent_video_off_24_filled"
    case warning = "ic_fluent_warning_24_filled"
    case endCall = "ic_fluent_call_end_24_filled"
    case endCallRegular = "ic_fluent_call_end_24_regular"
    case showParticipant = "ic_fluent_people_24_regular"
    case leftArrow = "ic_ios_arrow_left_24"
    case dismiss = "ic_fluent_dismiss_16_regular"
    case clock = "ic_fluent_clock_24_filled"
    case checkmark = "ic_fluent_checkmark_24_regular"
    case share = "ic_fluent_share_ios_24_regular"
    case more = "ic_fluent_more_horizontal_24_filled"
}

struct IconProvider {
    func getUIImage(for iconName: CompositeIcon) -> UIImage? {
        UIImage(named: "Icon/\(iconName.rawValue)",
                in: Bundle(for: CallComposite.self),
                compatibleWith: nil)
    }
    func getImage(for iconName: CompositeIcon) -> Image {
        Image("Icon/\(iconName.rawValue)", bundle: Bundle(for: CallComposite.self))
            .resizable()
            .renderingMode(.template)
    }
}
