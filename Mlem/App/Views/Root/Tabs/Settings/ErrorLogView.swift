//
//  ErrorLogView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-12-29.
//

import SwiftUI

struct ErrorLogView: View {
    @Environment(ErrorsTracker.self) var errorsTracker
    @Environment(Palette.self) var palette
    @Environment(NavigationLayer.self) var navigation
    
    var body: some View {
        FancyScrollView {
            LazyVStack(spacing: Constants.main.standardSpacing) {
                if errorsTracker.errors.isEmpty {
                    Text(verbatim: "No errors")
                        .foregroundStyle(palette.secondary)
                }
                ForEach(Array(errorsTracker.errors.enumerated()), id: \.offset) { _, errorDetails in
                    errorView(errorDetails)
                }
                .padding(.horizontal, Constants.main.standardSpacing)
            }
        }
        .background(palette.groupedBackground)
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
                                navigation.shareInfo = .init(url: url)
                            } else {
                                ToastModel.main.add(.failure(String("Failed to share error log")))
                            }
                        }
                    } label: {
                        Image(systemName: Icons.share)
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
                    if let text = details.error?.localizedDescription {
                        UIPasteboard.general.string = text
                        ToastModel.main.add(.success(String("Copied")))
                    }
                } label: {
                    Text(Image(systemName: Icons.copy))
                        .font(.subheadline)
                        .foregroundStyle(palette.accent)
                }
            }
            
            Text(details.errorText)
            
            Text(details.when.formatted(date: .abbreviated, time: .standard))
                .font(.caption)
                .foregroundStyle(palette.secondary)
        }
        .padding(Constants.main.standardSpacing)
        .background(palette.secondaryGroupedBackground)
        .clipShape(.rect(cornerRadius: Constants.main.mediumItemCornerRadius))
    }
}
