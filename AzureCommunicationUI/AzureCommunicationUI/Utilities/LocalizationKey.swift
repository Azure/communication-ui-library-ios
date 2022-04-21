//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

enum LocalizationKey: String {
    /* Devices */
    case iOS = "AzureCommunicationUI.AudioDevice.DeviceDrawer.iOS"
    case speaker = "AzureCommunicationUI.AudioDevice.DeviceDrawer.Speaker"
    case iPhone = "AzureCommunicationUI.AudioDevice.DeviceDrawer.iPhone"
    case iPad = "AzureCommunicationUI.AudioDevice.DeviceDrawer.iPad"
    case headphones = "AzureCommunicationUI.AudioDevice.DeviceDrawer.Headphones"
    case bluetooth = "AzureCommunicationUI.AudioDevice.DeviceDrawer.Bluetooth"

    /* DemoView */
    case startExperience = "AzureCommunicationUI.DemoView.StartExperience"
    case startExperienceAccessibilityLabel = "AzureCommunicationUI.DemoView.StartExperience.AccessibilityLabel"
    case clearTokenTextFieldAccessibilityLabel = "AzureCommunicationUI.DemoView.ClearTokenTextField.AccessibilityLabel"

    /* SetupView */
    case setupTitle = "AzureCommunicationUI.SetupView.Title"
    case dismissAccessibilityLabel = "AzureCommunicationUI.SetupView.Button.Dismiss.AccessibilityLabel"
    case joinCall = "AzureCommunicationUI.SetupView.Button.JoinCall"
    case joinCallAccessibilityLabel = "AzureCommunicationUI.SetupView.Button.JoinCall.AccessibilityLabel"
    case joiningCall = "AzureCommunicationUI.SetupView.Button.JoiningCall"
    case videoOff = "AzureCommunicationUI.SetupView.Button.VideoOff"
    case videoOffAccessibilityLabel = "AzureCommunicationUI.SetupView.Button.VideoOff.AccessibilityLabel"
    case videoOn = "AzureCommunicationUI.SetupView.Button.VideoOn"
    case videoOnAccessibilityLabel = "AzureCommunicationUI.SetupView.Button.VideoOn.AccessibilityLabel"
    case toggleVideoAccessibilityID = "AzureCommunicationUI.SetupView.Button.Video.AccessibilityID"
    case micOff = "AzureCommunicationUI.SetupView.Button.MicOff"
    case micOffAccessibilityLabel = "AzureCommunicationUI.SetupView.Button.MicOff.AccessibilityLabel"
    case micOn = "AzureCommunicationUI.SetupView.Button.MicOn"
    case micOnAccessibilityLabel = "AzureCommunicationUI.SetupView.Button.MicOn.AccessibilityLabel"
    case togglMicAccessibilityID = "AzureCommunicationUI.SetupView.Button.Mic.AccessibilityID"
    case device = "AzureCommunicationUI.SetupView.Button.Device"
    case deviceAccesibiiltyLabel = "AzureCommunicationUI.SetupView.Button.Device.AccessibilityLabel"
    case cameraDisabled = "AzureCommunicationUI.SetupView.PreviewArea.AudioGrantedCameraDisabled"
    case audioAndCameraDisabled = "AzureCommunicationUI.SetupView.PreviewArea.AudioDisabledCameraDenied"
    case audioDisabled = "AzureCommunicationUI.SetupView.PreviewArea.AudioDisabled"

    /* LobbyView */
    case waitingForHost = "AzureCommunicationUI.LobbyView.Text.WaitingForHost"
    case waitingDetails = "AzureCommunicationUI.LobbyView.Text.WaitingDetails"

    /* CallingView */
    case callWith0Person = "AzureCommunicationUI.CallingView.InfoHeader.WaitingForOthersToJoin"
    case callWith1Person = "AzureCommunicationUI.CallingView.InfoHeader.CallWith1Person"
    // %d is for number of people in call
    case callWithNPerson = "AzureCommunicationUI.CallingView.InfoHeader.CallWithNPeople"

    case unnamedParticipant = "AzureCommunicationUI.CallingView.ParticipantDrawer.Unnamed"
    // %@ is local participant name
    case localeParticipantWithSuffix =
            "AzureCommunicationUI.CallingView.ParticipantDrawer.LocalParticipant"
    case muted = "AzureCommunicationUI.CallingView.ParticipantDrawer.IsMuted"
    case unmuted = "AzureCommunicationUI.CallingView.ParticipantDrawer.IsUnmuted"

