//
//  NewSearchSheet.swift
//  Mlem
//
//  Created by Sjmarf on 2025-06-27.
//

import ComponentViews
import MlemMiddleware
import SwiftUI
import SwiftUIIntrospect

struct NewSearchSheet<Model: Hashable, Content: View>: View {
    @Environment(AppState.self) var appState
    @Environment(NavigationLayer.self) var navigation
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.palette) var palette
    @Environment(\.dismiss) var dismiss
    
    let callback: (Model) -> Void
    let loadContent: (String) async throws -> [Model]
    let content: (Model) -> Content
    
    init(
        callback: @escaping (Model) -> Void,
        loadContent: @escaping (String) async throws -> [Model],
        @ViewBuilder content: @escaping (Model) -> Content
    ) {
        self.callback = callback
        self.loadContent = loadContent
        self.content = content
    }
    
    @State var fadeIn: Bool = false
    @State var query: String = ""
    @State var results: [Model] = []
    
    @State var backgroundAccent: Color = .clear
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 60)
                Text("Results")
                    .foregroundStyle(.themedSecondary)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 16)
                    .padding(.bottom, 5)
                resultsView
                Spacer()
                    .frame(height: 70)
            }
        }
        .scrollIndicators(.hidden)
        .mask {
            VStack(spacing: 0) {
                Color.clear
                    .frame(height: 30)
                LinearGradient(colors: [.clear, .white], startPoint: .top, endPoint: .bottom)
                    .frame(height: 30)
                Color.white
                LinearGradient(colors: [.white, .clear], startPoint: .top, endPoint: .bottom)
                    .frame(height: 30)
                Color.clear
                    .frame(height: 30)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .bottom) {
            overlayView
                .scaleEffect(fadeIn ? 1 : 0.9)
                .padding(16)
        }
        .overlay(alignment: .topTrailing) {
            CloseButtonView(callback: closeSheet)
                .padding(.horizontal, 16)
        }
        .compositingGroup()
        .opacity(fadeIn ? 1 : 0)
        .onAppear {
            if !fadeIn {
                backgroundAccent = palette.colorfulAccents.randomElement() ?? palette.accent
                withAnimation(.easeOut(duration: 0.2)) {
                    fadeIn = true
                }
            }
        }
        .background {
            LinearGradient(
                colors: [.clear, backgroundAccent.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .background(.background)
            .ignoresSafeArea(.container)
            .opacity(fadeIn ? 1 : 0)
        }
        .presentationBackground(.clear)
        .task(id: query) {
            do {
                results = try await loadContent(query)
            } catch {
                handleError(error)
            }
        }
    }
    
    @ViewBuilder
    var resultsView: some View {
        VStack(spacing: 0) {
            ForEach(Array(results.enumerated()), id: \.element) { index, result in
                content(result)
                    .padding(8)
                    .background {
                        if index == 0 {
                            if colorScheme == .dark {
                                Capsule().fill(.ultraThinMaterial)
                            } else {
                                Capsule().fill(.themedSecondaryGroupedBackground)
                            }
                        }
                    }
                    .compositingGroup()
                    .shadow(color: .black.opacity(index == 0 ? 0.1 : 0), radius: 2)
                if index != 0 {
                    Divider()
                        .padding(.leading, 48)
                }
            }
            .id(results)
        }
        .padding(.horizontal, 16)
        .animation(.easeOut(duration: 0.2), value: results)
        .tint(backgroundAccent)
    }
    
    @ViewBuilder
    var overlayView: some View {
        HStack(spacing: 16) {
            HStack {
                Image(icon: .general.search)
                    .foregroundStyle(.secondary)
                TextField("Search", text: $query)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .submitLabel(.done)
                    .onSubmit {
                        if !query.isEmpty, let first = results.first {
                            callback(first)
                        }
                        closeSheet()
                    }
                    .introspect(.textField, on: .iOS(.v18)) { textField in
                        Task.detached { @MainActor in
                            if !textField.isFirstResponder {
                                textField.becomeFirstResponder()
                            }
                        }
                    }
            }
            .onAppear {
                DispatchQueue.main.async {
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.becomeFirstResponder),
                        to: nil,
                        from: nil,
                        for: nil
                    )
                }
            }
            .frame(height: 50)
            .padding(.horizontal)
            .background {
                if colorScheme == .dark {
                    Capsule().fill(.regularMaterial)
                } else {
                    Capsule().fill(.themedSecondaryGroupedBackground)
                }
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .compositingGroup()
        .shadow(color: .black.opacity(0.2), radius: 15)
    }

    func closeSheet() {
        var transaction = Transaction()
        transaction.animation = .easeOut(duration: 0.2)
        transaction.addAnimationCompletion {
            navigation.dismissSheet()
        }
        withTransaction(transaction) {
            fadeIn = false
        }
    }
}
