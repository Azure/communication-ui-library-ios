//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import Combine
import SwiftUI
import AzureCommunicationUI
import AzureCommunicationCalling

class UIKitDemoViewController: UIViewController {

    struct Constants {
        static let viewVerticalSpacing: CGFloat = 8.0
        static let stackViewInterItemSpacingPortrait: CGFloat = 18.0
        static let stackViewInterItemSpacingLandscape: CGFloat = 12.0
        static let buttonHorizontalInset: CGFloat = 20.0
        static let buttonVerticalInset: CGFloat = 10.0
    }

    private var selectedAcsTokenType: ACSTokenType = .token
    private var acsTokenUrlTextField: UITextField!
    private var acsTokenTextField: UITextField!
    private var selectedMeetingType: MeetingType = .groupCall
    private var displayNameTextField: UITextField!
    private var groupCallTextField: UITextField!
    private var teamsMeetingTextField: UITextField!
    private var startExperienceButton: UIButton!
    private var acsTokenTypeSegmentedControl: UISegmentedControl!
    private var meetingTypeSegmentedControl: UISegmentedControl!
    private var stackView: UIStackView!
    private var titleLabel: UILabel!
    private var titleLabelConstraint: NSLayoutConstraint!

    // The space needed to fill the top part of the stack view,
    // in order to make the stackview content centered
    private var spaceToFullInStackView: CGFloat?
    private var userIsEditing: Bool = false
    private var isKeyboardShowing: Bool = false

