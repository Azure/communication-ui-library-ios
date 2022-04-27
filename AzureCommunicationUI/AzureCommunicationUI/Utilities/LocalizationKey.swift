//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

enum LocalizationKey: String {
    /* Devices */
    case iOS = "AzureCommunicationUICalling.AudioDevice.DeviceDrawer.iOS"
    case speaker = "AzureCommunicationUICalling.AudioDevice.DeviceDrawer.Speaker"
    case iPhone = "AzureCommunicationUICalling.AudioDevice.DeviceDrawer.iPhone"
    case iPad = "AzureCommunicationUICalling.AudioDevice.DeviceDrawer.iPad"
    case headphones = "AzureCommunicationUICalling.AudioDevice.DeviceDrawer.Headphones"
    case bluetooth = "AzureCommunicationUICalling.AudioDevice.DeviceDrawer.Bluetooth"

    /* DemoView */
    case startExperience = "AzureCommunicationUICalling.DemoView.StartExperience"
    case startExperienceAccessibilityLabel = "AzureCommunicationUICalling.DemoView.StartExperience.AccessibilityLabel"
    case clearTokenTextFieldAccessibilityLabel =
            "AzureCommunicationUICalling.DemoView.ClearTokenTextField.AccessibilityLabel"

    /* SetupView */
    case setupTitle = "AzureCommunicationUICalling.SetupView.Title"
    case dismissAccessibilityLabel = "AzureCommunicationUICalling.SetupView.Button.Dismiss.AccessibilityLabel"
    case joinCall = "AzureCommunicationUICalling.SetupView.Button.JoinCall"
    case joinCallAccessibilityLabel = "AzureCommunicationUICalling.SetupView.Button.JoinCall.AccessibilityLabel"
    case joiningCall = "AzureCommunicationUICalling.SetupView.Button.JoiningCall"
    case videoOff = "AzureCommunicationUICalling.SetupView.Button.VideoOff"
    case videoOffAccessibilityLabel = "AzureCommunicationUICalling.SetupView.Button.VideoOff.AccessibilityLabel"
    case videoOn = "AzureCommunicationUICalling.SetupView.Button.VideoOn"
    case videoOnAccessibilityLabel = "AzureCommunicationUICalling.SetupView.Button.VideoOn.AccessibilityLabel"
    case toggleVideoAccessibilityID = "AzureCommunicationUICalling.SetupView.Button.Video.AccessibilityID"
    case micOff = "AzureCommunicationUICalling.SetupView.Button.MicOff"
    case micOffAccessibilityLabel = "AzureCommunicationUICalling.SetupView.Button.MicOff.AccessibilityLabel"
    case micOn = "AzureCommunicationUICalling.SetupView.Button.MicOn"
    case micOnAccessibilityLabel = "AzureCommunicationUICalling.SetupView.Button.MicOn.AccessibilityLabel"
    case togglMicAccessibilityID = "AzureCommunicationUICalling.SetupView.Button.Mic.AccessibilityID"
    case device = "AzureCommunicationUICalling.SetupView.Button.Device"
    case deviceAccesibiiltyLabel = "AzureCommunicationUICalling.SetupView.Button.Device.AccessibilityLabel"
    case cameraDisabled = "AzureCommunicationUICalling.SetupView.PreviewArea.AudioGrantedCameraDisabled"
    case audioAndCameraDisabled = "AzureCommunicationUICalling.SetupView.PreviewArea.AudioDisabledCameraDenied"
    case audioDisabled = "AzureCommunicationUICalling.SetupView.PreviewArea.AudioDisabled"

    /* LobbyView */
    case waitingForHost = "AzureCommunicationUICalling.LobbyView.Text.WaitingForHost"
    case waitingDetails = "AzureCommunicationUICalling.LobbyView.Text.WaitingDetails"

    /* CallingView */
    case callWith0Person = "AzureCommunicationUICalling.CallingView.InfoHeader.WaitingForOthersToJoin"
    case callWith1Person = "AzureCommunicationUICalling.CallingView.InfoHeader.CallWith1Person"
    // %d is for number of people in call
    case callWithNPerson = "AzureCommunicationUICalling.CallingView.InfoHeader.CallWithNPeople"

    case unnamedParticipant = "AzureCommunicationUICalling.CallingView.ParticipantDrawer.Unnamed"
    // %@ is local participant name
    case localeParticipantWithSuffix =
            "AzureCommunicationUICalling.CallingView.ParticipantDrawer.LocalParticipant"
    case muted = "AzureCommunicationUICalling.CallingView.ParticipantDrawer.IsMuted"
    case unmuted = "AzureCommunicationUICalling.CallingView.ParticipantDrawer.IsUnmuted"

    case frontCamera = "AzureCommunicationUICalling.CallingView.SwitchCamera.Front"
    case backCamera = "AzureCommunicationUICalling.CallingView.SwitchCamera.Back"

