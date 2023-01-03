//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit

#if DEBUG
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
        createButton(title: "Remove Participant",
                     accessibilityID: "callRemoveParticipant-AID",
                     selector: #selector(removeParticipantButtonTapped))
        createButton(title: "Unmute Participant",
                     accessibilityID: "callUnmuteParticipant-AID",
                     selector: #selector(unmuteParticipantButtonTapped))
        createButton(title: "Hold Participant",
                     accessibilityID: "callHoldParticipant-AID",
                     selector: #selector(holdParticipantButtonTapped))

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
            do {
                try await callingSDKWrapperMock?.holdCall()
            } catch {
            }
        }
    }

    @objc func resumeButtonTapped(sender: UIButton) {
        debugPrint("UI Test:: resumeButtonTapped")
        Task {
            do {
                try await callingSDKWrapperMock?.resumeCall()
            } catch {
            }
        }
    }

    @objc func transcriptionOnButtonTapped(sender: UIButton) {
        debugPrint("UI Test:: transcriptionOnButtonTapped")
        Task {
            do {
                try await callingSDKWrapperMock?.transcriptionOn()
            } catch {
            }
        }
    }

    @objc func transcriptionOffButtonTapped(sender: UIButton) {
        debugPrint("UI Test:: transcriptionOffButtonTapped")
        Task {
            do {
                try await callingSDKWrapperMock?.transcriptionOff()
            } catch {
            }
        }
    }

    @objc func recordingOnButtonTapped(sender: UIButton) {
        debugPrint("UI Test:: recordingOnButtonTapped")
        Task {
            do {
                try await callingSDKWrapperMock?.recordingOn()
            } catch {
            }
        }
    }

    @objc func recordingOffButtonTapped(sender: UIButton) {
        debugPrint("UI Test:: recordingOffButtonTapped")
        Task {
            do {
                try await callingSDKWrapperMock?.recordingOff()
            } catch {
            }
        }
    }

    @objc func addParticipantButtonTapped(sender: UIButton) {
        debugPrint("UI Test:: AddParticipantButtonTapped")
        Task {
            do {
                try await callingSDKWrapperMock?.addParticipant()
            } catch {
            }
        }
    }

    @objc func removeParticipantButtonTapped(sender: UIButton) {
        debugPrint("UI Test:: RemoveParticipantButtonTapped")
        Task {
            do {
                try await callingSDKWrapperMock?.removeParticipant()
            } catch {
            }
        }
    }

    @objc func unmuteParticipantButtonTapped(sender: UIButton) {
        debugPrint("UI Test:: ParticipantButtonTapped")
        Task {
            do {
                try await callingSDKWrapperMock?.unmuteParticipant()
            } catch {
            }
        }
    }

    @objc func holdParticipantButtonTapped(sender: UIButton) {
        debugPrint("UI Test:: HoldParticipantButtonTapped")
        Task {
            do {
                try await callingSDKWrapperMock?.holdParticipant()
            } catch {
            }
        }
    }
}

extension FloatingUITestWindow {
    // pass taps through window if not in stack view
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)

        return (hitView == stackView || hitView?.superview == stackView) ? hitView : nil
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
