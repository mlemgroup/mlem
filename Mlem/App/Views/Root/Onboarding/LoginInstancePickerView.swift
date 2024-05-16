//
//  LoginInstancePickerView.swift
//  Mlem
//
//  Created by Sjmarf on 10/05/2024.
//

import MlemMiddleware
import SwiftUI

struct LoginInstancePickerView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.isFirstPage) var isFirstPage
    @Environment(NavigationLayer.self) var navigation
    
    @State var domain: String = ""
    
    @State var connecting: Bool = false
    @State private var scrollViewContentSize: CGSize = .zero
    @FocusState private var focused: Bool
    
    // Temporary - before 2.0 release this should be a list of all major instances fetched dynamically.
    // In 1.0 we kept a list of top instances for use in the search homepage - we can reuse that list here.
    let suggestions: [String] = [
        "lemmy.ml",
        "sh.itjust.works",
        "lemmy.world",
        "literature.cafe",
        "lemmy.ca",
        "feddit.de",
        "lemmy.zip",
        "startrek.website"
    ]
    
    var body: some View {
        content
            .interactiveDismissDisabled(!domain.isEmpty)
            .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
            .toolbar {
                if navigation.isInsideSheet, isFirstPage {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                        .disabled(connecting)
                    }
                }
            }
    }
    
    @ViewBuilder
    var content: some View {
        let filteredSuggestions = suggestions.filter { $0.starts(with: domain) && $0 != domain }
        let showSuggestions = !(filteredSuggestions.isEmpty || domain.isEmpty || !focused)
        VStack {
            Image(systemName: "globe")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 50)
                .foregroundStyle(.blue)
            Text("Sign In to Lemmy")
                .font(.title)
                .bold()
            Text("Enter your instance's domain name below.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.bottom, 5)
            instanceSuggestionsBox(suggestions: filteredSuggestions)
                .padding(showSuggestions ? .vertical : .top)
            if !showSuggestions {
                nextButton
                    .padding(.top, 5)
            }
            Spacer()
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    func instanceSuggestionsBox(suggestions: [String]) -> some View {
        VStack(spacing: 0) {
            instanceField
            if !suggestions.isEmpty, !domain.isEmpty, focused {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(suggestions, id: \.self) { text in
                            Divider()
                            Button {
                                domain = text
                                focused = false
                            } label: {
                                Text(attributedString(suggestion: text))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding()
                        }
                    }
                    .background(
                        GeometryReader { geo in
                            geometryReaderBackground(geo: geo)
                        }
                    )
                }
                .frame(maxHeight: scrollViewContentSize.height)
                .scrollBounceBehavior(.basedOnSize)
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    @ViewBuilder
    var instanceField: some View {
        TextField(
            "Domain",
            text: $domain,
            prompt: Text("example.com")
        )
        .disabled(connecting)
        .focused($focused)
        .keyboardType(.URL)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled()
        .scrollDismissesKeyboard(.never)
        .padding()
        .submitLabel(.go)
        .onSubmit {
            if !domain.isEmpty {
                attemptToConnect()
            }
        }
        .onTapGesture {
            if !connecting { focused = true }
        }
        .onAppear { focused = true }
    }
    
    @ViewBuilder
    var nextButton: some View {
        Button(action: attemptToConnect) {
            Text(connecting ? "Connecting..." : "Next")
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .transaction { $0.animation = .none }
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.roundedRectangle(radius: 16))
        .transaction { $0.animation = .none }
        .disabled(!domain.contains(/.+\..+$/) || connecting)
    }
    
    func geometryReaderBackground(geo: GeometryProxy) -> some View {
        Task { @MainActor in
            scrollViewContentSize = geo.size
        }
        return Color.clear
    }
    
    func attemptToConnect() {
        guard !connecting else { return }
        var domain = domain
        if !domain.contains("://") {
            domain = "https://\(domain)"
        }
        if let url = URL(string: domain) {
            focused = false
            connecting = true
            Task {
                let apiClient = ApiClient.getApiClient(for: url, with: nil)
                do {
                    let instance = try await apiClient.getSite()
                    DispatchQueue.main.async {
                        navigation.push(.login(.instance(instance)))
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        connecting = false
                    }
                } catch {
                    DispatchQueue.main.async { connecting = false }
                }
            }
        }
    }
    
    func attributedString(suggestion string: String) -> AttributedString {
        var attributedString = AttributedString(stringLiteral: string)
        attributedString.foregroundColor = .secondary
        if string.starts(with: domain) {
            let range = ..<attributedString.index(attributedString.startIndex, offsetByCharacters: domain.count)
            attributedString[range].foregroundColor = .primary
        }
        return attributedString
    }
}
