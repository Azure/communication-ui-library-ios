//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import SwiftUI
import AzureCommunicationUI
import AzureCommunicationCalling

class UIKitDemoViewController: UIViewController {
    private var selectedAcsTokenType: ACSTokenType = .token
    private var acsTokenUrlTextField: UITextField!
    private var acsTokenTextField: UITextField!
    private var selectedMeetingType: MeetingType = .groupCall
    private var displayNameTextField: UITextField!
    private var groupCallTextField: UITextField!
    private var teamsMeetingTextField: UITextField!
    private var startExperienceButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    func didFail(_ error: ErrorEvent) {
        print("UIkitDemoView::getEventsHandler::didFail \(error)")
        print("UIkitDemoView error.code \(error.code)")
    }

    func startExperience(with link: String) {
        let callCompositeOptions = CallCompositeOptions(themeConfiguration: TeamsBrandConfig())

        let callComposite = CallComposite(withOptions: callCompositeOptions)

        callComposite.setTarget(didFail: didFail)

        if let communicationTokenCredential = try? getTokenCredential() {
            switch selectedMeetingType {
            case .groupCall:
                let uuid = UUID(uuidString: link) ?? UUID()
                let parameters = GroupCallOptions(communicationTokenCredential: communicationTokenCredential,
                                                  groupId: uuid,
                                                  displayName: getDisplayName())
                callComposite.launch(with: parameters)
            case .teamsMeeting:
                let parameters = TeamsMeetingOptions(communicationTokenCredential: communicationTokenCredential,
                                                     meetingLink: link,
                                                     displayName: getDisplayName())
                callComposite.launch(with: parameters)
            }
        } else {
            showError(for: DemoError.invalidToken.getErrorCode())
            return
        }
    }

    private func getTokenCredential() throws -> CommunicationTokenCredential {
        switch selectedAcsTokenType {
        case .token:
            if let communicationTokenCredential = try? CommunicationTokenCredential(token: acsTokenTextField.text!) {
                return communicationTokenCredential
            } else {
                throw DemoError.invalidToken
            }
        case .tokenUrl:
            if let url = URL(string: acsTokenUrlTextField.text!) {
                let communicationTokenRefreshOptions = CommunicationTokenRefreshOptions(initialToken: nil, refreshProactively: true, tokenRefresher: AuthenticationHelper.getCommunicationToken(tokenUrl: url))
                if let communicationTokenCredential = try? CommunicationTokenCredential(withOptions: communicationTokenRefreshOptions) {
                    return communicationTokenCredential
                }
            }
            throw DemoError.invalidToken
        }
    }

    private func getDisplayName() -> String {
        displayNameTextField.text ?? ""
    }

    private func getMeetingLink() -> String {
        switch selectedMeetingType {
        case .groupCall:
            return groupCallTextField.text ?? ""
        case .teamsMeeting:
            return teamsMeetingTextField.text ?? ""
        }
    }

    private func showError(for errorCode: String) {
        var errorMessage = ""
        switch errorCode {
        case CallCompositeErrorCode.tokenExpired:
            errorMessage = "Token is invalid"
        default:
            errorMessage = "Unknown error"
        }
        let errorAlert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        errorAlert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(errorAlert,
                animated: true,
                completion: nil)
    }

    @objc func onAcsTokenTypeValueChanged(_ sender: UISegmentedControl!) {
        selectedAcsTokenType = ACSTokenType(rawValue: sender.selectedSegmentIndex)!
        updateAcsTokenTypeFields()
    }
    @objc func onMeetingTypeValueChanged(_ sender: UISegmentedControl!) {
        selectedMeetingType = MeetingType(rawValue: sender.selectedSegmentIndex)!
        updateMeetingTypeFields()
    }

    @objc func textFieldEditingDidChange() {
        startExperienceButton.isEnabled = !isStartExperienceDisabled
        updateStartExperieceButton()
    }

    @objc func onStartExperienceBtnPressed() {
        let link = self.getMeetingLink()
        self.startExperience(with: link)
    }

    private func updateAcsTokenTypeFields() {
        switch selectedAcsTokenType {
        case .tokenUrl:
            acsTokenUrlTextField.isHidden = false
            acsTokenTextField.isHidden = true
        case .token:
            acsTokenUrlTextField.isHidden = true
            acsTokenTextField.isHidden = false
        }
    }

    private func updateMeetingTypeFields() {
        switch selectedMeetingType {
        case .groupCall:
            groupCallTextField.isHidden = false
            teamsMeetingTextField.isHidden = true
        case .teamsMeeting:
            groupCallTextField.isHidden = true
            teamsMeetingTextField.isHidden = false
        }
    }

    private func updateStartExperieceButton() {
        if isStartExperienceDisabled {
            startExperienceButton.backgroundColor = .systemGray3
        } else {
            startExperienceButton.backgroundColor = .systemBlue
        }
    }

    private var isStartExperienceDisabled: Bool {
        if (selectedAcsTokenType == .token && acsTokenTextField.text!.isEmpty)
            || (selectedAcsTokenType == .tokenUrl && acsTokenUrlTextField.text!.isEmpty)
            || (selectedMeetingType == .groupCall && groupCallTextField.text!.isEmpty)
            || (selectedMeetingType == .teamsMeeting && teamsMeetingTextField.text!.isEmpty) {
            return true
        }

        return false
    }

