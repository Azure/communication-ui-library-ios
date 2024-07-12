//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI

struct BackgroundCleanerView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct CustomAlert<Content: View>: View {
    let title: String
    let dismiss: () -> Void
    let content: Content

    init(title: String,
         dismiss: @escaping () -> Void,
         @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
        self.dismiss = dismiss
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
                            content
                        }
                    }.padding()
                        .background(Color(StyleProvider.color.surface))
                        .cornerRadius(10)
                        .shadow(radius: 10)

                    Spacer()
                }
                Spacer()
            }
        }
    }
}
