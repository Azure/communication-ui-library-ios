//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import AzureCommunicationUI
import AzureCommunicationCalling

struct SettingsView: View {
    @State private var isLocalePickerDisplayed: Bool = false
    @State private var selectedAvatarImage: Image?
    @ObservedObject var envConfigSubject: EnvConfigSubject
    var dismissAction: (() -> Void)

    let verticalPadding: CGFloat = 5
    let horizontalPadding: CGFloat = 10
    let avatarChoices: [String] = ["cat", "fox", "koala", "monkey", "mouse", "octopus"]
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    backButton
                    Spacer()
                }
                Text("UI Library - Settings")
                localizationSettings
                avatarSettings
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
                Button("\(envConfigSubject.languageCode)") {
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

    var avatarSettings: some View {
        VStack {
            Text("Avatars")
                .bold()
            HStack {
                ForEach(avatarChoices, id: \.self) { imgName in
                    Button(
                        action: {
                            if envConfigSubject.avatarImageName == imgName {
                                envConfigSubject.avatarImageName = ""
                            } else {
                                envConfigSubject.avatarImageName = imgName
                            }
                        },
                        label: { Image(imgName) }
                    ).border(envConfigSubject.avatarImageName == imgName ? Color.blue : Color.clear)
                }
                Spacer()
            }
            TextField("Rendered Display Name", text: $envConfigSubject.renderedDisplayName)
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .textFieldStyle(.roundedBorder)
        }
        .padding(.horizontal, horizontalPadding)
    }
}

struct LocalePicker: View {
    @Binding var selection: String
    @Binding var isShowing: Bool
    let supportedLanguage: [String] = ["auto"] + LocalizationConfiguration.supportedLanguages

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
                    if $0 == "auto" {
                        Text("Detect locale (en, zh-Hant, fr, fr-CA)")
                    } else {
                        Text($0)
                    }
                }
            }
            .pickerStyle(.wheel)
        }
    }
}
