//
//  Translation Sheet.swift
//  Mlem
//
//  Created by tht7 on 22/06/2023.
//

import Foundation
import SwiftUI

struct TranslationSheet: View {
    @Binding var textToTranslate: String?
    @Binding var shouldShow: Bool

    var body: some View {
        ZStack(alignment: .topTrailing) {
            InAppWebView(url: URL(string: "https://translate.google.com/?tl=\(Locale.current.language.languageCode?.identifier ?? "")&q=\(textToTranslate ?? "bobo")")!)
            Button() {
                withAnimation {
                    shouldShow = false
                }
            } label: {
                Image(systemName: "xmark")
//                    .scaledToFill()
                    .resizable()
                    .symbolRenderingMode(.monochrome)

            }
            .padding()
            .frame(width: 60, height: 60)
//            .padding()
            .background(.ultraThinMaterial)
//            .buttonBorderShape(.)
            .accessibilityLabel(Text("Close Translation Sheet Button"))
            .clipShape(.rect(cornerRadii: .init(topLeading: 0, bottomLeading: 16, bottomTrailing:  0, topTrailing: 0)))

        }
        .onAppear {
            if textToTranslate == nil {
                withAnimation {
                    shouldShow = false
                }
            }
        }
    }
}

struct EasyTranslateButton: View {
    @Environment(\.translateText) var translateText;
    @Binding var text: String?

    var body: some View {
        Button() {
            translateText(text!)
        } label: {
            Label("Translate", systemImage: "globe")
        }.disabled(text == nil)
    }
}
