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
            if allowBtn.exists {
                allowBtn.tap()
                return true
            }

            let okBtn = springboard.buttons["OK"]
            if okBtn.exists {
                okBtn.tap()
                return true
            }

            let dismissBtn = springboard.buttons["Dismiss"]
            if dismissBtn.exists {
                dismissBtn.tap()
                return true
            }

            return false
        }
        addUIInterruptionMonitor(withDescription: "System Dialog") { _ in
            let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
            let okBtn = springboard.buttons["OK"]
            if okBtn.exists {
                okBtn.tap()
                return true
            }

            let allowBtn = springboard.buttons["Allow"]
            if allowBtn.exists {
                allowBtn.tap()
                return true
            }

            let dismissBtn = springboard.buttons["Dismiss"]
            if dismissBtn.exists {
                dismissBtn.tap()
                return true
            }

            return false
        }
        app.tap()
    }
}

extension XCUITestBase {
    /// Taps the button that matches with the given accessibility label
    /// - Parameters:
    ///   - accessibilityIdentifier: accessibility label of the button
    ///   - shouldWait: determines whether app should wait for the tap test to complete. Default value is `false`
    func tapButton(accessibilityIdentifier: String, shouldWait: Bool = false) {
        let button = app.buttons[accessibilityIdentifier]
        if shouldWait {
            wait(for: button)
        }
        button.tap()
        if #unavailable(iOS 16) {
            sleep(1)
        }
    }

    /// Taps the enabled button that matches with the given accessibility label
    /// - Parameters:
    ///   - accessibilityIdentifier: accessibility label of the button
    ///   - shouldWait: determines whether app should wait for the tap test to complete
    func tapEnabledButton(accessibilityIdentifier: String, shouldWait: Bool) {
        let button = app.buttons[accessibilityIdentifier]
        if shouldWait {
            waitEnabled(for: button)
        }
        button.tap()
        if #unavailable(iOS 16) {
            sleep(1)
        }
    }

    /// Selects the interface before entering the composite
    /// - Note: Only call this function before entering composite.
    func tapInterfaceFor(_ interface: CompositeSampleInterface) {
        tapButton(accessibilityIdentifier: interface.name)
    }

    /// Selects the meeting type before entering the composite
    /// - Note: Only call this function before entering composite.
    func tapMeetingType(_ meetingType: CompositeMeetingType) {
        tapButton(accessibilityIdentifier: meetingType.name)
    }

    /// Selects the call connection type before entering the composite
    /// - Note: Only call this function before entering composite.
    func tapConnectionTokenType(_ connectionType: CompositeConnectionType) {
        tapButton(accessibilityIdentifier: connectionType.name)
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
        if #unavailable(iOS 16) {
            sleep(1)
        }
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

extension XCUITestBase {
    /// Enables CallingSDK mock and taps Start experience button
    /// - Parameter useCallingSDKMock: Option to enable callingSDK mock. Default value is `true`
    @available(iOS 15, *)
    func startExperienceWithCallingSDKMock() {
        enableMockCallingSDKWrapper()
        startExperience
    }

    /// Taps Start experience button
    func startExperience() {
        tapEnabledButton(accessibilityIdentifier: AccessibilityId.startExperienceAccessibilityID.rawValue,
                         shouldWait: true)
    }

    // switches don't handle tap correctly for iOS < 14. Possible problem can be Rosetta usage
    @available(iOS 15, *)
    func enableMockCallingSDKWrapper() {
        tapButton(accessibilityIdentifier: AccessibilityId.settingsButtonAccessibilityID.rawValue)
        wait(for: app.switches[AccessibilityId.useMockCallingSDKHandlerToggleAccessibilityID.rawValue])
        app.tap()
        let toggle = app.switches[AccessibilityId.useMockCallingSDKHandlerToggleAccessibilityID.rawValue]
        toggle.tap()
        XCTAssertEqual(toggle.isOn, true)
        app.buttons["Close"].tap()
    }

    func joinCall() {
        tapEnabledButton(accessibilityIdentifier: AccessibilityIdentifier.joinCallAccessibilityID.rawValue,
                         shouldWait: true)
    }
}
