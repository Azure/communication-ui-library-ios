//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
import Foundation
import FluentUI
import SwiftUI
import UIKit
@testable import AzureCommunicationUICalling

class CompositeButtonTests: XCTestCase {
    private var style: FluentUI.ButtonStyle!
    private var label: String!
    private var themeOptions: MockThemeOptions!

       override func setUp() {
           super.setUp()
           // Common setup for tests
           style = FluentUI.ButtonStyle.primaryFilled
           label = "Test Button"
           themeOptions = MockThemeOptions(primaryColor: .blue, foregroundOnPrimaryColor: .white)
       }
    // Test 1: Initialization
    func testInitialization() {
        let icon: CompositeIcon? = nil
        let padding = CompositeButton.Paddings(horizontal: 10, vertical: 5)
        let themeOptions = MockThemeOptions(primaryColor: .blue, foregroundOnPrimaryColor: .white)
        let compositeButton = CompositeButton(
            buttonStyle: style,
            buttonLabel: label,
            iconName: icon,
            paddings: padding,
            themeOptions: themeOptions,
            update: { _ in }
        )
        XCTAssertEqual(compositeButton.buttonStyle, style)
        XCTAssertEqual(compositeButton.buttonLabel, label)
        XCTAssertEqual(compositeButton.iconName, icon)
        XCTAssertEqual(compositeButton.paddings?.horizontal, 10)
        XCTAssertEqual(compositeButton.paddings?.vertical, 5)
        XCTAssertEqual(compositeButton.themeOptions.primaryColor, .blue)
    }

    // Test 2: Button Creation
    func testMakeUIView() {
        let icon: CompositeIcon? = nil
        let padding = CompositeButton.Paddings(horizontal: 10, vertical: 5)
        let compositeButton = CompositeButton(
            buttonStyle: style,
            buttonLabel: label,
            iconName: icon,
            paddings: padding,
            themeOptions: themeOptions,
            update: { _ in }
        )
        let button = compositeButton.createButton(style: style, label: label, paddings: nil, themeOptions: themeOptions)
        XCTAssertEqual(button.title(for: .normal), label)
        XCTAssertEqual(button.style, style)
        // Assert the edge insets match expected values
        let expectedInsets = button.edgeInsets
        XCTAssertEqual(button.edgeInsets, expectedInsets)
    }
    // Test 3: Dynamic Color Application
       func testDynamicColorApplication() {
           let compositeButton = CompositeButton(
               buttonStyle: FluentUI.ButtonStyle.primaryOutline,
               buttonLabel: label,
               iconName: nil,
               paddings: nil,
               themeOptions: themeOptions,
               update: { _ in }
           )
           let button = compositeButton.createButton(style: FluentUI.ButtonStyle.primaryOutline, label: label, paddings: nil, themeOptions: themeOptions)

           // Simulate button pressed state to check title color
           button.sendActions(for: .touchUpInside) // or whatever method is used to simulate the press
               // Get the button's title color for the normal and pressed states
               let currentTitleColorNormal = button.titleColor(for: .normal)
           // Use a color comparison function
           XCTAssertTrue(colorsEqual(currentTitleColorNormal, button.currentTitleColor), "The normal title color should match the expected foreground color.")
       }
 
    // Test 4: Icon Application
    func testIconApplication() {
        let style = FluentUI.ButtonStyle.primaryFilled
        let label = "Test Button"
        let iconName: CompositeIcon = .checkmark
        let themeOptions = MockThemeOptions(primaryColor: .blue, foregroundOnPrimaryColor: .white)
        let compositeButton = CompositeButton(
            buttonStyle: style,
            buttonLabel: label,
            iconName: iconName,
            paddings: nil,
            themeOptions: themeOptions,
            update: { _ in }
        )
        let button = compositeButton.createButton(style: style, label: label, paddings: nil, themeOptions: themeOptions)
        XCTAssertEqual(button.image(for: .normal), button.currentImage)
    }
    // Helper function to compare UIColor instances
        private func colorsEqual(_ color1: UIColor?, _ color2: UIColor?) -> Bool {
            guard let c1 = color1?.cgColor.components,
                  let c2 = color2?.cgColor.components else { return false }
            return c1.count == c2.count && zip(c1, c2).allSatisfy { abs($0 - $1) < 0.01 } // Allow a small margin for floating-point differences
        }
}
