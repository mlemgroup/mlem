//
//  ReportView.swift
//  Mlem
//
//  Created by Sjmarf on 2024-12-16.
//

import LemmyMarkdownUI
import MlemMiddleware
import SwiftUI

struct ReportView: View {
    @Environment(\.palette) var palette
    
    let report: Report
    
    var body: some View {
        targetView
            .buttonStyle(.empty)
            .environment(\.reportContext, report)
    }
    
    @ViewBuilder
    var targetView: some View {
        switch report.target {
        case let .post(post):
            NavigationLink(.post(post)) {
                FeedPostView(post: post, overridePostSize: .headline, favoredLink: .creator) {
                    reportDetailsView
                    resolutionInfoView
                }
            }
        case let .comment(comment):
            NavigationLink(.comment(comment, post: comment.post)) {
                FeedCommentView(comment: comment, overriddenSize: .large) {
                    reportDetailsView
                    resolutionInfoView
                }
            }
        case let .message(message):
            MessageView(message: message) {
                reportDetailsView
                resolveButton
            }
        }
    }
    
    @ViewBuilder
    var reportDetailsView: some View {
        VStack(alignment: .leading) {
            let reporterLabel = report.creator.nameTextView(
                showFlairs: false,
                showInstance: true,
                font: .footnote,
                palette: palette,
                nameColor: .themedWarning.opacity(0.5),
                instanceColor: .themedWarning.opacity(0.3)
            )
            Text("Reported \(report.created.getRelativeTime()) by \(reporterLabel)")
                .foregroundStyle(.secondary) // No palette!
                .font(.footnote)
                .lineLimit(1)
            Text(report.reason)
        }
        .foregroundStyle(.themedWarning)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Constants.main.standardSpacing)
        .background(
            .themedWarning.opacity(0.1),
            in: .rect(cornerRadius: Constants.main.standardSpacing)
        )
    }
    
    @ViewBuilder
    var resolutionInfoView: some View {
        if report.resolved, let resolver = report.resolver {
            let resolverLabel = resolver.nameTextView(
                showFlairs: false,
                showInstance: true,
                font: .footnote,
                palette: palette,
                nameColor: .themedPositive,
                instanceColor: .themedPositive.opacity(0.5)
            )
            Label("Resolved by \(resolverLabel)", icon: .general.success)
                .foregroundStyle(.themedPositive)
                .symbolVariant(.circle.fill)
                .font(.footnote)
                .padding(.horizontal, Constants.main.halfSpacing)
                .lineLimit(1)
        }
    }
    
    // TODO: NOW
    @ViewBuilder
    func legacyPostView(post: Post1, community: Community1, creator: Person1) -> some View {
        Text("TODO")
//        NavigationLink(.post(post)) {
//            VStack(alignment: .leading, spacing: Constants.main.standardSpacing) {
//                FullyQualifiedLinkView(creator, labelStyle: .medium)
//                HeadlinePostBodyView(post: post)
//                reportDetailsView
//                resolveButton
//            }
//            .padding(Constants.main.standardSpacing)
//            .background(.themedSecondaryGroupedBackground, in: .rect(cornerRadius: Constants.main.standardSpacing))
//            .paletteBorder(cornerRadius: Constants.main.standardSpacing)
//        }
    }
    
    @ViewBuilder
    var resolveButton: some View {
        HStack {
            Button(
                report.resolved ? "Resolved" : "Resolve",
                systemImage: Icons.success
            ) {
                report.toggleResolved(feedback: [.haptic])
            }
            .foregroundStyle(report.resolved ? .themedContrastingLabel : .themedPrimary)
            .padding(.vertical, 3)
            .padding(.horizontal, 8)
            .imageScale(.small)
            .background(
                report.resolved ? .themedPositive : .themedTertiaryGroupedBackground,
                in: .rect(cornerRadius: Constants.main.standardSpacing)
            )
            if report.resolved, let resolver = report.resolver {
                Text("by \(resolver.fullName)")
                    .foregroundStyle(.themedPositive)
            }
        }
        .font(.footnote)
    }
}
