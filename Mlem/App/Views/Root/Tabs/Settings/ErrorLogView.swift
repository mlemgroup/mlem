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
    
    var body: some View {
        FancyScrollView {
            LazyVStack(spacing: Constants.main.standardSpacing) {
                ForEach(Array(errorsTracker.errors.enumerated()), id: \.offset) { _, errorDetails in
                    errorView(errorDetails)
                }
            }
            .padding(.horizontal, Constants.main.standardSpacing)
        }
        .background(palette.groupedBackground)
    }
    
    @ViewBuilder
    func errorView(_ details: ErrorDetails) -> some View {
        VStack(alignment: .leading, spacing: Constants.main.standardSpacing) {
            // TODO: Copy
            Text(details.title ?? "Error")
                .fontWeight(.semibold)
            
            Text(details.errorText)
            
            // TODO: more human format
            Text(details.when.formatted(.iso8601))
                .font(.caption)
                .foregroundStyle(palette.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(Constants.main.standardSpacing)
        .background(palette.secondaryGroupedBackground)
        .clipShape(.rect(cornerRadius: Constants.main.smallItemCornerRadius))
    }
}
