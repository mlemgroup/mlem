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

struct InstanceDetailsView: View {
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
                    .tint(.themedPersonAccent)
                FormReadout("Communities", value: instance.communityCount_ ?? 0)
                    .tint(.themedCommunityAccent)
            }
            .frame(maxWidth: .infinity)
            
            HStack(spacing: 16) {
                FormReadout("Posts", value: instance.postCount_ ?? 0)
                    .tint(.themedPostAccent)
                FormReadout("Comments", value: instance.commentCount_ ?? 0)
                    .tint(.themedCommentAccent)
            }
            .frame(maxWidth: .infinity)
            
            if let activeUserCount = instance.activeUserCount_ {
                ActiveUserCountView(activeUserCount: activeUserCount)
            }
            
            FormSection {
                VStack(alignment: .leading, spacing: 0) {
                    settingRow(
                        "Private",
                        icon: .lemmy.private,
                        value: instance.isPrivate_ ?? false
                    )
                    Divider()
                    settingRow(
                        "Federates",
                        icon: .lemmy.federation,
                        value: instance.federationEnabled_ ?? false
                    )
                }
            }
            
            FormSection {
                VStack(alignment: .leading, spacing: 0) {
                    settingRow(
                        "Registration",
                        icon: .lemmy.person,
                        value: instance.registrationMode_?.label ?? "Closed",
                        color: instance.registrationMode_?.color ?? .themedNegative
                    )
                    if instance.registrationMode_ != .closed {
                        Divider()
                        settingRow(
                            "Email Verification",
                            icon: .general.email,
                            value: instance.emailVerificationRequired_ ?? false
                        )
                        Divider()
                        settingRow(
                            "Captcha",
                            icon: .lemmy.captcha,
                            value: captchaLabel,
                            color: instance.captchaDifficulty_ == nil ? .themedNegative : .themedPositive
                        )
                    }
                }
            }
            
            FormSection {
                VStack(alignment: .leading, spacing: 0) {
                    settingRow(
                        "NSFW Content",
                        icon: .settings.blurNsfw,
                        value: instance.nsfwContentEnabled_ ?? false
                    )
                    Divider()
                    settingRow(
                        "Downvotes",
                        icon: .lemmy.downvoted,
                        value: instance.downvotesEnabled_ ?? false
                    )
                    Divider()
                    settingRow(
                        "Community Creation",
                        icon: .lemmy.community,
                        value: !(instance.communityCreationRestrictedToAdmins_ ?? false)
                    )
                    Divider()
                    settingRow(
                        "Slur Filter",
                        icon: .general.filter,
                        value: instance.slurFilterRegex_ != nil
                    )
                    if let regex = instance.slurFilterRegex_ {
                        Divider()
                        VStack(alignment: .leading, spacing: 2) {
                            if showingSlurRegex {
                                Text(regex)
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
                    if let feedType = instance.defaultFeed_ {
                        Divider()
                        settingRow(
                            "Default Feed Type (Desktop)",
                            icon: .lemmy.feed,
                            value: feedType.label
                        )
                    }
                }
            }
            
            FormSection {
                VStack(alignment: .leading, spacing: 0) {
                    settingRow(
                        "Show Mod Names in Modlog",
                        icon: .lemmy.moderation,
                        value: !(instance.hideModlogNames_ ?? true)
                    )
                    Divider()
                    settingRow(
                        "Applications Email Admins",
                        icon: .lemmy.registrationApplication,
                        value: instance.emailApplicationsToAdmins_ ?? false
                    )
                    Divider()
                    settingRow(
                        "Reports Email Admins",
                        icon: .lemmy.report,
                        value: instance.emailReportsToAdmins_ ?? false
                    )
                }
            }
        }
        .padding([.horizontal, .bottom], 16)
    }
    
    var captchaLabel: LocalizedStringResource {
        if let diff = instance.captchaDifficulty_ {
            return .init(
                "Captcha Difficulty Yes",
                defaultValue: "Yes (\(diff.label))",
                comment: "Used to indicate Captcha difficulty. E.g. \"Yes (Hard)\"."
            )
        }
        return "No"
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
    
    @ViewBuilder
    func settingRow(_ label: LocalizedStringResource, icon: Icon, value: Bool) -> some View {
        settingRow(
            label,
            icon: icon,
            value: value ? "Yes" : "No",
            color: value ? .themedPositive : .themedNegative
        )
    }
}
