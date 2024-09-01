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
    @Environment(\.isRootView) var isRootView
    @Environment(NavigationLayer.self) var navigation
    @Environment(Palette.self) var palette
    
    @State var domain: String = ""
    
    @State var connecting: Bool = false
    @State var invalidInstance: Bool = false
    @State private var scrollViewContentSize: CGSize = .zero
    @FocusState private var focused: Bool
    
    var body: some View {
        content
            .interactiveDismissDisabled(!domain.isEmpty)
            .background(palette.groupedBackground.ignoresSafeArea())
            .toolbar {
                if navigation.isInsideSheet, isRootView {
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
        let filteredSuggestions = MlemStats.main.instances?.lazy.map(\.host).filter {
            $0.starts(with: domain) && $0 != domain
        } ?? []
        let showSuggestions = !(filteredSuggestions.isEmpty || domain.isEmpty || !focused)
        VStack {
            Image(systemName: "globe")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 50)
                .foregroundStyle(palette.accent)
            Text("Sign In to Lemmy")
                .font(.title)
                .bold()
            Text("Enter your instance's domain name below.")
                .foregroundStyle(palette.secondary)
                .multilineTextAlignment(.center)
                .padding(.bottom, 5)
            instanceSuggestionsBox(suggestions: filteredSuggestions)
                .padding(showSuggestions ? .vertical : .top)
            if !showSuggestions {
                nextButton
                    .padding(.top, 5)
            }
            if invalidInstance {
                Text("Failed to connect to \(domain)")
                    .foregroundStyle(palette.negative)
                    .multilineTextAlignment(.center)
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
                                attemptToConnect()
                            } label: {
                                Text(attributedString(suggestion: text))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding()
                        }
                    }
                    .background(
                        GeometryReader { geo in
                            geometryReaderBackground(geoSize: geo.size)
                        }
                    )
                }
                .frame(maxHeight: scrollViewContentSize.height)
                .scrollBounceBehavior(.basedOnSize)
            }
        }
        .frame(maxWidth: .infinity)
        .background(palette.secondaryGroupedBackground)
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
        .onChange(of: domain) {
            invalidInstance = false
        }
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
        .disabled(!(domain.contains(/.+\..+$/) || domain.starts(with: "localhost:")) || connecting)
    }
    
    func geometryReaderBackground(geoSize: CGSize) -> some View {
        Task { @MainActor in
            scrollViewContentSize = geoSize
        }
        return Color.clear
    }
    
    func attemptToConnect() {
        guard !connecting else { return }
        var domain = domain
        if !domain.contains("://") {
            domain = domain.starts(with: "localhost:") ? "http://\(domain)" : "https://\(domain)"
        }
        if let url = URL(string: domain) {
            focused = false
            connecting = true
            let fetchTask = Task {
                let apiClient = ApiClient.getApiClient(for: url, with: nil)
                do {
                    let instance = try await apiClient.getMyInstance()
                    Task { @MainActor in
                        navigation.push(.login(.instance(instance)))
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        connecting = false
                    }
                } catch {
                    Task { @MainActor in
                        connecting = false
                        invalidInstance = true
                    }
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                fetchTask.cancel()
                invalidInstance = true
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
