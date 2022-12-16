//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit

class FloatingUITestWindow: UIWindow {

    var callingSDKWrapperMock: UITestCallingSDKWrapper?
    var stackView: UIStackView!

    init() {
        super.init(frame: CGRect(x: 50, y: 50, width: 100, height: 100) )
    }

    override init(windowScene: UIWindowScene) {
        super.init(windowScene: windowScene)
        setupUIs()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUIs() {
        self.frame = CGRect(x: 0, y: 120, width: 100, height: 150)
        accessibilityIdentifier = "debugger_Window"
        backgroundColor = UIColor(white: 0, alpha: 0.7)
        stackView = UIStackView(arrangedSubviews: [])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.frame = self.bounds
        addSubview(stackView)
        createButton(title: "Hold",
                     accessibilityID: "callOnHold-AID",
                     selector: #selector(holdButtonTapped))
        createButton(title: "Resume",
                     accessibilityID: "callResume-AID",
                     selector: #selector(resumeButtonTapped))
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
    }

    private func createButton(title: String,
                              accessibilityID: String? = nil,
                              selector: Selector) {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12)
        button.frame = self.bounds
        button.accessibilityIdentifier = accessibilityID
        button.isAccessibilityElement = true
        button.addTarget(self, action: selector, for: .touchUpInside)
        // addSubview(button)
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
}