    case frontCamera = "AzureCommunicationUI.CallingView.SwitchCamera.Front"
    case backCamera = "AzureCommunicationUI.CallingView.SwitchCamera.Back"

    case onePersonJoined = "AzureCommunicationUI.CallingView.OnePersonJoined"
    case multiplePeopleJoined = "AzureCommunicationUI.CallingView.MutiplePeopleJoined"
    case onePersonLeft = "AzureCommunicationUI.CallingView.OnePersonLeft"
    case multiplePeopleLeft = "AzureCommunicationUI.CallingView.MutiplePeopleLeft"

    case videoAccessibilityLabel = "AzureCommunicationUI.CallingView.ControlButton.Video.AccessibilityLabel"
    case micAccessibilityLabel = "AzureCommunicationUI.CallingView.ControlButton.Microphone.AccessibilityLabel"
    case audioDeviceAccessibilityLabel = "AzureCommunicationUI.CallingView.ControlButton.AudioDevice.AccessibilityLabel"
    case hangupAccessibilityLabel = "AzureCommunicationUI.CallingView.ControlButton.HangUp.AccessibilityLabel"

    case leaveCallListHeader = "AzureCommunicationUI.CallingView.LeaveCallList.Header.LeaveCall"
    case leaveCall = "AzureCommunicationUI.CallingView.Overlay.LeaveCall"
    case cancel = "AzureCommunicationUI.CallingView.Overlay.Cancel"
    case cancelAccssibilityLabel = "AzureCommunicationUI.CallingView.Overlay.Cancel.AccssibilityLabel"

    /* ComplianceBanner title */
    case bannerTitleRecordingAndTranscriptionStarted =
            "AzureCommunicationUI.CallingView.BannerTitle.RecordingAndTranscribingStarted"
    case bannerTitleReordingStarted =
            "AzureCommunicationUI.CallingView.BannerTitle.RecordingStarted"
    case bannerTitleTranscriptionStoppedStillRecording =
            "AzureCommunicationUI.CallingView.BannerTitle.TranscriptionStoppedStillRecording"
    case bannerTitleTranscriptionStarted =
            "AzureCommunicationUI.CallingView.BannerTitle.TranscriptionStarted"
    case bannerTitleTranscriptionStopped =
            "AzureCommunicationUI.CallingView.BannerTitle.TranscriptionStopped"
    case bannerTitleRecordingStoppedStillTranscribing =
            "AzureCommunicationUI.CallingView.BannerTitle.RecordingStoppedStillTranscribing"
    case bannerTitleRecordingStopped =
            "AzureCommunicationUI.CallingView.BannerTitle.RecordingStopped"
    case bannerTitleRecordingAndTranscribingStopped =
            "AzureCommunicationUI.CallingView.BannerTitle.RecordingAndTranscribingStopped"

    /* ComplianceBanner body */
    case bannerBodyConsent = "AzureCommunicationUI.CallingView.BannerBody.Consent"
    case bannerBodyRecording = "AzureCommunicationUI.CallingView.BannerBody.Recording"
    case bannerBodyTranscriptionStopped = "AzureCommunicationUI.CallingView.BannerBody.TranscriptionStopped"
    case bannerBodyOnlyTranscribing = "AzureCommunicationUI.CallingView.BannerBody.OnlyTranscribing"
    case bannerBodyRecordingStopped = "AzureCommunicationUI.CallingView.BannerBody.RecordingStopped"
    case bannerBodyRecordingAndTranscriptionStopped =
            "AzureCommunicationUI.CallingView.BannerBody.RecordingAndTranscriptionStopped"

    /* ComplianceBanner display link */
    case bannerDisplayLinkPrivacyPolicy = "AzureCommunicationUI.CallingView.BannerLink.PrivacyPolicy"
    case bannerDisplayLinkLearnMore = "AzureCommunicationUI.CallingView.BannerLink.LearnMore"

    /* PopUp warning */
    case snackBarDismiss = "AzureCommunicationUI.SnackBar.Button.Dismiss"
    case snackBarDismissAccessibilityLabel = "AzureCommunicationUI.SnackBar.Button.Dismiss.AccessibilityLabel"
    case snackBarDismissAccessibilityHint = "AzureCommunicationUI.SnackBar.Button.Dismiss.AccessibilityHint"
    case snackBarErrorJoinCall = "AzureCommunicationUI.SnackBar.Text.ErrorCallJoin"
    case snackBarErrorCallEnd = "AzureCommunicationUI.SnackBar.Text.ErrorCallEnd"
    case snackBarError = "AzureCommunicationUI.SnackBar.Text.Error"
}
