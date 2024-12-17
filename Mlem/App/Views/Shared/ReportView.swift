//
//  ReportView.swift
//  Mlem
//
//  Created by Sjmarf on 2024-12-16.
//

import MlemMiddleware
import SwiftUI

struct ReportView: View {
    @Environment(Palette.self) var palette
    
    let report: Report
    
    var body: some View {
        targetView
            .background(palette.secondaryGroupedBackground)
            .clipShape(.rect(cornerRadius: Constants.main.standardSpacing))
            .environment(\.reportContext, report)
    }
    
    @ViewBuilder
    var targetView: some View {
        switch report.target {
        case let .post(post as any Post1Providing), .legacyPost(let post as any Post1Providing, _, _):
            HeadlinePostView(post: post) { embeddedContent }
        case let .comment(comment as any Comment), .legacyComment(let comment as any Comment, _, _):
            CommentView(comment: comment) { embeddedContent }
        case let .message(message):
            MessageView(message: message)
        }
    }
    
    @ViewBuilder
    var embeddedContent: some View {
        VStack(alignment: .leading) {
            Text("Reported \(report.created.getRelativeTime()) by \(report.creator.fullName ?? "")")
                .foregroundStyle(.secondary) // No palette!
                .font(.footnote)
            Text(report.reason)
        }
        .foregroundStyle(palette.warning)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Constants.main.standardSpacing)
        .background(palette.warning.opacity(0.1), in: .rect(cornerRadius: Constants.main.standardSpacing))
    }
}
