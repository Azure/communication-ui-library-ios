//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import AzureCommunicationUI
import AzureCommunicationCalling

struct SettingsView: View {
    @State private var isLocalePickerDisplayed: Bool = false
    @ObservedObject var envConfigSubject: EnvConfigSubject
    var dismissAction: (() -> Void)

    let verticalPadding: CGFloat = 5
    let horizontalPadding: CGFloat = 10

    var body: some View {
        ZStack {
            VStack {
                HStack {
                    backButton
                    Spacer()
                }
                Text("UI Library - Settings")
                localizationSettings
                Spacer()
            }
            LocalePicker(selection: $envConfigSubject.languageCode,
                         isShowing: $isLocalePickerDisplayed)
                .animation(.linear)
                .offset(y: isLocalePickerDisplayed ? 0 : UIScreen.main.bounds.height)
        }
        .padding()
    }

    var backButton: some View {
        Button("Back") {
            dismissAction()
        }
    }

    var localizationSettings: some View {
        VStack {
            Text("Localization Settings")
                .bold()
            HStack {
                Text("Language: ")
                Spacer()
                Button("\(envConfigSubject.languageCode.rawValue)") {
                    self.isLocalePickerDisplayed.toggle()
                }
                .padding(.horizontal, horizontalPadding)
            }
            .onTapGesture(perform: {
                self.isLocalePickerDisplayed.toggle()
            })
            .padding(.horizontal, horizontalPadding)

            HStack {
                Toggle("Is Right-to-Left: ", isOn: $envConfigSubject.isRightToLeft)
            }
            .padding(.horizontal, horizontalPadding)
        }
        .padding(.vertical, verticalPadding)
        .padding(.horizontal, horizontalPadding)
    }
}

struct LocalePicker: View {
    @Binding var selection: LanguageCode
    @Binding var isShowing: Bool
    let supportedLanguage: [LanguageCode] = LocalizationConfiguration.supportedLanguages

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button("Close") {
                    self.isShowing = false
                }
            }
            Picker("Language", selection: $selection) {
                ForEach(supportedLanguage, id: \.self) {
                    Text($0.rawValue)
                }
            }
            .pickerStyle(.wheel)
        }
    }
}
