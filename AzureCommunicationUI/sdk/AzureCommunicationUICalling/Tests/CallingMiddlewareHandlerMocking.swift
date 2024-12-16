//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import AzureCommunicationUICalling

class CallingMiddlewareHandlerMocking: CallingMiddlewareHandling {
    var setupCallWasCalled: ((Bool) -> Void)?
    var startCallWasCalled: ((Bool) -> Void)?
    var endCallWasCalled: ((Bool) -> Void)?
    var enterBackgroundCalled: ((Bool) -> Void)?
    var enterForegroundCalled: ((Bool) -> Void)?
    var cameraPermissionSetCalled: ((Bool) -> Void)?
    var cameraPermissionGrantedCalled: ((Bool) -> Void)?
    var micPermissionGrantedCalled: ((Bool) -> Void)?
    var requestCameraPreviewOnCalled: ((Bool) -> Void)?
    var requestCameraOnCalled: ((Bool) -> Void)?
    var requestCameraOffCalled: ((Bool) -> Void)?
    var requestCameraSwitchCalled: ((Bool) -> Void)?
    var requestMicMuteCalled: ((Bool) -> Void)?
    var requestMicUnmuteCalled: ((Bool) -> Void)?
    var requestHoldCalled: ((Bool) -> Void)?
    var requestResumeCalled: ((Bool) -> Void)?
    var willTerminateCalled: ((Bool) -> Void)?
    var admitAllLobbyParticipants: ((Bool) -> Void)?
    var declineAllLobbyParticipants: ((Bool) -> Void)?
    var admitLobbyParticipant: ((Bool) -> Void)?
    var declineLobbyParticipant: ((Bool) -> Void)?
    var startCaptions: ((Bool) -> Void)?
    var stopCaptions: ((Bool) -> Void)?
    var setCaptionsSpokenLanguage: ((Bool) -> Void)?
    var setCaptionsLangue: ((Bool) -> Void)?
    var onNetworkQualityCallDiagnosticsUpdated: ((Bool) -> Void)?
    var onNetworkCallDiagnosticsUpdated: ((Bool) -> Void)?
    var onMediaCallDiagnosticsUpdated: ((Bool) -> Void)?
    var dismissNotification: ((Bool) -> Void)?
    var setCapabilities: ((Bool) -> Void)?
    var removeParticipant: ((Bool) -> Void)?
    var onCapabilitiesChanged: ((CapabilitiesChangedEvent) -> Void)?

