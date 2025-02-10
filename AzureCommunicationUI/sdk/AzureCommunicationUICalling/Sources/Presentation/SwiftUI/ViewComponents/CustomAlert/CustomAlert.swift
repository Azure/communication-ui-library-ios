//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI

/// Custom Alert
internal struct CustomAlert: View {
    let title: String
    let dismiss: () -> Void
    let agreeText: String
    let agreeAction: () -> Void
    let denyText: String
    let denyAction: () -> Void

    init(title: String,
         agreeText: String,
         denyText: String,
         dismiss: @escaping () -> Void,
         agreeAction: @escaping () -> Void,
         denyAction: @escaping () -> Void
         ) {
        self.title = title
        self.dismiss = dismiss
        self.agreeText = agreeText
        self.denyText = denyText
        self.agreeAction = agreeAction
        self.denyAction = denyAction
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onTapGesture {
                    dismiss()
                }
            HStack {
                Spacer()
                VStack {
                    Spacer()
                    VStack {
                        Text(title).font(.headline)
                        HStack {
                            Button(action: {
                                agreeAction()
                                dismiss()
                            }, label: {
                                Text(agreeText)
                                    .frame(width: CustomAlertConstants.confirmationButtonWidth,
                                           height: CustomAlertConstants.confirmationButtonHeight,
                                           alignment: .center
                                    )
                                    .foregroundColor(Color(StyleProvider.color.brandForegroundTint))
                            })
                            Divider().frame(maxHeight: CustomAlertConstants.confirmationButtonHeight)
                            Button(action: {
                                denyAction()
                                dismiss()
                            }, label: {
                                Text(denyText)
                                    .frame(width: CustomAlertConstants.confirmationButtonWidth,
                                           height: CustomAlertConstants.confirmationButtonHeight,
                                           alignment: .center)
                                    .foregroundColor(Color(StyleProvider.color.brandForegroundTint))
                            })
                        }
                    }.padding()
                        .background(Color(StyleProvider.color.drawerColor))
                        .cornerRadius(10)
                        .shadow(radius: 10)

                    Spacer()
                }
                Spacer()
            }
        }.accessibilityAddTraits(.isModal)
    }
}

internal struct BackgroundCleanerView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

internal class CustomAlertConstants {
   static let confirmationButtonWidth: CGFloat = 100
   static let confirmationButtonHeight: CGFloat = 48
}
