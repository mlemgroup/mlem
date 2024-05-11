//
//  InstanceField.swift
//  Mlem
//
//  Created by Sjmarf on 10/05/2024.
//

import Combine
import MlemMiddleware
import SwiftUI

struct InstanceField: View {
    // Temporary - before 2.0 release this should be a list of all major instances
    let suggestions: [String] = [
        "lemmy.ml",
        "sh.itjust.works",
        "lemmy.world",
        "literature.cafe",
        "lemmy.ca",
        "startrek.site"
    ]
    
    @Binding var instance: String
    @Binding var instanceValidity: LandingPage.InstanceValidationProgress
    
    @State private var scrollViewContentSize: CGSize = .zero
    @FocusState private var focused: Bool
    
    @State private var relay = PassthroughSubject<String, Never>()
    @State private var debouncedPublisher: AnyPublisher<String, Never>
    
    init(instance: Binding<String>, instanceValidity: Binding<LandingPage.InstanceValidationProgress>) {
        self._instance = instance
        self._instanceValidity = instanceValidity
        let relay = PassthroughSubject<String, Never>()
        self._relay = .init(wrappedValue: relay)
        self._debouncedPublisher = .init(wrappedValue: relay
            .debounce(for: 0.3, scheduler: RunLoop.main)
            .eraseToAnyPublisher()
        )
    }
    
    var body: some View {
        VStack(spacing: 0) {
            instanceField()
            if !instance.isEmpty {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(suggestions.filter { $0.starts(with: instance) && $0 != instance }, id: \.self) { text in
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
    func instanceField() -> some View {
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
        .onChange(of: instance) {
            print("CHANGEOF")
            instanceValidity = .debouncing
            relay.send(instance)
        }
        .overlay(alignment: .trailing) {
            Group {
                switch instanceValidity {
                case .success:
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                case .failure:
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.red)
                case .waiting:
                    ProgressView()
                case .debouncing:
                    EmptyView()
                }
            }
            .padding(.trailing)
            .transition(.opacity)
        }
        .animation(.easeOut(duration: 0.1), value: instanceValidity)
        .onReceive(debouncedPublisher, perform: checkInstanceValidity)
    }
    
    func geometryReaderBackground(geo: GeometryProxy) -> some View {
        DispatchQueue.main.async {
            scrollViewContentSize = geo.size
        }
        return Color.clear
    }
    
    func checkInstanceValidity(domain: String) {
        var domain = domain
        if domain.contains(/.*\..+$/) {
            if !domain.contains("://") {
                domain = "https://\(domain)"
            }
            if let url = URL(string: domain) {
                instanceValidity = .waiting
                Task {
                    let apiClient = ApiClient.getApiClient(for: url, with: nil)
                    do {
                        _ = try await apiClient.getSite()
                        instanceValidity = .success
                    } catch {
                        instanceValidity = .failure
                    }
                }
            }
        }
    }
    
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
