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
            FormSection {
                ProfileDateView(profilable: instance)
                    .padding(.vertical, Constants.main.standardSpacing)
            }
            
            HStack(spacing: 16) {
                FormReadout("Users", value: instance.userCount_ ?? 0)
                    .tint(palette.userAccent)
                FormReadout("Communities", value: instance.communityCount_ ?? 0)
                    .tint(palette.communityAccent)
            }
            .frame(maxWidth: .infinity)
            
            HStack(spacing: 16) {
                FormReadout("Posts", value: instance.postCount_ ?? 0)
                    .tint(palette.postAccent)
                FormReadout("Comments", value: instance.commentCount_ ?? 0)
                    .tint(palette.commentAccent)
            }
            .frame(maxWidth: .infinity)
            
            if let activeUserCount = instance.activeUserCount_ {
                ActiveUserCountView(activeUserCount: activeUserCount)
            }
            
            FormSection {
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
            }
            
            FormSection {
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
            }
            
            FormSection {
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
            }
            
            FormSection {
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
            }
        }
        .padding(16)
        .background(palette.groupedBackground)
    }
    
    var captchaLabel: LocalizedStringResource {
        if let diff = instance.captchaDifficulty_ {
            return "Yes (\(diff.label))"
        }
        return "No"
    }

    @ViewBuilder
    func settingRow(
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
    
    @ViewBuilder
    func settingRow(_ label: LocalizedStringResource, systemImage: String, value: Bool) -> some View {
        settingRow(
            label,
            systemImage: systemImage,
            value: value ? "Yes" : "No",
            color: value ? palette.positive : palette.negative
        )
    }
}
