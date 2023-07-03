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
            InAppWebView(url: getTranslateUrl(textToTranslate))
            Button {
                withAnimation {
                    shouldShow = false
                }
            } label: {
                Image(systemName: "xmark")
                    .resizable()
                    .symbolRenderingMode(.monochrome)

            }
            .padding()
            .frame(width: 60, height: 60)
            .background(.ultraThinMaterial)
            .accessibilityLabel(Text("Close Translation Sheet Button"))
            .clipShape(RoundedRectangle(cornerRadius: 16))

        }
        .onAppear {
            if textToTranslate == nil {
                withAnimation {
                    shouldShow = false
                }
            }
        }
    }
    
    func getTranslateUrl(_ text: String?) -> URL {
        let baseURL = "https://translate.google.com/?tl="
        let lang = Locale.current.language.languageCode?.identifier ?? ""
        return URL(string: "\(baseURL)\(lang)&q=\(textToTranslate ?? "Missing Text")")!
    }
}

struct EasyTranslateButton: View {
    @Environment(\.translateText) var translateText
    @Binding var text: String?

    var body: some View {
        Button {
            translateText(text!)
        } label: {
            Label("Translate", systemImage: "globe")
        }.disabled(text == nil)
    }
}
