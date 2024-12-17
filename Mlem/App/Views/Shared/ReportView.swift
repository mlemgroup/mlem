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
    @Environment(Palette.self) var palette
    
    let report: Report
    
    var body: some View {
        targetView
            .buttonStyle(.empty)
            .background(palette.secondaryGroupedBackground)
            .clipShape(.rect(cornerRadius: Constants.main.standardSpacing))
            .environment(\.reportContext, report)
    }
    
    @ViewBuilder
    var targetView: some View {
        switch report.target {
        case let .post(post):
            NavigationLink(.post(post)) {
                FeedPostView(post: post, overridePostSize: .headline, favoredLink: .creator) { embeddedContent }
            }
        case let .comment(comment):
            NavigationLink(.comment(comment)) {
                FeedCommentView(comment: comment, overrideIsTiled: false) { embeddedContent }
            }
        case let .message(message):
            MessageView(message: message) { embeddedContent }
        case let .legacyPost(post, community: community, creator: creator):
            legacyPostView(post: post, community: community, creator: creator)
        case let .legacyComment(comment, community: community, creator: creator):
            legacyCommentView(comment: comment, community: community, creator: creator)
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
        .background(
            palette.warning.opacity(0.1),
            in: .rect(cornerRadius: Constants.main.standardSpacing)
        )
        if report.resolved, let resolver = report.resolver {
            Label("Resolved by \(resolver.fullName ?? "")", systemImage: Icons.successCircleFill)
                .foregroundStyle(palette.positive)
                .font(.footnote)
                .padding(.horizontal, Constants.main.halfSpacing)
        }
    }
    
    @ViewBuilder
    func legacyPostView(post: Post1, community: Community1, creator: Person1) -> some View {
        NavigationLink(.post(post)) {
            VStack(alignment: .leading, spacing: Constants.main.standardSpacing) {
                HStack {
                    FullyQualifiedLinkView(entity: creator, labelStyle: .medium, showAvatar: true)
                    Spacer()
                    resolveButton
                }
                HeadlinePostBodyView(post: post)
                embeddedContent
            }
            .padding(Constants.main.standardSpacing)
            .background(palette.secondaryGroupedBackground, in: .rect(cornerRadius: Constants.main.standardSpacing))
            .paletteBorder(cornerRadius: Constants.main.standardSpacing)
        }
    }
    
    @ViewBuilder
    func legacyCommentView(comment: Comment1, community: Community1, creator: Person1) -> some View {
        NavigationLink(.comment(comment)) {
            VStack(alignment: .leading, spacing: Constants.main.standardSpacing) {
                HStack {
                    FullyQualifiedLinkView(entity: creator, labelStyle: .medium, showAvatar: true)
                    Spacer()
                    resolveButton
                }
                Markdown(comment.content, configuration: .default)
                embeddedContent
            }
            .padding(Constants.main.standardSpacing)
            .background(palette.secondaryGroupedBackground, in: .rect(cornerRadius: Constants.main.standardSpacing))
            .paletteBorder(cornerRadius: Constants.main.standardSpacing)
        }
    }
    
    @ViewBuilder
    var resolveButton: some View {
        Button(
            report.resolved ? "Unresolve" : "Resolve",
            systemImage: report.resolved ? Icons.successCircleFill : Icons.successCircle
        ) {
            report.toggleResolved(feedback: [.haptic])
        }
        .foregroundStyle(palette.positive)
        .labelStyle(.iconOnly)
    }
}
