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

    // MARK: Private / helper functions

    /// Responds to app permission prompts and system prompt
    private func setupSystemPromptMonitor() {
        addUIInterruptionMonitor(withDescription: "System Dialog") { _ in
            let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
            let allowBtn = springboard.buttons["Allow"]
            if allowBtn.exists {
                allowBtn.tap()
                if #unavailable(iOS 16) {
                    sleep(1)
                }
                return true
            }

            let okBtn = springboard.buttons["OK"]
            if okBtn.exists {
                okBtn.tap()
                if #unavailable(iOS 16) {
                    sleep(1)
                }
                return true
            }

            let dismissBtn = springboard.buttons["Dismiss"]
            if dismissBtn.exists {
                dismissBtn.tap()
                if #unavailable(iOS 16) {
                    sleep(1)
                }
                return true
            }

            return false
        }
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

    /// Verifies a button is on the screen
    /// - Parameters:
    ///   - accessibilityIdentifier: accessibility label of the button
    func verifyButtonExistsAndEnabled(accessibilityIdentifier: String) {
        let button = app.buttons[accessibilityIdentifier]
        wait(for: button)
        XCTAssertTrue(button.exists, "Button does not exist.")
        XCTAssertTrue(button.isEnabled, "Button is not enabled.")
    }

    /// Verifies a button is on the screen
    /// - Parameters:
    ///   - accessibilityIdentifier: accessibility label of the button
    func verifyButtonDoesNotExist(accessibilityIdentifier: String) {
        let button = app.buttons[accessibilityIdentifier]
        XCTAssertTrue(!button.exists, "Button Exists, should be hidden.")
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

    /// Enables CallingSDK mock and taps Start experience button
    /// - Parameter useCallingSDKMock: Option to enable callingSDK mock. Default value is `true`
    func startExperience(useCallingSDKMock: Bool = true) {
        if useCallingSDKMock {
            enableMockCallingSDKWrapper()
        }
        tapEnabledButton(accessibilityIdentifier: AccessibilityId.startExperienceAccessibilityID.rawValue,
                         shouldWait: true)
    }

    func closeDemoAppSettingsPage() {
        if #unavailable(iOS 15) {
            // Close button in toolbar is unavailable for iOS 14 because of how Forms handles events
            // this issue is fixed for iOS 15
            // closing the presented view with a swipe
            let startPoint = app.navigationBars.firstMatch.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            // the value shouldn't be less than 500
            // as swipe won't performed as expected for hiding the presented view
            let finishYOffset = 500
            let finishPoint = startPoint.withOffset(CGVector(dx: 0, dy: finishYOffset))
            startPoint.press(forDuration: 0, thenDragTo: finishPoint)
        } else {
            tapButton(accessibilityIdentifier: AccessibilityId.settingsCloseButtonAccessibilityID.rawValue)
        }
    }

    /// Enables the Mock Calling SDK Wrapper by toggling the relevant switch in the settings.
    func enableMockCallingSDKWrapper() {
        tapButton(accessibilityIdentifier: AccessibilityId.useMockCallingSDKHandlerToggleAccessibilityID.rawValue)
    }

    func joinCall() {
        tapEnabledButton(accessibilityIdentifier: AccessibilityIdentifier.joinCallAccessibilityID.rawValue,
                         shouldWait: true)
    }

    /// Enters text into a field identified by an accessibility identifier
    /// - Parameters:
    ///   - accessibilityIdentifier: The accessibility identifier of the text field.
    ///   - text: The text to enter into the field.
    func enterText(accessibilityIdentifier: String, text: String) {
        let textField = app.textFields[accessibilityIdentifier]
        // let textFieldOther = app.otherElements[accessibilityIdentifier]
        wait(for: textField)
        textField.tap() // Make sure the text field is focused
        if #unavailable(iOS 16) {
            sleep(1) // Sleep to ensure the keyboard has time to appear
        }
        textField.typeText(text)
    }

    /// Taps a settings toggle based on its accessibility identifier.
    /// - Parameter accessibilityId: The accessibility identifier of the toggle.
    func enableSettingsToggle(accessibilityId: String) {
        navigateToSettings()
        let toggle = findAndPrepareToggle(accessibilityId: accessibilityId)
        toggleSwitch(accessibilityIdentifier: accessibilityId, expectedState: true)
        verifyToggleState(toggle, expectedState: true)
        closeSettings()
    }

    /// Generic method to navigate to the settings page.
    private func navigateToSettings() {
        tapButton(accessibilityIdentifier: AccessibilityId.settingsButtonAccessibilityID.rawValue)
    }

    /// Finds a toggle switch and scrolls to it if necessary.
    /// - Parameter accessibilityId: The accessibility identifier of the toggle.
    /// - Returns: The toggle switch as an XCUIElement.
    private func findAndPrepareToggle(accessibilityId: String) -> XCUIElement {
        let toggle = app.switches[accessibilityId]
        scrollAndWaitForElement(element: toggle)
        return toggle
    }

    /// Verifies the state of a toggle switch.
    /// - Parameters:
    ///   - toggle: The toggle switch as an XCUIElement.
    ///   - expectedState: The expected state of the toggle (true for on, false for off).
    private func verifyToggleState(_ toggle: XCUIElement, expectedState: Bool) {
        XCTAssertEqual(toggle.isOn, expectedState, "Toggle state did not match expected state.")
    }

    /// Scrolls until a specific element is visible or a timeout is reached.
    /// - Parameters:
    ///   - element: The element to scroll to.
    ///   - timeout: Maximum time to attempt scrolling.
    private func scrollAndWaitForElement(element: XCUIElement, timeout: TimeInterval = 25.0) {
        let startTime = Date()
        while Date().timeIntervalSince(startTime) < timeout {
            guard !element.exists || !element.isHittable else {
                return
            }
            app.swipeUp() // Simplified as swipeUp() should work for both tables and collection views generically
        }

        wait(for: element)
    }

    /// Closes the settings page, adapting to different iOS versions as necessary.
    private func closeSettings() {
        let element = app.buttons[AccessibilityId.settingsCloseButtonAccessibilityID.rawValue]
        wait(for: element)
        element.tap()
    }

    /// Taps a button based on its accessibility identifier.
    /// - Parameters:
    ///   - accessibilityIdentifier: The accessibility identifier of the button.
    private func tapButton(accessibilityIdentifier: String) {
        let button = app.buttons[accessibilityIdentifier]
        button.tap()
        // Add any necessary wait or delay here if needed
    }

    func toggleSwitch(accessibilityIdentifier: String, expectedState: Bool, maxAttempts: Int = 2) {
        let toggle = app.switches[accessibilityIdentifier]
        for _ in 1...maxAttempts {
            if toggle.isOn != expectedState {
                toggle.tap()
                sleep(1) // Wait a moment for the state to potentially change.
            } else {
                return // Exit if the toggle reaches the expected state.
            }
        }
        // Optionally, verify the toggle state after all attempts.
        verifyToggleState(toggle, expectedState: expectedState)
    }

}
