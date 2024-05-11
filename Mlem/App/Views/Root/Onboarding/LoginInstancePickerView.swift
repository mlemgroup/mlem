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
    @Environment(NavigationLayer.self) var navigation
    
    @State var instance: String = ""
    
    @State private var scrollViewContentSize: CGSize = .zero
    @FocusState private var focused: Bool
    
    // Temporary - before 2.0 release this should be a list of all major instances
    let suggestions: [String] = [
        "lemmy.ml",
        "sh.itjust.works",
        "lemmy.world",
        "literature.cafe",
        "lemmy.ca",
        "feddit.de",
        "lemmy.zip",
        "startrek.site"
    ]
    
    var body: some View {
        let filteredSuggestions = suggestions.filter { $0.starts(with: instance) && $0 != instance }
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
                .padding(filteredSuggestions.isEmpty ? [.horizontal, .top] : .all)
            if filteredSuggestions.isEmpty {
                Button("Next") {}
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.roundedRectangle(radius: 16))
                    .disabled(!instance.contains(/.*\..+$/))
            }
            Spacer()
        }
        .toolbar {
            if navigation.isInsideSheet {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .interactiveDismissDisabled(!instance.isEmpty)
    }
    
    @ViewBuilder
    func instanceSuggestionsBox(suggestions: [String]) -> some View {
        VStack(spacing: 0) {
            instanceField
            if !instance.isEmpty {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(suggestions, id: \.self) { text in
                            Divider()
                            Button {
                                instance = text
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
            text: $instance,
            prompt: Text("example.com")
        )
        .focused($focused)
        .keyboardType(.URL)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled()
        .scrollDismissesKeyboard(.never)
        .padding()
        .onTapGesture { focused = true }
        .onAppear { focused = true }
    }
    
    func geometryReaderBackground(geo: GeometryProxy) -> some View {
        DispatchQueue.main.async {
            scrollViewContentSize = geo.size
        }
        return Color.clear
    }
    
//    func checkInstanceValidity(domain: String) {
//        var domain = domain
//        if domain.contains(/.*\..+$/) {
//            if !domain.contains("://") {
//                domain = "https://\(domain)"
//            }
//            if let url = URL(string: domain) {
//                instanceValidity = .waiting
//                Task {
//                    let apiClient = ApiClient.getApiClient(for: url, with: nil)
//                    do {
//                        _ = try await apiClient.getSite()
//                        instanceValidity = .success
//                    } catch {
//                        instanceValidity = .failure
//                    }
//                }
//            }
//        }
//    }
    
    func attributedString(suggestion string: String) -> AttributedString {
        var attributedString = AttributedString(stringLiteral: string)
        attributedString.foregroundColor = .secondary
        if string.starts(with: instance) {
            let range = ..<attributedString.index(attributedString.startIndex, offsetByCharacters: instance.count)
            attributedString[range].foregroundColor = .primary
        }
        return attributedString
    }
}