    private func setupUI() {
        let margin = CGFloat(18)
        let margins = view.safeAreaLayoutGuide

        view.backgroundColor = .white

        let titleLabel = UILabel()
        titleLabel.text = "UI Library - UIKit Sample"
        titleLabel.sizeToFit()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        let acsTokenTypeSegmentedControl = UISegmentedControl(items: ["Token URL", "Token"])
        acsTokenTypeSegmentedControl.selectedSegmentIndex = selectedAcsTokenType.rawValue
        acsTokenTypeSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        acsTokenTypeSegmentedControl.addTarget(self, action: #selector(onAcsTokenTypeValueChanged(_:)), for: .valueChanged)

        acsTokenUrlTextField = UITextField()
        acsTokenUrlTextField.placeholder = "ACS Token URL"
        acsTokenUrlTextField.text = EnvConfig.acsTokenUrl.value()
        acsTokenUrlTextField.delegate = self
        acsTokenUrlTextField.sizeToFit()
        acsTokenUrlTextField.translatesAutoresizingMaskIntoConstraints = false
        acsTokenUrlTextField.borderStyle = .roundedRect
        acsTokenUrlTextField.addTarget(self, action: #selector(textFieldEditingDidChange), for: .editingChanged)

        acsTokenTextField = UITextField()
        acsTokenTextField.placeholder = "ACS Token"
        acsTokenTextField.text = EnvConfig.acsToken.value()
        acsTokenTextField.delegate = self
        acsTokenTextField.sizeToFit()
        acsTokenTextField.translatesAutoresizingMaskIntoConstraints = false
        acsTokenTextField.borderStyle = .roundedRect
        acsTokenTextField.addTarget(self, action: #selector(textFieldEditingDidChange), for: .editingChanged)

        displayNameTextField = UITextField()
        displayNameTextField.placeholder = "Display Name"
        displayNameTextField.text = EnvConfig.displayName.value()
        displayNameTextField.translatesAutoresizingMaskIntoConstraints = false
        displayNameTextField.delegate = self
        displayNameTextField.borderStyle = .roundedRect
        displayNameTextField.addTarget(self, action: #selector(textFieldEditingDidChange), for: .editingChanged)

        let meetingTypeSegmentedControl = UISegmentedControl(items: ["Group Call", "Teams Meeting"])
        meetingTypeSegmentedControl.selectedSegmentIndex = MeetingType.groupCall.rawValue
        meetingTypeSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        meetingTypeSegmentedControl.addTarget(self, action: #selector(onMeetingTypeValueChanged(_:)), for: .valueChanged)

        groupCallTextField = UITextField()
        groupCallTextField.placeholder = "Group Call Id"
        groupCallTextField.text = EnvConfig.groupCallId.value()
        groupCallTextField.delegate = self
        groupCallTextField.sizeToFit()
        groupCallTextField.translatesAutoresizingMaskIntoConstraints = false
        groupCallTextField.borderStyle = .roundedRect
        groupCallTextField.addTarget(self, action: #selector(textFieldEditingDidChange), for: .editingChanged)

        teamsMeetingTextField = UITextField()
        teamsMeetingTextField.placeholder = "Teams Meeting Link"
        teamsMeetingTextField.text = EnvConfig.teamsMeetingLink.value()
        teamsMeetingTextField.delegate = self
        teamsMeetingTextField.sizeToFit()
        teamsMeetingTextField.translatesAutoresizingMaskIntoConstraints = false
        teamsMeetingTextField.borderStyle = .roundedRect
        teamsMeetingTextField.addTarget(self, action: #selector(textFieldEditingDidChange), for: .editingChanged)

        startExperienceButton = UIButton()
        startExperienceButton.backgroundColor = .systemBlue
        startExperienceButton.setTitleColor(UIColor.white, for: .normal)
        startExperienceButton.setTitleColor(UIColor.systemGray6, for: .disabled)
        startExperienceButton.contentEdgeInsets = UIEdgeInsets.init(top: 10, left: 20, bottom: 10, right: 20)
        startExperienceButton.layer.cornerRadius = 8
        startExperienceButton.setTitle("Start Experience", for: .normal)
        startExperienceButton.sizeToFit()
        startExperienceButton.translatesAutoresizingMaskIntoConstraints = false
        startExperienceButton.addTarget(self, action: #selector(onStartExperienceBtnPressed), for: .touchUpInside)
        view.addSubview(startExperienceButton)

        let stackView = UIStackView(arrangedSubviews: [acsTokenTypeSegmentedControl,
                                                       acsTokenUrlTextField,
                                                       acsTokenTextField,
                                                       displayNameTextField,
                                                       meetingTypeSegmentedControl,
                                                       groupCallTextField,
                                                       teamsMeetingTextField])
        stackView.spacing = margin
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

        let constraints = [
            titleLabel.centerXAnchor.constraint(equalTo: margins.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: margins.topAnchor, constant: margin),

            stackView.centerXAnchor.constraint(equalTo: margins.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: margins.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: margin),
            stackView.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -margin),

            startExperienceButton.centerXAnchor.constraint(equalTo: margins.centerXAnchor),
            startExperienceButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: margin)
        ]
        NSLayoutConstraint.activate(constraints)

        updateAcsTokenTypeFields()
        updateMeetingTypeFields()
        startExperienceButton.isEnabled = !isStartExperienceDisabled
        updateStartExperieceButton()
    }
}

extension UIKitDemoViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