    case onePersonJoined = "AzureCommunicationUICalling.CallingView.OnePersonJoined"
    case multiplePeopleJoined = "AzureCommunicationUICalling.CallingView.MutiplePeopleJoined"
    case onePersonLeft = "AzureCommunicationUICalling.CallingView.OnePersonLeft"
    case multiplePeopleLeft = "AzureCommunicationUICalling.CallingView.MutiplePeopleLeft"

    case videoAccessibilityLabel = "AzureCommunicationUICalling.CallingView.ControlButton.Video.AccessibilityLabel"
    case micAccessibilityLabel = "AzureCommunicationUICalling.CallingView.ControlButton.Microphone.AccessibilityLabel"
    case audioDeviceAccessibilityLabel =
            "AzureCommunicationUICalling.CallingView.ControlButton.AudioDevice.AccessibilityLabel"
    case hangupAccessibilityLabel = "AzureCommunicationUICalling.CallingView.ControlButton.HangUp.AccessibilityLabel"

    case leaveCallListHeader = "AzureCommunicationUICalling.CallingView.LeaveCallList.Header.LeaveCall"
    case leaveCall = "AzureCommunicationUICalling.CallingView.Overlay.LeaveCall"
    case cancel = "AzureCommunicationUICalling.CallingView.Overlay.Cancel"
    case cancelAccssibilityLabel = "AzureCommunicationUICalling.CallingView.Overlay.Cancel.AccssibilityLabel"

    /* ComplianceBanner title */
    case bannerTitleRecordingAndTranscriptionStarted =
            "AzureCommunicationUICalling.CallingView.BannerTitle.RecordingAndTranscribingStarted"
    case bannerTitleReordingStarted =
            "AzureCommunicationUICalling.CallingView.BannerTitle.RecordingStarted"
    case bannerTitleTranscriptionStoppedStillRecording =
            "AzureCommunicationUICalling.CallingView.BannerTitle.TranscriptionStoppedStillRecording"
    case bannerTitleTranscriptionStarted =
            "AzureCommunicationUICalling.CallingView.BannerTitle.TranscriptionStarted"
    case bannerTitleTranscriptionStopped =
            "AzureCommunicationUICalling.CallingView.BannerTitle.TranscriptionStopped"
    case bannerTitleRecordingStoppedStillTranscribing =
            "AzureCommunicationUICalling.CallingView.BannerTitle.RecordingStoppedStillTranscribing"
    case bannerTitleRecordingStopped =
            "AzureCommunicationUICalling.CallingView.BannerTitle.RecordingStopped"
    case bannerTitleRecordingAndTranscribingStopped =
            "AzureCommunicationUICalling.CallingView.BannerTitle.RecordingAndTranscribingStopped"

    /* ComplianceBanner body */
    case bannerBodyConsent = "AzureCommunicationUICalling.CallingView.BannerBody.Consent"
    case bannerBodyRecording = "AzureCommunicationUICalling.CallingView.BannerBody.Recording"
    case bannerBodyTranscriptionStopped = "AzureCommunicationUICalling.CallingView.BannerBody.TranscriptionStopped"
    case bannerBodyOnlyTranscribing = "AzureCommunicationUICalling.CallingView.BannerBody.OnlyTranscribing"
    case bannerBodyRecordingStopped = "AzureCommunicationUICalling.CallingView.BannerBody.RecordingStopped"
    case bannerBodyRecordingAndTranscriptionStopped =
            "AzureCommunicationUICalling.CallingView.BannerBody.RecordingAndTranscriptionStopped"

    /* ComplianceBanner display link */
    case bannerDisplayLinkPrivacyPolicy = "AzureCommunicationUICalling.CallingView.BannerLink.PrivacyPolicy"
    case bannerDisplayLinkLearnMore = "AzureCommunicationUICalling.CallingView.BannerLink.LearnMore"

    /* PopUp warning */
    case snackBarDismiss = "AzureCommunicationUICalling.SnackBar.Button.Dismiss"
    case snackBarDismissAccessibilityLabel = "AzureCommunicationUICalling.SnackBar.Button.Dismiss.AccessibilityLabel"
    case snackBarDismissAccessibilityHint = "AzureCommunicationUICalling.SnackBar.Button.Dismiss.AccessibilityHint"
    case snackBarErrorJoinCall = "AzureCommunicationUICalling.SnackBar.Text.ErrorCallJoin"
    case snackBarErrorCallEnd = "AzureCommunicationUICalling.SnackBar.Text.ErrorCallEnd"
    case snackBarErrorCallEvicted = "AzureCommunicationUICalling.SnackBar.Text.ErrorCallEvicted"
    case snackBarError = "AzureCommunicationUICalling.SnackBar.Text.Error"
}
