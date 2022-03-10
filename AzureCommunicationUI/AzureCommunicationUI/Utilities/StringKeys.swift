//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

enum StringKey: String {
    /* Devices */
    case iOS = "AzureCommunicationUI.AudioDevice.DeviceDrawer.iOS"
    case speaker = "AzureCommunicationUI.AudioDevice.DeviceDrawer.Speaker"
    case iPhone = "AzureCommunicationUI.AudioDevice.DeviceDrawer.iPhone"
    case iPad = "AzureCommunicationUI.AudioDevice.DeviceDrawer.iPad"
    case headphones = "AzureCommunicationUI.AudioDevice.DeviceDrawer.Headphones"
    case bluetooth = "AzureCommunicationUI.AudioDevice.DeviceDrawer.Bluetooth"

    /* SetupView */
    case joinCall = "AzureCommunicationUI.SetupView.Button.JoinCall"
    case joiningCall = "AzureCommunicationUI.SetupView.Button.JoiningCall"
    case videoOff = "AzureCommunicationUI.SetupView.Button.VideoOff"
    case videoOn = "AzureCommunicationUI.SetupView.Button.VideoOn"
    case micOff = "AzureCommunicationUI.SetupView.Button.MicOff"
    case micOn = "AzureCommunicationUI.SetupView.Button.MicOn"
    case device = "AzureCommunicationUI.SetupView.Button.Device"
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
    case localeParticipant =
            "AzureCommunicationUI.CallingView.ParticipantDrawer.LocalParticipant"

    case leaveCall = "AzureCommunicationUI.CallingView.Overlay.LeaveCall"
    case cancel = "AzureCommunicationUI.CallingView.Overlay.Cancel"

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
    case bannerTitleRecordingAndTranscriptionStopped =
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
    case snackBarErrorJoinCall = "AzureCommunicationUI.SnackBar.Text.ErrorCallJoin"
    case snackBarErrorCallEnd = "AzureCommunicationUI.SnackBar.Text.ErrorCallEnd"
    case snackBarError = "AzureCommunicationUI.SnackBar.Text.Error"
}
