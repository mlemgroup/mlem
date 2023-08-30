//
//  Error View.swift
//  Mlem
//
//  Created by David Bureš on 19.06.2022.
//

import SwiftUI
import UniformTypeIdentifiers
import Combine

struct ErrorDetails {
    var title: String?
    var body: String?
    var error: Error?
    var icon: String?
    var buttonText: String?
    var refresh: (() async -> Bool)?
    var autoRefresh: Bool = false
    
    static func mock() -> ErrorDetails {
        func callback() async -> Bool {
            try? await Task.sleep(nanoseconds: UInt64(1 * Double(NSEC_PER_SEC)))
            return false
        }
        
        enum MockError: Error {
            case mock
        }
        return ErrorDetails(error: MockError.mock, refresh: callback)
    }
}

struct ErrorView: View {
    @AppStorage("developerMode") var developerMode: Bool = false
    
    @State var errorDetails: ErrorDetails
    
    @State private var showingFullError: Bool = false
    @State private var refreshInProgress: Bool = false
    
    var timer = Timer.publish(every: 1, tolerance: 0.5, on: .main, in: .common)
        .autoconnect()
    
    init(_ errorDetails: ErrorDetails) {
        var errorDetails = errorDetails
        if !InternetConnectionManager.isConnectedToNetwork() {
            if errorDetails.title == nil {
                errorDetails.title = "You're offline"
                errorDetails.body = nil
                errorDetails.icon = "wifi.slash"
                errorDetails.autoRefresh = true
            }
        }
        _errorDetails = State(wrappedValue: errorDetails)
    }

    var body: some View {
        VStack(spacing: 15) {
            if showingFullError, let errorText = errorDetails.error?.localizedDescription {
                errorDetails(errorText)
            } else {
                if let icon = errorDetails.icon {
                    Image(systemName: icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 50)
                }
                Text(errorDetails.title ?? "Something went wrong.")
                    .font(.title3.bold())
                    .foregroundStyle(.primary)
                
                if let body = errorDetails.body { Text(body) }
                
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
                            Text(errorDetails.buttonText ?? "Try again")
                            if refreshInProgress {
                                ProgressView()
                            }
                        }
                    }
                    .buttonStyle(.bordered)
                    .animation(.default, value: refreshInProgress)
                }
            }
            
            if errorDetails.error != nil && (errorDetails.title == nil || developerMode) {
                Button("Show details") {
                    showingFullError.toggle()
                }
                .buttonStyle(.plain)
                .foregroundStyle(.tertiary)
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
                UIPasteboard.general.setValue(errorText,
                                              forPasteboardType: UTType.plainText.identifier)
            } label: {
                Label("Copy", systemImage: "square.on.square")
            }
            .buttonStyle(.plain)
        }
        .padding(10)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.smallItemCornerRadius))
    }
}