    private var cancellable = Set<AnyCancellable>()
    private var envConfigSubject: EnvConfigSubject

    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        return view
    }()

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateUIBasedOnUserInterfaceStyle()

        if UIDevice.current.orientation.isPortrait {
            stackView.spacing = Constants.stackViewInterItemSpacingPortrait
            titleLabelConstraint.constant = 32
        } else if UIDevice.current.orientation.isLandscape {
            stackView.spacing = Constants.stackViewInterItemSpacingLandscape
            titleLabelConstraint.constant = 16.0
        }
    }

    init(envConfigSubject: EnvConfigSubject) {
        self.envConfigSubject = envConfigSubject
        super.init(nibName: nil, bundle: nil)
        self.combineEnvConfigSubject()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        registerNotifications()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        guard !userIsEditing else {
            return
        }
        scrollView.setNeedsLayout()
        scrollView.layoutIfNeeded()
        let emptySpace = stackView.customSpacing(after: stackView.arrangedSubviews.first!)
        let spaceToFill = (scrollView.frame.height - (stackView.frame.height - emptySpace)) / 2
        stackView.setCustomSpacing(spaceToFill + Constants.viewVerticalSpacing,
                                   after: stackView.arrangedSubviews.first!)
    }

    func combineEnvConfigSubject() {
        envConfigSubject.objectWillChange
            .throttle(for: 0.5, scheduler: DispatchQueue.main, latest: true).sink(receiveValue: { [weak self] _ in
                self?.updateFromEnvConfig()
            }).store(in: &cancellable)
    }

    func updateFromEnvConfig() {
        if !envConfigSubject.acsToken.isEmpty {
            acsTokenTextField.text = envConfigSubject.acsToken
            acsTokenTypeSegmentedControl.selectedSegmentIndex = 2
        }
        if !envConfigSubject.displayName.isEmpty {
            displayNameTextField.text = envConfigSubject.displayName
        }

        if !envConfigSubject.groupCallId.isEmpty {
            groupCallTextField.text = envConfigSubject.groupCallId
            meetingTypeSegmentedControl.selectedSegmentIndex = 1
        }

        if !envConfigSubject.teamsMeetingLink.isEmpty {
            teamsMeetingTextField.text = envConfigSubject.teamsMeetingLink
            meetingTypeSegmentedControl.selectedSegmentIndex = 2
        }
    }

    func didFail(_ error: ErrorEvent) {
        print("::::UIkitDemoView::getEventsHandler::didFail \(error)")
        print("::::UIkitDemoView error.code \(error.code)")
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
                let tokenRefresher = AuthenticationHelper.getCommunicationToken(tokenUrl: url)
                let refreshOptions = CommunicationTokenRefreshOptions(initialToken: nil, refreshProactively: true,
                                                                                        tokenRefresher: tokenRefresher)
                if let credential = try? CommunicationTokenCredential(withOptions: refreshOptions) {
                    return credential
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

    private func registerNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(keyboardWillHide),
                                       name: UIResponder.keyboardWillHideNotification,
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(keyboardWillShow),
                                       name: UIResponder.keyboardWillShowNotification,
                                       object: nil)
    }

    private func updateUIBasedOnUserInterfaceStyle() {
        if UITraitCollection.current.userInterfaceStyle == .dark {
            view.backgroundColor = .black
        } else {
            view.backgroundColor = .white
        }
    }

    @objc func onAcsTokenTypeValueChanged(_ sender: UISegmentedControl!) {
        selectedAcsTokenType = ACSTokenType(rawValue: sender.selectedSegmentIndex)!
        updateAcsTokenTypeFields()
    }
    @objc func onMeetingTypeValueChanged(_ sender: UISegmentedControl!) {
        selectedMeetingType = MeetingType(rawValue: sender.selectedSegmentIndex)!
        updateMeetingTypeFields()
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        isKeyboardShowing = true
        adjustScrollView()
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        userIsEditing = false
        isKeyboardShowing = false
        adjustScrollView()
    }

    @objc func textFieldEditingDidChange() {
        startExperienceButton.isEnabled = !isStartExperienceDisabled
        updateStartExperieceButton()
    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        userIsEditing = true
        return true
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
        updateUIBasedOnUserInterfaceStyle()
        let safeArea = view.safeAreaLayoutGuide

        titleLabel = UILabel()
        titleLabel.text = "UI Library - UIKit Sample"
        titleLabel.sizeToFit()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        titleLabelConstraint = titleLabel.topAnchor.constraint(equalTo: safeArea.topAnchor,
                                                               constant: Constants.stackViewInterItemSpacingPortrait)
        titleLabelConstraint.isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor).isActive = true

        acsTokenUrlTextField = UITextField()
        acsTokenUrlTextField.placeholder = "ACS Token URL"
        acsTokenUrlTextField.text = envConfigSubject.acsTokenUrl
        acsTokenUrlTextField.delegate = self
        acsTokenUrlTextField.sizeToFit()
        acsTokenUrlTextField.translatesAutoresizingMaskIntoConstraints = false
        acsTokenUrlTextField.borderStyle = .roundedRect
        acsTokenUrlTextField.addTarget(self,
                                       action: #selector(textFieldEditingDidChange),
                                       for: .editingChanged)

        acsTokenTextField = UITextField()
        acsTokenTextField.placeholder = "ACS Token"
        acsTokenTextField.text = envConfigSubject.acsToken
        acsTokenTextField.delegate = self
        acsTokenTextField.sizeToFit()
        acsTokenTextField.translatesAutoresizingMaskIntoConstraints = false
        acsTokenTextField.borderStyle = .roundedRect
        acsTokenTextField.addTarget(self, action: #selector(textFieldEditingDidChange), for: .editingChanged)

        acsTokenTypeSegmentedControl = UISegmentedControl(items: ["Token URL", "Token"])
        acsTokenTypeSegmentedControl.selectedSegmentIndex = envConfigSubject.selectedAcsTokenType.rawValue
        acsTokenTypeSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        acsTokenTypeSegmentedControl.addTarget(self,
                                               action: #selector(onAcsTokenTypeValueChanged(_:)),
                                               for: .valueChanged)
        selectedAcsTokenType = envConfigSubject.selectedAcsTokenType

        displayNameTextField = UITextField()
        displayNameTextField.placeholder = "Display Name"
        displayNameTextField.text = envConfigSubject.displayName
        displayNameTextField.translatesAutoresizingMaskIntoConstraints = false
        displayNameTextField.delegate = self
        displayNameTextField.borderStyle = .roundedRect
        displayNameTextField.addTarget(self, action: #selector(textFieldEditingDidChange), for: .editingChanged)

        groupCallTextField = UITextField()
        groupCallTextField.placeholder = "Group Call Id"
        groupCallTextField.text = envConfigSubject.groupCallId
        groupCallTextField.delegate = self
        groupCallTextField.sizeToFit()
        groupCallTextField.translatesAutoresizingMaskIntoConstraints = false
        groupCallTextField.borderStyle = .roundedRect
        groupCallTextField.addTarget(self, action: #selector(textFieldEditingDidChange), for: .editingChanged)

        teamsMeetingTextField = UITextField()
        teamsMeetingTextField.placeholder = "Teams Meeting Link"
        teamsMeetingTextField.text = envConfigSubject.teamsMeetingLink
        teamsMeetingTextField.delegate = self
        teamsMeetingTextField.sizeToFit()
        teamsMeetingTextField.translatesAutoresizingMaskIntoConstraints = false
        teamsMeetingTextField.borderStyle = .roundedRect
        teamsMeetingTextField.addTarget(self, action: #selector(textFieldEditingDidChange), for: .editingChanged)

        meetingTypeSegmentedControl = UISegmentedControl(items: ["Group Call", "Teams Meeting"])
        meetingTypeSegmentedControl.selectedSegmentIndex = envConfigSubject.selectedMeetingType.rawValue
        meetingTypeSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        meetingTypeSegmentedControl.addTarget(self,
                                              action: #selector(onMeetingTypeValueChanged(_:)),
                                              for: .valueChanged)
        selectedMeetingType = envConfigSubject.selectedMeetingType

        startExperienceButton = UIButton()
        startExperienceButton.backgroundColor = .systemBlue
        startExperienceButton.setTitleColor(UIColor.white, for: .normal)
        startExperienceButton.setTitleColor(UIColor.systemGray6, for: .disabled)
        startExperienceButton.contentEdgeInsets = UIEdgeInsets.init(top: Constants.buttonVerticalInset,
                                                                    left: Constants.buttonHorizontalInset,
                                                                    bottom: Constants.buttonVerticalInset,
                                                                    right: Constants.buttonHorizontalInset)
        startExperienceButton.layer.cornerRadius = 8
        startExperienceButton.setTitle("Start Experience", for: .normal)
        startExperienceButton.sizeToFit()
        startExperienceButton.translatesAutoresizingMaskIntoConstraints = false
        startExperienceButton.addTarget(self, action: #selector(onStartExperienceBtnPressed), for: .touchUpInside)

        // horizontal stack view for the startExperienceButton

        let hSpacer1 = UIView()
        hSpacer1.translatesAutoresizingMaskIntoConstraints = false
        hSpacer1.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let hSpacer2 = UIView()
        hSpacer2.translatesAutoresizingMaskIntoConstraints = false
        hSpacer2.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let hStack = UIStackView(arrangedSubviews: [hSpacer1, startExperienceButton, hSpacer2])
        hStack.axis = .horizontal
        hStack.alignment = .fill
        hStack.distribution = .fill
        hStack.translatesAutoresizingMaskIntoConstraints = false

        let spaceView1 = UIView()
        spaceView1.translatesAutoresizingMaskIntoConstraints = false
        spaceView1.heightAnchor.constraint(equalToConstant: 0).isActive = true

        stackView = UIStackView(arrangedSubviews: [spaceView1, acsTokenTypeSegmentedControl,
                                                   acsTokenUrlTextField,
                                                   acsTokenTextField,
                                                   displayNameTextField,
                                                   meetingTypeSegmentedControl,
                                                   groupCallTextField,
                                                   teamsMeetingTextField, hStack])
        stackView.spacing = Constants.stackViewInterItemSpacingPortrait
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.setCustomSpacing(0, after: stackView.arrangedSubviews.first!)

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,
                                        constant: Constants.viewVerticalSpacing).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor).isActive = true

        contentView.addSubview(stackView)
        contentView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true

        stackView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                           constant: Constants.stackViewInterItemSpacingPortrait).isActive = true
        stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                            constant: -Constants.stackViewInterItemSpacingPortrait).isActive = true
        stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true

        hSpacer2.widthAnchor.constraint(equalTo: hSpacer1.widthAnchor).isActive = true

        updateAcsTokenTypeFields()
        updateMeetingTypeFields()
        startExperienceButton.isEnabled = !isStartExperienceDisabled
        updateStartExperieceButton()
    }

    private func adjustScrollView() {
        if UIDevice.current.userInterfaceIdiom == .phone || UIDevice.current.orientation.isLandscape {
            if self.isKeyboardShowing {
                let offset: CGFloat = (UIDevice.current.orientation.isPortrait
                              || UIDevice.current.orientation == .unknown) ? 200 : 250
                let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: offset, right: 0)
                scrollView.contentInset = contentInsets
                scrollView.scrollIndicatorInsets = contentInsets
                scrollView.setContentOffset(CGPoint(x: 0, y: offset), animated: true)
            } else {
                scrollView.contentInset = .zero
                scrollView.scrollIndicatorInsets = .zero
            }
        }
    }
}

extension UIKitDemoViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
