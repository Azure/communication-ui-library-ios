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
    case selected = "AzureCommunicationUICalling.AudioDevice.Drawer.Selected.AccessibilityLabel"

    /* SetupView */
    case setupTitle = "AzureCommunicationUICalling.SetupView.Title"
    case dismissAccessibilityLabel = "AzureCommunicationUICalling.SetupView.Button.Dismiss.AccessibilityLabel"
    case joinCall = "AzureCommunicationUICalling.SetupView.Button.JoinCall"
    case joiningCall = "AzureCommunicationUICalling.SetupView.Button.JoiningCall"
    case startCall = "AzureCommunicationUICalling.SetupView.Button.StartCall"
    case startingCall = "AzureCommunicationUICalling.SetupView.Button.StartingCall"
    case videoOff = "AzureCommunicationUICalling.SetupView.Button.VideoOff"
    case videoOffAccessibilityLabel = "AzureCommunicationUICalling.SetupView.Button.VideoOff.AccessibilityLabel"
    case videoOn = "AzureCommunicationUICalling.SetupView.Button.VideoOn"
    case videoOnAccessibilityLabel = "AzureCommunicationUICalling.SetupView.Button.VideoOn.AccessibilityLabel"
    case micOff = "AzureCommunicationUICalling.SetupView.Button.MicOff"
    case micOffAccessibilityLabel = "AzureCommunicationUICalling.SetupView.Button.MicOff.AccessibilityLabel"
    case micOn = "AzureCommunicationUICalling.SetupView.Button.MicOn"
    case micOnAccessibilityLabel = "AzureCommunicationUICalling.SetupView.Button.MicOn.AccessibilityLabel"
    case device = "AzureCommunicationUICalling.SetupView.Button.Device"
    case deviceAccesibiiltyLabel = "AzureCommunicationUICalling.SetupView.Button.Device.AccessibilityLabel"
    case joinCallDiableStateAccessibilityLabel =
            "AzureCommunicationUICalling.SetupView.Button.JoinCall.DisableState.AccessibilityLabel"
    case startCallDiableStateAccessibilityLabel =
            "AzureCommunicationUICalling.SetupView.Button.StartCall.DisableState.AccessibilityLabel"
    case goToSettings = "AzureCommunicationUICalling.SetupView.Button.GoToSettings"
    case cameraDisabled = "AzureCommunicationUICalling.SetupView.PreviewArea.AudioGrantedCameraDisabled"
    case audioAndCameraDisabled = "AzureCommunicationUICalling.SetupView.PreviewArea.AudioDisabledCameraDenied"
    case audioDisabled = "AzureCommunicationUICalling.SetupView.PreviewArea.AudioDisabled"

    /* LobbyView */
    case waitingForHost = "AzureCommunicationUICalling.LobbyView.Text.WaitingForHost"
    case waitingDetails = "AzureCommunicationUICalling.LobbyView.Text.WaitingDetails"

    /* OnHoldView */
    case onHoldMessage = "AzureCommunicationUICalling.OnHoldView.Text.OnHold"
    case resume = "AzureCommunicationUICalling.OnHoldView.Button.Resume"
    case resumeAccessibilityLabel = "AzureCommunicationUICalling.OnHoldView.Button.Resume.AccessibilityLabel"

    /* CallingView */
    case callWith0Person = "AzureCommunicationUICalling.CallingView.InfoHeader.WaitingForOthersToJoin"
    case callWith1Person = "AzureCommunicationUICalling.CallingView.InfoHeader.CallWith1Person"
    // %d is for number of people in call
    case callWithNPerson = "AzureCommunicationUICalling.CallingView.InfoHeader.CallWithNPeople"
    case participantListAccessibilityLabel =
            "AzureCommunicationUICalling.CallingView.InfoHeader.ParticipantList.AccessibilityLabel"
    case callingCallMessage = "AzureCommunicationUICalling.CallingView.GridView.Calling"

    /* Lobby waiting */
    case lobbyWaitingToJoin = "AzureCommunicationUICalling.CallingView.LobbyWaitingHeader.LobbyWaitingToJoin"
    case lobbyWaitingHeaderViewButton =
            "AzureCommunicationUICalling.CallingView.LobbyWaitingHeader.ViewButton"
    case lobbyWaitingHeaderViewButtonAccessibilityLabel =
            "AzureCommunicationUICalling.CallingView.LobbyWaitingHeader.ViewButton.AccessibilityLabel"
    case lobbyWaitingHeaderDismissButtonAccessibilityLabel =
            "AzureCommunicationUICalling.CallingView.LobbyWaitingHeader.DismissButton.AccessibilityLabel"

    /* Lobby waiting error */
    case lobbyActionErrorConversationTypeNotSupported =
            "AzureCommunicationUICalling.CallingView.LobbyActionError.ConversationTypeNotSupported"
    case lobbyActionErrorLobbyDisabledByConfigurations =
            "AzureCommunicationUICalling.CallingView.LobbyActionError.DisabledByConfigurations"
    case lobbyActionErrorMeetingRoleNotAllowed =
            "AzureCommunicationUICalling.CallingView.LobbyActionError.RoleNotAllowed"
    case lobbyActionErrorParticipantOperationFailure =
            "AzureCommunicationUICalling.CallingView.LobbyActionError.ParticipantOperationFailure"
    case lobbyActionUnknownError = "AzureCommunicationUICalling.CallingView.LobbyActionError.UnknownError"

    case lobbyActionErrorDismiss = "AzureCommunicationUICalling.CallingView.LobbyActionError.Dismiss.AccessibilityLabel"

    case unnamedParticipant = "AzureCommunicationUICalling.CallingView.ParticipantDrawer.Unnamed"
    // %@ is local participant name
    case localeParticipantWithSuffix =
            "AzureCommunicationUICalling.CallingView.ParticipantDrawer.LocalParticipant"
    case muted = "AzureCommunicationUICalling.CallingView.ParticipantDrawer.IsMuted"
    case unmuted = "AzureCommunicationUICalling.CallingView.ParticipantDrawer.IsUnmuted"
    case speaking = "AzureCommunicationUICalling.CallingView.ParticipantDrawer.IsSpeaking"
    case onHold = "AzureCommunicationUICalling.CallingView.ParticipantDrawer.OnHold"
    case onHoldAccessibilityLabel =
            "AzureCommunicationUICalling.CallingView.ParticipantDrawer.OnHold.AccessibilityLabel"
    case participantResumeAccessibilityLabel =
            "AzureCommunicationUICalling.CallingView.ParticipantDrawer.Resume.AccessibilityLabel"
    case participantListLobbyAction = "AzureCommunicationUICalling.CallingView.ParticipantDrawer.LobbyAction"
    case participantListWaitingInLobby = "AzureCommunicationUICalling.CallingView.ParticipantDrawer.WaitingInLobby"
    case participantListInTheCall = "AzureCommunicationUICalling.CallingView.ParticipantDrawer.InTheCall"
    case participantListAdmitAll = "AzureCommunicationUICalling.CallingView.ParticipantDrawer.AdmitAll"
    case participantListConfirmTitleAdmitAll =
            "AzureCommunicationUICalling.CallingView.ParticipantDrawer.Confirm.Title.AdmitAll"
    case participantListConfirmTitleAdmitParticipant =
            "AzureCommunicationUICalling.CallingView.ParticipantDrawer.Confirm.Title.AdmitParticipant"
    case participantListConfirmAdmit = "AzureCommunicationUICalling.CallingView.ParticipantDrawer.Confirm.Admit"
    case participantListConfirmDecline = "AzureCommunicationUICalling.CallingView.ParticipantDrawer.Confirm.Decline"
    case participantListPlusMore = "AzureCommunicationUICalling.CallingView.ParticipantDrawer.PlusMore"

    case frontCamera = "AzureCommunicationUICalling.CallingView.SwitchCamera.Front"
    case backCamera = "AzureCommunicationUICalling.CallingView.SwitchCamera.Back"

    case onePersonJoined = "AzureCommunicationUICalling.CallingView.OnePersonJoined"
    case multiplePeopleJoined = "AzureCommunicationUICalling.CallingView.MutiplePeopleJoined"
    case onePersonLeft = "AzureCommunicationUICalling.CallingView.OnePersonLeft"
    case multiplePeopleLeft = "AzureCommunicationUICalling.CallingView.MutiplePeopleLeft"
    case participantInformationAccessibilityLable =
            "AzureCommunicationUICalling.CallingView.ParticipantInformation.AccessibilityLabel"
    case joinedCallAccessibilityLabel =
            "AzureCommunicationUICalling.CallingView.JoinedCall.AccessibilityLabel"
    case screenshareStartAccessibilityLabel =
            "AzureCommunicationUICalling.CallingView.ScreenShareStart.AccessibilityLabel"
    case screenshareEndAccessibilityLabel =
            "AzureCommunicationUICalling.CallingView.ScreenShareEnd.AccessibilityLabel"

    case leaveCallListHeader = "AzureCommunicationUICalling.CallingView.LeaveCallList.Header.LeaveCall"
    case leaveCall = "AzureCommunicationUICalling.CallingView.Overlay.LeaveCall"
    case cancel = "AzureCommunicationUICalling.CallingView.Overlay.Cancel"

    case moreAccessibilityLabel = "AzureCommunicationUICalling.CallingView.Button.More.AccessibilityLabel"
    case shareDiagnosticsInfo = "AzureCommunicationUICalling.CallingView.MoreCallOptionsList.ShareDiagnosticsInfo"
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
    case snackBarErrorOnHoldTitle = "AzureCommunicationUICalling.SnackBar.Text.ErrorResumeCallTitle"
    case snackBarErrorOnHoldSubtitle = "AzureCommunicationUICalling.SnackBar.Text.ErrorResumeCallSubTitle"
    case snackBarErrorCallDenied =
            "AzureCommunicationUICalling.SnackBar.Text.ErrorCallDenied"
    case snackBarErrorCameraOnFailed = "AzureCommunicationUICalling.SnackBar.Text.CameraOnFailed"
    case snackBarErrorConnectionError =
            "AzureCommunicationUICalling.SnackBar.Text.ConnectionError"

    /* Call Diagnostics */
    case callDiagnosticsUserMuted = "AzureCommunicationUICalling.Diagnostics.Text.YouAreMuted"
    case callDiagnosticsNetworkQualityLow = "AzureCommunicationUICalling.Diagnostics.Text.NetworkQualityLow"
    case callDiagnosticsNetworkLost = "AzureCommunicationUICalling.Diagnostics.Text.NetworkLost"
    case callDiagnosticsNetworkReconnect = "AzureCommunicationUICalling.Diagnostics.Text.NetworkReconnect"
    case callDiagnosticsCameraNotWorking = "AzureCommunicationUICalling.Diagnostics.Text.CameraNotStarted"
    case callDiagnosticsUnableToLocateSpeaker = "AzureCommunicationUICalling.Diagnostics.Text.UnableToLocateSpeaker"
    case callDiagnosticsUnableToLocateMicrophone =
            "AzureCommunicationUICalling.Diagnostics.Text.UnableToLocateMicrophone"
    case callDiagnosticsMicrophoneNotWorking = "AzureCommunicationUICalling.Diagnostics.Text.MicrophoneNotWorking"
    case callDiagnosticsSpeakerNotWorking = "AzureCommunicationUICalling.Diagnostics.Text.SpeakerNotWorking"
    case callDiagnosticsSpeakerMuted = "AzureCommunicationUICalling.Diagnostics.Text.SpeakerMuted"

    case callDiagnosticsDismissAccessibilityLabel =
            "AzureCommunicationUICalling.Diagnostics.Button.Dismiss.AccessibilityLabel"
    case callDiagnosticsDismissAccessibilityHint =
            "AzureCommunicationUICalling.Diagnostics.Button.Dismiss.AccessibilityHint"

    /* Support Form */
    case supportFormReportIssueTitle = "AzureCommunicationUICalling.ReportIssue.Title"
    case supportFormLogsAttachNotice = "AzureCommunicationUICalling.LogsAttach.Notice"
    case supportFormPrivacyPolicyText = "AzureCommunicationUICalling.PrivacyPolicy.Text"
    case supportFormDescribeYourIssueHintText = "AzureCommunicationUICalling.DescribeYourIssueHint.Text"
    case supportFormCancelButtonText = "AzureCommunicationUICalling.CancelButton.Text"
    case supportFormAttachScreenshot = "AzureCommunicationUICalling.Attach.Screenshot"
    case supportFormReportAProblemText = "AzureCommunicationUICalling.ReportAProblem.Text"
    case supportFormSendFeedbackText = "AzureCommunicationUICalling.SendFeedback.Text"

    /* Captions */
    case captionsListTitle = "AzureCommunicationUICalling.Captions.Text.LiveCaptions"
    case captionsSpokenLanguage = "AzureCommunicationUICalling.Captions.Text.SpokenLanguage"
    case captionsCaptionLanguage = "AzureCommunicationUICalling.Captions.Text.CaptionLanguage"
    case captionsStartingCaptions = "AzureCommunicationUICalling.Captions.Text.StartingCaptions"
    case captionsStartCaptionsError = "AzureCommunicationUICalling.Captions.ActionError.StartCaptions"
    case captionsStopCaptionsError = "AzureCommunicationUICalling.Captions.ActionError.StopCaptions"
    case captionsChangeCaptionsLanguageError = "AzureCommunicationUICalling.Captions.ActionError.ChangeCaptionsLanguage"
    case captionsChangeSpokenLanguageError = "AzureCommunicationUICalling.Captions.ActionError.ChangeSpokenLanguage"
    case captionsTurnOnCaptions = "AzureCommunicationUICalling.Captions.Text.TurnOnCaptions"
    case captionsTurnOffCaptions = "AzureCommunicationUICalling.Captions.Text.TurnOffCaptions"

    /* RTT */
    case rttCaptionsListTitle = "AzureCommunicationUICalling.Captions.Text.LiveCaptionsAndRTT"
    case rttListTitle = "AzureCommunicationUICalling.RTT.Title.RTT"
    case rttTurnOn = "AzureCommunicationUICalling.RTT.TurnOn.Text"
    case rttAlertTitle = "AzureCommunicationUICalling.RTT.Alert.Title"
    case rttAlertMessage = "AzureCommunicationUICalling.RTT.Alert.Message"
    case rttAlertTurnOn = "AzureCommunicationUICalling.RTT.Alert.TurnOn"
    case rttAlertDismiss = "AzureCommunicationUICalling.RTT.Alert.Dismiss"
    case rttWarningMessage = "AzureCommunicationUICalling.RTT.WarningMessage.Text"
    case rttTextBoxHint = "AzureCommunicationUICalling.RTT.TextBox.Hint"
    case rttTyping = "AzureCommunicationUICalling.RTT.Text.RTTTyping"
    case rttLabel = "AzureCommunicationUICalling.RTT.RTTLable"
    case rttLinkLearnMore = "AzureCommunicationUICalling.RTT.WarningMessage.LearnMore"
    case maximizeCaptionsRtt = "AzureCommunicationUICalling.RTT.Maximize.CaptionsRTT"
    case minimizeCaptionsRtt = "AzureCommunicationUICalling.RTT.Minimize.CaptionsRTT"

    /* Remote participant menu */
    case callingViewParticipantMenuMute = "AzureCommunicationUICalling.CallingView.ParticipantMenu.Mute"
    case callingViewParticipantMenuMuteAccessibilityLabel =
            "AzureCommunicationUICalling.CallingView.ParticipantMenu.Mute.AccessibilityLabel"
    case callingViewParticipantMenuRemove = "AzureCommunicationUICalling.CallingView.ParticipantMenu.Remove"
    case callingViewParticipantMenuRemoveAccessibilityLabel =
            "AzureCommunicationUICalling.CallingView.ParticipantMenu.Remove.AccessibilityLabel"
    case callingViewToastFeaturesLost = "AzureCommunicationUICalling.CallingView.Toast.FeaturesLost"
    case callingViewToastFeaturesGained = "AzureCommunicationUICalling.CallingView.Toast.FeaturesGained"
}
