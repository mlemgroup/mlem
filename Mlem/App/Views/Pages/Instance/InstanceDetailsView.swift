//
//  InstanceStatsView.swift
//  Mlem
//
//  Created by Sjmarf on 20/01/2024.
//

import Icons
import MlemMiddleware
import SwiftUI
import Theming

// swiftlint:disable:next type_body_length
struct InstanceDetailsView: View {
    @State private var showingSlurRegex: Bool = false
    @State var uptimeData: UptimeDataStatus?
    
    let instance: Instance
    
    var body: some View {
        content
            .task {
                let fetchedData = await loadUptimeData(instance: instance)
                withAnimation(.easeOut(duration: 0.2)) {
                    uptimeData = fetchedData
                }
            }
    }
    
    var content: some View {
        VStack(spacing: 16) {
            if instance.api.supports(.viewInstanceCreationDate, defaultValue: true) {
                FormSection {
                    ProfileDateView(profilable: instance)
                        .padding(.vertical, Constants.main.standardSpacing)
                }
            }
            
            statsView
            
            FormSection {
                if case let .success(uptimeData) = uptimeData {
                    NavigationLink(.instanceUptime(instance, uptimeData: uptimeData)) {
                        uptimeSummary
                    }
                    .buttonStyle(.plain)
                } else {
                    uptimeSummary
                }
            }
            
            if instance.api.supports(.viewInstanceSettings, defaultValue: true) {
                settingsListView
            }
        }
        .padding([.horizontal, .bottom], 16)
    }
    
    @ViewBuilder
    var statsView: some View {
        HStack(spacing: 16) {
            ExpectedView(instance.userCount) { userCount in
                FormReadout("Users", value: userCount)
                    .tint(.themedPersonAccent)
            }
            ExpectedView(instance.communityCount) { communityCount in
                FormReadout("Communities", value: communityCount)
                    .tint(.themedCommunityAccent)
            }
        }
        .frame(maxWidth: .infinity)
        
        HStack(spacing: 16) {
            ExpectedView(instance.postCount) { postCount in
                FormReadout("Posts", value: postCount)
                    .tint(.themedPostAccent)
            }
            ExpectedView(instance.commentCount) { commentCount in
                FormReadout("Comments", value: commentCount)
                    .tint(.themedCommentAccent)
            }
        }
        .frame(maxWidth: .infinity)
        
        ExpectedView(instance.activeUserCount) { activeUserCount in
            ActiveUserCountView(activeUserCount: activeUserCount)
        }
    }
    