    func setupCall(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            setupCallWasCalled?(true)
        }
    }

    func startCall(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            startCallWasCalled?(true)
        }
    }

    func endCall(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            endCallWasCalled?(true)
        }
    }

    func enterBackground(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            enterBackgroundCalled?(true)
        }
    }

    func enterForeground(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            enterForegroundCalled?(true)
        }
    }

    func onCameraPermissionIsSet(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            cameraPermissionSetCalled?(true)
        }
    }

    func cameraPermissionGranted(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            cameraPermissionGrantedCalled?(true)
        }
    }

    func onMicPermissionIsGranted(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            micPermissionGrantedCalled?(true)
        }
    }

    func requestCameraPreviewOn(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            requestCameraPreviewOnCalled?(true)
        }
    }

    func requestCameraOn(
        state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
            Task {
                requestCameraOnCalled?(true)
            }
        }

    func requestCameraOff(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            requestCameraOffCalled?(true)
        }
    }

    func requestCameraSwitch(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            requestCameraSwitchCalled?(true)
        }
    }

    func requestMicrophoneMute(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            requestMicMuteCalled?(true)
        }
    }

    func requestMicrophoneUnmute(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            requestMicUnmuteCalled?(true)
        }
    }

    func holdCall(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            requestHoldCalled?(true)
        }
    }

    func resumeCall(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            requestResumeCalled?(true)
        }
    }

    func audioSessionInterrupted(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {}
    }

    func willTerminate(state: AzureCommunicationUICalling.AppState, dispatch: @escaping AzureCommunicationUICalling.ActionDispatch) -> Task<Void, Never> {
        Task {
            willTerminateCalled?(true)
        }
    }

    func admitAllLobbyParticipants(state: AzureCommunicationUICalling.AppState, dispatch: @escaping AzureCommunicationUICalling.ActionDispatch) -> Task<Void, Never> {
        Task {
            admitAllLobbyParticipants?(true)
        }
    }

    func declineAllLobbyParticipants(state: AzureCommunicationUICalling.AppState, dispatch: @escaping AzureCommunicationUICalling.ActionDispatch) -> Task<Void, Never> {
        Task {
            declineAllLobbyParticipants?(true)
        }
    }

    func admitLobbyParticipant(state: AzureCommunicationUICalling.AppState, dispatch: @escaping AzureCommunicationUICalling.ActionDispatch, participantId: String) -> Task<Void, Never> {
        Task {
            admitLobbyParticipant?(true)
        }
    }

    func declineLobbyParticipant(state: AzureCommunicationUICalling.AppState, dispatch: @escaping AzureCommunicationUICalling.ActionDispatch, participantId: String) -> Task<Void, Never> {
        Task {
            declineLobbyParticipant?(true)
        }
    }

    func startCaptions(state: AzureCommunicationUICalling.AppState, dispatch: @escaping AzureCommunicationUICalling.ActionDispatch, language: String) -> Task<Void, Never> {
        Task {
            startCaptions?(true)
        }
    }

    func sendRttMessage(message: String, isFinal: Bool) -> Task<Void, Never> {
        Task {
            sendRttMessage(message: message, isFinal: isFinal)
        }
    }
    func stopCaptions(state: AzureCommunicationUICalling.AppState, dispatch: @escaping AzureCommunicationUICalling.ActionDispatch) -> Task<Void, Never> {
        Task {
            stopCaptions?(true)
        }
    }

    func setCaptionsSpokenLanguage(state: AzureCommunicationUICalling.AppState, dispatch: @escaping AzureCommunicationUICalling.ActionDispatch, language: String) -> Task<Void, Never> {
        Task {
            setCaptionsSpokenLanguage?(true)
        }
    }

    func setCaptionsLanguage(state: AzureCommunicationUICalling.AppState, dispatch: @escaping AzureCommunicationUICalling.ActionDispatch, language: String) -> Task<Void, Never> {
        Task {
            setCaptionsLangue?(true)
        }
    }

    func onNetworkQualityCallDiagnosticsUpdated(state: AzureCommunicationUICalling.AppState, dispatch: @escaping AzureCommunicationUICalling.ActionDispatch, diagnisticModel: AzureCommunicationUICalling.NetworkQualityDiagnosticModel) -> Task<Void, Never> {
        Task {
            onNetworkQualityCallDiagnosticsUpdated?(true)
        }
    }

    func onNetworkCallDiagnosticsUpdated(state: AzureCommunicationUICalling.AppState, dispatch: @escaping AzureCommunicationUICalling.ActionDispatch, diagnisticModel: AzureCommunicationUICalling.NetworkDiagnosticModel) -> Task<Void, Never> {
        Task {
            onNetworkCallDiagnosticsUpdated?(true)
        }
    }

    func onMediaCallDiagnosticsUpdated(state: AzureCommunicationUICalling.AppState, dispatch: @escaping AzureCommunicationUICalling.ActionDispatch, diagnisticModel: AzureCommunicationUICalling.MediaDiagnosticModel) -> Task<Void, Never> {
        Task {
            onMediaCallDiagnosticsUpdated?(true)
        }
    }

    func dismissNotification(state: AzureCommunicationUICalling.AppState, dispatch: @escaping AzureCommunicationUICalling.ActionDispatch) -> Task<Void, Never> {
        Task {
            dismissNotification?(true)
        }
    }

    func setCapabilities(capabilities: Set<AzureCommunicationUICalling.ParticipantCapabilityType>, state: AzureCommunicationUICalling.AppState, dispatch: @escaping AzureCommunicationUICalling.ActionDispatch) -> Task<Void, Never> {
        Task {
            setCapabilities?(true)
        }
    }

    func removeParticipant(state: AzureCommunicationUICalling.AppState, dispatch: @escaping AzureCommunicationUICalling.ActionDispatch, participantId: String) -> Task<Void, Never> {
        Task {
            removeParticipant?(true)
        }
    }

    func onCapabilitiesChanged(event: AzureCommunicationUICalling.CapabilitiesChangedEvent, state: AzureCommunicationUICalling.AppState, dispatch: @escaping AzureCommunicationUICalling.ActionDispatch) -> Task<Void, Never> {
        Task {
            onCapabilitiesChanged?(event)
        }
    }

    func recordingStateUpdated(state: AzureCommunicationUICalling.AppState, dispatch: @escaping AzureCommunicationUICalling.ActionDispatch, isRecordingActive: Bool) -> Task<Void, Never> {
        Task {}
    }

    func transcriptionStateUpdated(state: AzureCommunicationUICalling.AppState, dispatch: @escaping AzureCommunicationUICalling.ActionDispatch, isTranscriptionActive: Bool) -> Task<Void, Never> {
        Task {}
    }
}
