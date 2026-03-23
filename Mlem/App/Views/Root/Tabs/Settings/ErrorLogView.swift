//
//  ErrorLogView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-12-29.
//

import Rest
import SwiftUI
import Theming

struct ErrorLogView: View {
    @Environment(ErrorsTracker.self) var errorsTracker
    @Environment(NavigationLayer.self) var navigation
    
    var body: some View {
        FancyScrollView {
            LazyVStack(spacing: Constants.main.standardSpacing) {
                if errorsTracker.errors.isEmpty {
                    Text(verbatim: "No errors")
                        .foregroundStyle(.themedSecondary)
                }
                ForEach(Array(errorsTracker.errors.enumerated()), id: \.offset) { _, errorDetails in
                    errorView(errorDetails)
                }
                .padding(.horizontal, Constants.main.standardSpacing)
            }
        }
        .themedGroupedBackground()
        .navigationTitle(String("Error Log"))
        .toolbar {
            if !errorsTracker.errors.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            if let url = await downloadTextToFileSystem(
                                fileName: "mlem_error_log.txt",
                                text: errorsTracker.createErrorLog()
                            ) {
                                navigation.model?.shareInfo = .init(url: url)
                            } else {
                                ToastModel.main.add(.failure(String("Failed to share error log")))
                            }
                        }
                    } label: {
                        Image(icon: .general.share)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func errorView(_ details: ErrorDetails) -> some View {
        VStack(alignment: .leading, spacing: Constants.main.standardSpacing) {
            HStack {
                Text(details.title ?? "Error")
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button {
                    UIPasteboard.general.string = details.errorText()
                    ToastModel.main.add(.success(String("Copied")))
                } label: {
                    Text(Image(icon: .general.copy))
                        .font(.subheadline)
                        .foregroundStyle(.themedAccent)
                }
            }
            
            Text(details.errorText(includingLocation: false))
                .font(.caption)
                .monospaced()
            
            if let location = details.location {
                HStack(alignment: .top, spacing: 2) {
                    Image(systemName: "arrow.turn.down.right")
                        .offset(y: 2)
                    
                    Text(location)
                        .monospaced()
                }
                .font(.caption)
            }
            
            Text(details.when.formatted(date: .abbreviated, time: .standard))
                .font(.caption)
                .foregroundStyle(.themedSecondary)
        }
        .padding(Constants.main.standardSpacing)
        .background(.themedSecondaryGroupedBackground)
        .clipShape(.rect(cornerRadius: Constants.main.mediumItemCornerRadius))
    }
}