    @ViewBuilder
    var settingsListView: some View {
        FormSection {
            VStack(alignment: .leading, spacing: 0) {
                ExpectedView(instance.isPrivate) { isPrivate in
                    settingRow(
                        "Private",
                        icon: .lemmy.private,
                        value: isPrivate
                    )
                }
                Divider()
                ExpectedView(instance.federationEnabled) { federationEnabled in
                    settingRow(
                        "Federates",
                        icon: .lemmy.federation,
                        value: federationEnabled
                    )
                }
            }
        }
        
        FormSection {
            ExpectedView(instance.registrationMode) { registrationMode in
                VStack(alignment: .leading, spacing: 0) {
                    settingRow(
                        "Registration",
                        icon: .lemmy.person,
                        value: registrationMode.label,
                        color: registrationMode.color
                    )
                    if registrationMode != .closed {
                        Divider()
                        ExpectedView(instance.emailVerificationRequired) { emailVerificationRequired in
                            settingRow(
                                "Email Verification",
                                icon: .general.email,
                                value: emailVerificationRequired
                            )
                        }
                        Divider()
                        ExpectedView(instance.captchaDifficulty) { captchaDifficulty in
                            settingRow(
                                "Captcha",
                                icon: .lemmy.captcha,
                                value: captchaLabel(for: captchaDifficulty),
                                color: captchaDifficulty == nil ? .themedNegative : .themedPositive
                            )
                        }
                    }
                }
            }
        }

        FormSection {
            ExpectedView(instance.voteFederationMode) { voteMode in
                VStack(alignment: .leading, spacing: 0) {
                    voteFederationRow(
                        "Post Upvotes",
                        type: .upvote,
                        value: voteMode.postUpvote
                    )
                    Divider()
                    voteFederationRow(
                        "Post Downvotes",
                        type: .downvote,
                        value: voteMode.postDownvote
                    )
                    Divider()
                    voteFederationRow(
                        "Comment Upvotes",
                        type: .upvote,
                        value: voteMode.commentUpvote
                    )
                    Divider()
                    voteFederationRow(
                        "Comment Downvotes",
                        type: .downvote,
                        value: voteMode.commentDownvote
                    )
                }
            }
        }
        
        FormSection {
            VStack(alignment: .leading, spacing: 0) {
                ExpectedView(instance.nsfwContentEnabled) { nsfwContentEnabled in
                    settingRow(
                        "NSFW Content",
                        icon: .settings.blurNsfw,
                        value: nsfwContentEnabled
                    )
                }
                Divider()
                ExpectedView(instance.communityCreationRestrictedToAdmins) { communityCreationRestrictedToAdmins in
                    settingRow(
                        "Community Creation",
                        icon: .lemmy.community,
                        value: !communityCreationRestrictedToAdmins
                    )
                }
                Divider()
                ExpectedView(instance.slurFilterRegex) { slurFilterRegex in
                    Group {
                        settingRow(
                            "Slur Filter",
                            icon: .general.filter,
                            value: slurFilterRegex != nil
                        )
                        if let slurFilterRegex {
                            Divider()
                            VStack(alignment: .leading, spacing: 2) {
                                if showingSlurRegex {
                                    Text(slurFilterRegex)
                                        .foregroundStyle(.themedSecondary)
                                        .textSelection(.enabled)
                                } else {
                                    Text("Tap to show slur filter regex.")
                                    Label(
                                        "This probably contains foul language.",
                                        icon: .general.warning
                                    )
                                    .foregroundStyle(.themedCaution)
                                }
                            }
                            .font(.footnote)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                            .contentShape(.rect)
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    showingSlurRegex.toggle()
                                }
                            }
                        }
                    }
                }
                Divider()
                ExpectedView(instance.defaultFeed) { defaultFeed in
                    settingRow(
                        "Default Feed Type (Desktop)",
                        icon: .lemmy.feed,
                        value: defaultFeed.label
                    )
                }
            }
        }
        
        FormSection {
            VStack(alignment: .leading, spacing: 0) {
                ExpectedView(instance.hideModlogNames) { hideModlogNames in
                    settingRow(
                        "Show Mod Names in Modlog",
                        icon: .lemmy.moderation,
                        value: !hideModlogNames
                    )
                }
                Divider()
                ExpectedView(instance.emailApplicationsToAdmins) { emailApplicationsToAdmins in
                    settingRow(
                        "Applications Email Admins",
                        icon: .lemmy.registrationApplication,
                        value: emailApplicationsToAdmins
                    )
                }
                Divider()
                ExpectedView(instance.emailReportsToAdmins) { emailReportsToAdmins in
                    settingRow(
                        "Reports Email Admins",
                        icon: .lemmy.report,
                        value: emailReportsToAdmins
                    )
                }
            }
        }
    }

    @ViewBuilder
    func settingRow(
        _ label: LocalizedStringResource,
        icon: Icon,
        value: LocalizedStringResource,
        color: ThemedColor? = nil
    ) -> some View {
        HStack {
            Image(icon: icon)
                .foregroundStyle(.themedSecondary)
                .frame(width: 30)
            Text(label)
            Spacer()
            Text(value)
                .foregroundStyle(color ?? .themedPrimary)
        }
        .padding(12)
    }
    
    func captchaLabel(for diff: CaptchaDifficulty?) -> LocalizedStringResource {
        if let diff {
            return .init(
                "Captcha Difficulty Yes",
                defaultValue: "Yes (\(diff.label))",
                comment: "Used to indicate Captcha difficulty. E.g. \"Yes (Hard)\"."
            )
        }
        return "No"
    }

    @ViewBuilder
    func settingRow(_ label: LocalizedStringResource, icon: Icon, value: Bool) -> some View {
        settingRow(
            label,
            icon: icon,
            value: value ? "Yes" : "No",
            color: value ? .themedPositive : .themedNegative
        )
    }

    @ViewBuilder
    func voteFederationRow(
        _ label: LocalizedStringResource,
        type: ScoringOperation,
        value: FederationMode
    ) -> some View {
        settingRow(
            label,
            icon: type.icon,
            value: value.label,
            color: value.color
        )
    }
    
    @ViewBuilder
    var uptimeSummary: some View {
        VStack(spacing: Constants.main.standardSpacing) {
            HStack {
                Text("Uptime")
                
                Spacer()
                
                if case .success = uptimeData {
                    (Text("Details") + Text(verbatim: " ") + Text(Image(icon: .general.forward)))
                        .font(.footnote)
                        .foregroundStyle(.themedAccent)
                }
            }
            
            switch uptimeData {
            case let .success(uptimeData):
                RecentUptimeChecks(results: uptimeData.results)
            case .unavailable:
                Text("Data not available")
                    .italic()
                    .foregroundStyle(.themedWarning)
                    .frame(maxWidth: .infinity, alignment: .leading)
            case let .failure(error):
                ErrorView(.init(error: error))
            default:
                ProgressView()
                    .padding(Constants.main.halfSpacing)
            }
        }
        .padding(Constants.main.standardSpacing)
    }
}
