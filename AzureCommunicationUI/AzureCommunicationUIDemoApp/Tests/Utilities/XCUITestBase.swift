//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureCommunicationUICalling

class XCUITestBase: XCTestCase {

    enum CompositeSampleInterface {
        case callSwiftUI
        case callUIKit

        var name: String {
            switch self {
            case .callSwiftUI:
                return "Call - Swift UI"
            case .callUIKit:
                return "Call - UI Kit"
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

    override func tearDown() {
        super.tearDown()
        // terminate app on tear down
        app.terminate()
    }

    // MARK: Private / helper functions

    /// Responds to app permission prompts and system prompt
    private func setupSystemPromptMonitor() {
        addUIInterruptionMonitor(withDescription: "System Dialog") { _ in
            let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
            let allowBtn = springboard.buttons["Allow"]
            // if allowBtn.waitForExistence(timeout: 1) {
            if allowBtn.exists {
                allowBtn.tap()
                return true
            }

            let okBtn = springboard.buttons["OK"]
            // if okBtn.waitForExistence(timeout: 1) {
            if okBtn.exists {
                okBtn.tap()
                return true
            }

            let dismissBtn = springboard.buttons["Dismiss"]
            // if dismissBtn.waitForExistence(timeout: 1) {
            if dismissBtn.exists {
                dismissBtn.tap()
                return true
            }

            let cancelBtn = springboard.buttons["Cancel"]
            if cancelBtn.exists {
//            if cancelBtn.waitForExistence(timeout: 1) {
                cancelBtn.tap()
                return true
            }

            return false
        }
        app.tap()
    }
}

extension XCUITestBase {

    /// Taps the button that matches with the given name
    /// - Parameters:
    ///   - buttonName: accessibility label of the button
    ///   - shouldWait: determines whether app should wait for the tap test to complete
    private func tapEnabledButton(buttonName: String, shouldWait: Bool) {
        let button = app.buttons[buttonName]
        if shouldWait {
            waitEnabled(for: button)
        }
        button.tap()
    }

    /// Taps the enabled button that matches with the given name
    /// - Parameters:
    ///   - buttonName: accessibility label of the button
    ///   - shouldWait: determines whether app should wait for the tap test to complete
    private func tapButton(buttonName: String, shouldWait: Bool) {
        let button = app.buttons[buttonName]
        if shouldWait {
            wait(for: button)
        }
        button.tap()
    }

    /// Taps the button that matches with the given accessibility label
    /// - Parameters:
    ///   - accessibilityIdentifier: accessibility label of the button
    ///   - shouldWait: determines whether app should wait for the tap test to complete. Default value is `false`
    func tapButton(accessibilityIdentifier: String, shouldWait: Bool = false) {
        tapButton(buttonName: accessibilityIdentifier, shouldWait: shouldWait)
    }

    /// Taps the enabled button that matches with the given accessibility label
    /// - Parameters:
    ///   - accessibilityIdentifier: accessibility label of the button
    ///   - shouldWait: determines whether app should wait for the tap test to complete
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

    func toggleMockSDKWrapperSwitch(enable: Bool) {
        tapButton(
            accessibilityIdentifier: AccessibilityId.settingsButtonAccessibilityID.rawValue,
            shouldWait: false)
        app.tap()
        let toggle = app.switches[AccessibilityId.useMockCallingSDKHandlerToggleAccessibilityID.rawValue]
        if toggle.waitForExistence(timeout: 3), let enabled = toggle.isOn, enabled != enable {
            toggle.tap()
        }
        app.buttons["Close"].tap()
    }

    /// Taps the cell that matches with the given accessibility id
    /// - Parameters:
    ///   - accessibilityIdentifier: accessibility id of the cell
    ///   - shouldWait: determines whether app should wait for the tap test to complete. Default value is `true`
    func tapCell(accessibilityIdentifier: String, shouldWait: Bool = true) {
        let cell = app.cells[accessibilityIdentifier]
        if shouldWait {
            wait(for: cell)
        }
        cell.tap()
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

extension XCUIElement {
    var isOn: Bool? {
        return (self.value as? String).map { $0 == "1" }
    }
}
