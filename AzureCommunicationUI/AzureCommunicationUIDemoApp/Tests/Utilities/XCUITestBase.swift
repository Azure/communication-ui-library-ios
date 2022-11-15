//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureCommunicationUICalling

class XCUITestBase: XCTestCase {

    enum CompositeSampleInterface {
        case swiftUI
        case uiKit

        var name: String {
            switch self {
            case .swiftUI:
                return "Swift UI"
            case .uiKit:
                return "UI Kit"
            }
        }
    }

    enum CompositeMeetingType {
        case groupCall
        case teamsCall

        var name: String {
            switch self {
            case .groupCall:
                return "Group Call"
            case .teamsCall:
                return "Teams Meeting"
            }
        }
    }

    enum CompositeConnectionType {
        case acsTokenUrl
        case acsToken

        var name: String {
            switch self {
            case .acsTokenUrl:
                return "Token URL"
            case .acsToken:
                return "Token"
            }
        }
    }

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        app.launch()
        setupSystemPromptMonitor()
    }

    // MARK: Private / helper functions

    /// Responds to app permission prompts and system prompt
    private func setupSystemPromptMonitor() {
        addUIInterruptionMonitor(withDescription: "System Dialog") { _ in
            let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
            let allowBtn = springboard.buttons["Allow"]
            if allowBtn.waitForExistence(timeout: 2) {
                allowBtn.tap()
                return true
            }

            let okBtn = springboard.buttons["OK"]
            if okBtn.waitForExistence(timeout: 2) {
                okBtn.tap()
                return true
            }

            let dismissBtn = springboard.buttons["Dismiss"]
            if dismissBtn.waitForExistence(timeout: 2) {
                dismissBtn.tap()
                return true
            }

            return true
        }
        app.tap()
    }
}

extension XCUITestBase {

    /// Taps the button that matches with the given name
    /// - Parameters:
    ///   - accesiibilityLabel: accessibility label of the button
    ///   - shouldWait: determienes whether app should wait for the tap test to complete
    private func tapEnabledButton(buttonName: String, shouldWait: Bool) {
        let button = app.buttons[buttonName]
        if shouldWait {
            waitEnabled(for: button)
        }
        button.tap()
    }

    /// Taps the enabled button that matches with the given name
    /// - Parameters:
    ///   - accesiibilityLabel: accessibility label of the button
    ///   - shouldWait: determienes whether app should wait for the tap test to complete
    private func tapButton(buttonName: String, shouldWait: Bool) {
        let button = app.buttons[buttonName]
        if shouldWait {
            wait(for: button)
        }
        button.forceTapElement()
    }

    func isUsingMockedCallingSDKWrapper() -> Bool {
        return ProcessInfo.processInfo.environment["CALLING_SDK_MOCK_ENABLED"] == "true"
    }

    /// Taps the button that matches with the given accessibility label
    /// - Parameters:
    ///   - accesiibilityLabel: accessibility label of the button
    ///   - shouldWait: determienes whether app should wait for the tap test to complete
    func tapButton(accessibilityIdentifier: String, shouldWait: Bool) {
        tapButton(buttonName: accessibilityIdentifier, shouldWait: shouldWait)
    }

    /// Taps the enabled button that matches with the given accessibility label
    /// - Parameters:
    ///   - accesiibilityLabel: accessibility label of the button
    ///   - shouldWait: determienes whether app should wait for the tap test to complete
    func tapEnabledButton(accessibilityIdentifier: String, shouldWait: Bool) {
        tapEnabledButton(buttonName: accessibilityIdentifier, shouldWait: shouldWait)
    }

    /// Selects the interface before entering the composite
    /// - Note: Only call this function before entering composite.
    func tapInterfaceFor(_ interface: CompositeSampleInterface) {
        app.buttons[interface.name].tap()
    }

    /// Selects the meeting type before entering the composite
    /// - Note: Only call this function before entering composite.
    func tapMeetingType(_ meetingType: CompositeMeetingType) {
        app.buttons[meetingType.name].tap()
    }

    /// Selects the call connection type before entering the composite
    /// - Note: Only call this function before entering composite.
    func tapConnectionTokenType(_ connectionType: CompositeConnectionType) {
        app.buttons[connectionType.name].tap()
    }

    /// Taps the cell that matches with the given accessibility id
    /// - Parameters:
    ///   - accessibilityIdentifier: accessibility id of the cell
    ///   - shouldWait: determines whether app should wait for the tap test to complete
    func tapCell(accessibilityIdentifier: String, shouldWait: Bool) {
        let cell = app.cells[accessibilityIdentifier]
        if shouldWait {
            wait(for: cell)
        }
        cell.forceTapElement()
    }

    func takeScreenshot(name: String = "App Screenshot - \(Date().description)",
                        lifetime: XCTAttachment.Lifetime  = .keepAlways) {
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = lifetime
        add(attachment)
    }
}
