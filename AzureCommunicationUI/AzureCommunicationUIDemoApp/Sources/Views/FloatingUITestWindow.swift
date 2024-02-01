//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit

#if DEBUG
@testable import AzureCommunicationUICalling
class FloatingUITestWindow: UIWindow {

    var callingSDKWrapperMock: UITestCallingSDKWrapper?
    var stackView: UIStackView!

    init() {
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        super.init(frame: keyWindow?.frame ?? .zero )
    }

    override init(windowScene: UIWindowScene) {
        super.init(windowScene: windowScene)
        setupUIs()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUIs() {
        backgroundColor = .clear
        accessibilityIdentifier = "debugger_Window"
        stackView = UIStackView(arrangedSubviews: [])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.backgroundColor = UIColor(white: 0, alpha: 0.7)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        createButton(title: "Hold",
                     accessibilityID: "callOnHold-AID",
                     selector: #selector(holdButtonTapped))
        createButton(title: "Transcription on",
                     accessibilityID: "callTranscriptionOn-AID",
                     selector: #selector(transcriptionOnButtonTapped))
        createButton(title: "Transcription off",
                     accessibilityID: "callTranscriptionOff-AID",
                     selector: #selector(transcriptionOffButtonTapped))
        createButton(title: "Recording on",
                     accessibilityID: "callRecordingOn-AID",
                     selector: #selector(recordingOnButtonTapped))
        createButton(title: "Recording off",
                     accessibilityID: "callRecordingOff-AID",
                     selector: #selector(recordingOffButtonTapped))
        createButton(title: "Add Participant",
                     accessibilityID: "callAddParticipant-AID",
                     selector: #selector(addParticipantButtonTapped))
        createButton(title: "Add InLobby Participant",
                     accessibilityID: "callAddInLobbyParticipant-AID",
                     selector: #selector(addInLobbyParticipantButtonTapped))
        createButton(title: "Remove Participant",
                     accessibilityID: "callRemoveParticipant-AID",
                     selector: #selector(removeParticipantButtonTapped))
        createButton(title: "Unmute Participant",
                     accessibilityID: "callUnmuteParticipant-AID",
                     selector: #selector(unmuteParticipantButtonTapped))
        createButton(title: "Hold Participant",
                     accessibilityID: "callHoldParticipant-AID",
                     selector: #selector(holdParticipantButtonTapped))
        createButton(title: "Change role to Presenter",
                     accessibilityID: "ChangeRoleToPresenter-AID",
                     selector: #selector(changeRoleToPresenterButtonTapped))
        createButton(title: "Change role to Attendee",
                     accessibilityID: "ChangeRoleToAttendee-AID",
                     selector: #selector(changeRoleToAttendeeButtonTapped))

        createButton(title: "Media Diag Bad",
                     accessibilityID: "emitMediaDiagnosticBad-AID",
                     selector: #selector(emitMediaCallDiagnosticBadState))
        createButton(title: "Media Diag Good",
                     accessibilityID: "emitMediaDiagnosticGood-AID",
                     selector: #selector(emitMediaCallDiagnosticGoodState))
        createButton(title: "Media Diagnostic",
                     accessibilityID: "changeMediaDiagnostic-AID",
                     selector: #selector(changeCurrentMediaDiagnostic))

        createButton(title: "Network Diag Bad",
                     accessibilityID: "emitNetworkDiagnosticBad-AID",
                     selector: #selector(emitNetworkCallDiagnosticBadState))
        createButton(title: "Network Diag Good",
                     accessibilityID: "emitNetworkDiagnosticGood-AID",
                     selector: #selector(emitNetworkCallDiagnosticGoodState))
        createButton(title: "Network Diagnostic",
                     accessibilityID: "changeNetworkDiagnostic-AID",
                     selector: #selector(changeCurrentNetworkDiagnostic))

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            stackView.widthAnchor.constraint(equalToConstant: 120.0),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 120),
            stackView.heightAnchor.constraint(equalToConstant: CGFloat(stackView.arrangedSubviews.count) * 20.0)
        ])
    }

    private func createButton(title: String,
                              accessibilityID: String? = nil,
                              selector: Selector) {
        // size will be updated when view is added to the stack view
        let button = UIButton(frame: .zero)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12)
        button.accessibilityIdentifier = accessibilityID
        button.addTarget(self, action: selector, for: .touchUpInside)
        stackView.addArrangedSubview(button)
    }

    @objc func holdButtonTapped(sender: UIButton) {
        debugPrint("UI Test:: holdButtonTapped")
        Task {
            try? await callingSDKWrapperMock?.holdCall()
        }
    }

    @objc func resumeButtonTapped(sender: UIButton) {
        debugPrint("UI Test:: resumeButtonTapped")
        Task {
            try? await callingSDKWrapperMock?.resumeCall()
        }
    }

    @objc func transcriptionOnButtonTapped(sender: UIButton) {
        debugPrint("UI Test:: transcriptionOnButtonTapped")
        Task {
            try? await callingSDKWrapperMock?.transcriptionOn()
        }
    }

    @objc func transcriptionOffButtonTapped(sender: UIButton) {
        debugPrint("UI Test:: transcriptionOffButtonTapped")
        Task {
            try? await callingSDKWrapperMock?.transcriptionOff()
        }
    }

    @objc func recordingOnButtonTapped(sender: UIButton) {
        debugPrint("UI Test:: recordingOnButtonTapped")
        Task {
            try? await callingSDKWrapperMock?.recordingOn()
        }
    }

    @objc func recordingOffButtonTapped(sender: UIButton) {
        debugPrint("UI Test:: recordingOffButtonTapped")
        Task {
            try? await callingSDKWrapperMock?.recordingOff()
        }
    }

    @objc func addParticipantButtonTapped(sender: UIButton) {
        debugPrint("UI Test:: AddParticipantButtonTapped")
        Task {
            try? await callingSDKWrapperMock?.addParticipant()
        }
    }

    @objc func addInLobbyParticipantButtonTapped(sender: UIButton) {
        debugPrint("UI Test:: AddParticipantButtonTapped")
        Task {
            try? await callingSDKWrapperMock?.addInLobbyParticipant()
        }
    }

    @objc func removeParticipantButtonTapped(sender: UIButton) {
        debugPrint("UI Test:: RemoveParticipantButtonTapped")
        Task {
            try? await callingSDKWrapperMock?.removeParticipant()
        }
    }

    @objc func unmuteParticipantButtonTapped(sender: UIButton) {
        debugPrint("UI Test:: ParticipantButtonTapped")
        Task {
            try? await callingSDKWrapperMock?.unmuteParticipant()
        }
    }

    @objc func holdParticipantButtonTapped(sender: UIButton) {
        debugPrint("UI Test:: HoldParticipantButtonTapped")
        Task {
            try? await callingSDKWrapperMock?.holdParticipant()
        }
    }

    @objc func changeRoleToPresenterButtonTapped(sender: UIButton) {
        debugPrint("UI Test:: ChangeRoleToPresenterButtonTapped")
        Task {
            try? await callingSDKWrapperMock?.changeLocalParticipantRole(.presenter)
        }
    }

    @objc func changeRoleToAttendeeButtonTapped(sender: UIButton) {
        debugPrint("UI Test:: ChangeRoleToAttendeeButtonTapped")
        Task {
            try? await callingSDKWrapperMock?.changeLocalParticipantRole(.attendee)
        }
    }

    @objc func emitMediaCallDiagnosticBadState(sender: UIButton) {
        debugPrint("UI Test:: emitMediaCallDiagnosticBadState")
        callingSDKWrapperMock?.emitMediaCallDiagnosticBadState()
    }

    @objc func emitMediaCallDiagnosticGoodState(sender: UIButton) {
        debugPrint("UI Test:: emitMediaCallDiagnosticGoodState")
        callingSDKWrapperMock?.emitMediaCallDiagnosticGoodState()
    }

    @objc func changeCurrentMediaDiagnostic(sender: UIButton) {
        debugPrint("UI Test:: changeCurrentMediaDiagnostic")
        callingSDKWrapperMock?.changeCurrentMediaDiagnostic()
    }

    @objc func emitNetworkCallDiagnosticBadState(sender: UIButton) {
        debugPrint("UI Test:: emitNetworkCallDiagnosticBadState")
        callingSDKWrapperMock?.emitNetworkCallDiagnosticBadState()
    }

    @objc func emitNetworkCallDiagnosticGoodState(sender: UIButton) {
        debugPrint("UI Test:: emitNetworkCallDiagnosticGoodState")
        callingSDKWrapperMock?.emitNetworkCallDiagnosticGoodState()
    }

    @objc func changeCurrentNetworkDiagnostic(sender: UIButton) {
        debugPrint("UI Test:: changeCurrentNetworkDiagnostic")
        callingSDKWrapperMock?.changeCurrentNetworkDiagnostic()
    }
}

extension FloatingUITestWindow {
    // pass taps through window if not in stack view
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)

        return (hitView == stackView || hitView?.superview == stackView) ? hitView : nil
    }
}
#endif
