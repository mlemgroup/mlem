//
//  InstanceStatsView.swift
//  Mlem
//
//  Created by Sjmarf on 20/01/2024.
//

import MlemMiddleware
import SwiftUI

struct InstanceDetailsView: View {
    @Environment(Palette.self) private var palette
    
    @State private var showingSlurRegex: Bool = false
    
    let instance: any Instance
    
    var body: some View {
        VStack(spacing: 16) {
            box {
                HStack {
                    Label(instance.created.dateString, systemImage: Icons.cakeDay)
                    Text(verbatim: "•")
                    Label(instance.created.getRelativeTime(unitsStyle: .abbreviated), systemImage: Icons.time)
                }
                .foregroundStyle(palette.secondary)
                .font(.footnote)
            }
            HStack(spacing: 16) {
                box {
                    Text("Users")
                        .foregroundStyle(palette.secondary)
                    Text((instance.userCount_ ?? 0).abbreviated)
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundStyle(palette.userAccent)
                }
                
                box {
                    Text("Communities")
                        .foregroundStyle(palette.secondary)
                    Text((instance.communityCount_ ?? 0).abbreviated)
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundStyle(palette.communityAccent)
                }
            }
            .frame(maxWidth: .infinity)
            
            HStack(spacing: 16) {
                box {
                    Text("Posts")
                        .foregroundStyle(palette.secondary)
                    Text((instance.postCount_ ?? 0).abbreviated)
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundStyle(palette.postAccent)
                }
                
                box {
                    Text("Comments")
                        .foregroundStyle(palette.secondary)
                    Text((instance.commentCount_ ?? 0).abbreviated)
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundStyle(palette.commentAccent)
                }
            }
            .frame(maxWidth: .infinity)
            
            if let activeUserCount = instance.activeUserCount_ {
                box(spacing: 8) {
                    Text("Active Users")
                        .foregroundStyle(palette.secondary)
                    HStack(spacing: 16) {
                        activeUserBox("6mo", value: activeUserCount.sixMonths)
                        activeUserBox("1mo", value: activeUserCount.month)
                        activeUserBox("1w", value: activeUserCount.week)
                        activeUserBox("1d", value: activeUserCount.day)
                    }
                }
            }
            VStack(alignment: .leading, spacing: 0) {
                settingRow(
                    "Private",
                    systemImage: Icons.private,
                    value: instance.isPrivate_ ?? false
                )
                Divider()
                settingRow(
                    "Federates",
                    systemImage: Icons.federation,
                    value: instance.federationEnabled_ ?? false
                )
            }
            .frame(maxWidth: .infinity)
            .background(palette.secondaryGroupedBackground)
            .cornerRadius(Constants.main.mediumItemCornerRadius)
            
            VStack(alignment: .leading, spacing: 0) {
                settingRow(
                    "Registration",
                    systemImage: Icons.person,
                    value: instance.registrationMode_?.label ?? "Closed",
                    color: instance.registrationMode_?.color ?? palette.negative
                )
                if instance.registrationMode_ != .closed {
                    Divider()
                    settingRow(
                        "Email Verification",
                        systemImage: Icons.email,
                        value: instance.emailVerificationRequired_ ?? false
                    )
                    Divider()
                    settingRow(
                        "Captcha",
                        systemImage: Icons.photo,
                        value: captchaLabel,
                        color: instance.captchaDifficulty_ == nil ? palette.negative : palette.positive
                    )
                }
            }
            .frame(maxWidth: .infinity)
            .background(palette.secondaryGroupedBackground)
            .cornerRadius(Constants.main.mediumItemCornerRadius)
            
            VStack(alignment: .leading, spacing: 0) {
                settingRow(
                    "NSFW Content",
                    systemImage: Icons.blurNsfw,
                    value: instance.nsfwContentEnabled_ ?? false
                )
                Divider()
                settingRow(
                    "Downvotes",
                    systemImage: Icons.downvote,
                    value: instance.downvotesEnabled_ ?? false
                )
                Divider()
                settingRow(
                    "Community Creation",
                    systemImage: "house",
                    value: !(instance.communityCreationRestrictedToAdmins_ ?? false)
                )
                Divider()
                settingRow(
                    "Slur Filter",
                    systemImage: Icons.filterFill,
                    value: instance.slurFilterRegex_ != nil
                )
                if let regex = instance.slurFilterRegex_ {
                    Divider()
                    VStack(alignment: .leading, spacing: 2) {
                        if showingSlurRegex {
                            Text(regex)
                                .foregroundStyle(palette.secondary)
                                .textSelection(.enabled)
                        } else {
                            Text("Tap to show slur filter regex.")
                            Label(
                                "This probably contains foul language.",
                                systemImage: Icons.warning
                            )
                            .foregroundStyle(palette.caution)
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
                if let feedType = instance.defaultFeed_ {
                    Divider()
                    settingRow(
                        "Default Feed Type (Desktop)",
                        systemImage: Icons.feeds,
                        value: feedType.label
                    )
                }
            }
            .frame(maxWidth: .infinity)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .cornerRadius(Constants.main.mediumItemCornerRadius)
            
            VStack(alignment: .leading, spacing: 0) {
                settingRow(
                    "Show Mod Names in Modlog",
                    systemImage: Icons.moderation,
                    value: !(instance.hideModlogNames_ ?? true)
                )
                Divider()
                settingRow(
                    "Applications Email Admins",
                    systemImage: Icons.person,
                    value: instance.emailApplicationsToAdmins_ ?? false
                )
                Divider()
                settingRow(
                    "Reports Email Admins",
                    systemImage: Icons.moderationReport,
                    value: instance.emailReportsToAdmins_ ?? false
                )
            }
            .frame(maxWidth: .infinity)
            .background(palette.secondaryGroupedBackground)
            .cornerRadius(Constants.main.mediumItemCornerRadius)
        }
        .padding(.horizontal, 16)
    }
    
    var captchaLabel: LocalizedStringResource {
        if let diff = instance.captchaDifficulty_ {
            return "Yes (\(diff.rawValue.capitalized))"
        }
        return "No"
    }
    
    @ViewBuilder func box(spacing: CGFloat = 5, @ViewBuilder content: () -> some View) -> some View {
        VStack(spacing: spacing) {
            content()
        }
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(palette.secondaryGroupedBackground)
        .cornerRadius(Constants.main.mediumItemCornerRadius)
    }
    
    @ViewBuilder func settingRow(
        _ label: LocalizedStringResource,
        systemImage: String,
        value: LocalizedStringResource,
        color: Color? = nil
    ) -> some View {
        HStack {
            Image(systemName: systemImage)
                .foregroundStyle(palette.secondary)
                .frame(width: 30)
            Text(label)
            Spacer()
            Text(value)
                .foregroundStyle(color ?? palette.primary)
        }
        .padding(12)
    }
    
    @ViewBuilder func settingRow(_ label: LocalizedStringResource, systemImage: String, value: Bool) -> some View {
        HStack {
            Image(systemName: systemImage)
                .foregroundStyle(palette.secondary)
                .frame(width: 30)
            Text(label)
            Spacer()
            Text(value ? "Yes" : "No")
                .foregroundStyle(value ? palette.positive : palette.negative)
        }
        .padding(12)
    }
    
    @ViewBuilder
    func activeUserBox(_ label: LocalizedStringResource, value: Int) -> some View {
        VStack {
            Text(value.abbreviated)
                .font(.title3)
                .fontWeight(.semibold)
            Text(label)
                .foregroundStyle(palette.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

private extension ApiRegistrationMode {
    var label: LocalizedStringResource {
        switch self {
        case .closed: "Closed"
        case .requireApplication: "Requires Application"
        case .open: "Open"
        }
    }
    
    var color: Color {
        switch self {
        case .closed:
            return Palette.main.negative
        case .requireApplication:
            return Palette.main.caution
        case .open:
            return Palette.main.positive
        }
    }
}
