//
//  Error View.swift
//  Mlem
//
//  Created by David Bureš on 19.06.2022.
//

import Combine
import MlemMiddleware
import SwiftUI
import UniformTypeIdentifiers

struct ErrorView: View {
    @Environment(Palette.self) var palette
    @Setting(\.developerMode) var developerMode
    
    @State var errorDetails: ErrorDetails
    
    @State private var showingFullError: Bool = false
    @State private var refreshInProgress: Bool = false
    
    var timer = Timer.publish(every: 1, tolerance: 0.5, on: .main, in: .common)
        .autoconnect()
    
    init(_ errorDetails: ErrorDetails) {
        _errorDetails = State(wrappedValue: errorDetails)
    }

    var body: some View {
        VStack(spacing: 15) {
            if showingFullError {
                if let error = errorDetails.error {
                    if let error = error as? ApiClientError {
                        errorDetails(error.description)
                    } else {
                        errorDetails(error.localizedDescription)
                    }
                }
            } else {
                if let systemImage = errorDetails.systemImage {
                    Image(systemName: systemImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 50)
                }
                Text(errorDetails.title ?? "Something went wrong.")
                    .font(.title3.bold())
                    .foregroundStyle(palette.primary)
                
                if let body = errorDetails.body {
                    Text(body)
                        .multilineTextAlignment(.center)
                }
                
                if !errorDetails.autoRefresh, let refresh = errorDetails.refresh {
                    Button {
                        Task {
                            refreshInProgress = true
                            if await refresh() {
                                timer.upstream.connect().cancel()
                            }
                            refreshInProgress = false
                        }
                    } label: {
                        HStack(spacing: 10) {
                            Text(errorDetails.buttonText ?? "Try Again")
                            if refreshInProgress {
                                ProgressView()
                            }
                        }
                    }
                    .tint(palette.secondary)
                    .buttonStyle(.bordered)
                    .animation(.default, value: refreshInProgress)
                }
            }
            
            if errorDetails.error != nil, errorDetails.title == nil || developerMode {
                Button("Show Details") {
                    showingFullError.toggle()
                }
                .buttonStyle(.plain)
                .foregroundStyle(palette.tertiary)
            }
        }
        .padding()
        .foregroundColor(.secondary)
        .onDisappear {
            timer.upstream.connect().cancel()
        }
        
        .onReceive(timer) { _ in
            if errorDetails.autoRefresh, let refresh = errorDetails.refresh {
                Task {
                    if await refresh() {
                        timer.upstream.connect().cancel()
                    }
                }
            }
        }
        
        .animation(.default, value: showingFullError)
        .padding()
    }
        
    @ViewBuilder
    func errorDetails(_ errorText: String) -> some View {
        VStack {
            Text(errorText)
                .foregroundStyle(.red)
            Divider()
            Button {
                UIPasteboard.general.setValue(
                    errorText,
                    forPasteboardType: UTType.plainText.identifier
                )
            } label: {
                Label("Copy", systemImage: "square.on.square")
            }
            .buttonStyle(.plain)
        }
        .padding(Constants.main.standardSpacing)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: Constants.main.smallItemCornerRadius))
    }
}
