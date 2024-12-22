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
                FeedPostView(post: post, overridePostSize: .headline, favoredLink: .creator) {
                    reportDetailsView
                    resolutionInfoView
                }
            }
        case let .comment(comment):
            NavigationLink(.comment(comment)) {
                FeedCommentView(comment: comment, overriddenSize: .large) {
                    reportDetailsView
                    resolutionInfoView
                }
            }
        case let .message(message):
            MessageView(message: message) {
                reportDetailsView
                if (message.api.fetchedVersion ?? .infinity) < .v19_4 {
                    resolveButton
                } else {
                    resolutionInfoView
                }
            }
        case let .legacyPost(post, community: community, creator: creator):
            legacyPostView(post: post, community: community, creator: creator)
        case let .legacyComment(comment, community: community, creator: creator):
            legacyCommentView(comment: comment, community: community, creator: creator)
        }
    }
    
    @ViewBuilder
    var reportDetailsView: some View {
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
    }
    
    @ViewBuilder
    var resolutionInfoView: some View {
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
                FullyQualifiedLinkView(entity: creator, labelStyle: .medium, showAvatar: true)
                HeadlinePostBodyView(post: post)
                reportDetailsView
                resolveButton
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
                FullyQualifiedLinkView(entity: creator, labelStyle: .medium, showAvatar: true)
                Markdown(comment.content, configuration: .default)
                reportDetailsView
                resolveButton
            }
            .padding(Constants.main.standardSpacing)
            .background(palette.secondaryGroupedBackground, in: .rect(cornerRadius: Constants.main.standardSpacing))
            .paletteBorder(cornerRadius: Constants.main.standardSpacing)
        }
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
            .foregroundStyle(report.resolved ? palette.selectedInteractionBarItem : palette.primary)
            .padding(.vertical, 3)
            .padding(.horizontal, 8)
            .imageScale(.small)
            .background(
                report.resolved ? palette.positive : palette.tertiaryGroupedBackground,
                in: .rect(cornerRadius: Constants.main.standardSpacing)
            )
            if report.resolved, let resolver = report.resolver {
                Text("by \(resolver.fullName ?? "")")
                    .foregroundStyle(palette.positive)
            }
        }
        .font(.footnote)
    }
}
