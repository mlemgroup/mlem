//
//  InstanceStatsView.swift
//  Mlem
//
//  Created by Sjmarf on 20/01/2024.
//

import SwiftUI

struct InstanceStatsView: View {
    @AppStorage("developerMode") var developerMode: Bool = false
    
    let instance: InstanceModel
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                box {
                    HStack {
                        Text("Users")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("\(abbreviateNumber(instance.userCount ?? 0))")
                            .font(.title)
                            .fontWeight(.semibold)
                    }
                }
                
                box {
                    HStack {
                        Text("Communities")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("\(abbreviateNumber(instance.communityCount ?? 0))")
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundStyle(.green)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            
            HStack(spacing: 16) {
                box {
                    HStack {
                        Text("Posts")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("\(abbreviateNumber(instance.postCount ?? 0))")
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundStyle(.pink)
                    }
                }
                
                box {
                    HStack {
                        Text("Comments")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("\(abbreviateNumber(instance.commentCount ?? 0))")
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundStyle(.orange)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            
            if let activeUserCount = instance.activeUserCount {
                box(spacing: 8) {
                    Text("Active Users")
                        .foregroundStyle(.secondary)
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
                    value: instance.private ?? false
                )
                Divider()
                settingRow(
                    "Federates",
                    systemImage: Icons.federation,
                    value: instance.federates ?? false
                )
                if developerMode, let signedFetch = instance.federationSignedFetch {
                    Divider()
                    settingRow(
                        "Federation Signed Fetch",
                        systemImage: Icons.developerMode,
                        value: signedFetch
                    )
                }
            }
            .frame(maxWidth: .infinity)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .cornerRadius(AppConstants.largeItemCornerRadius)
            
            VStack(alignment: .leading, spacing: 0) {
                settingRow(
                    "NSFW Content",
                    systemImage: Icons.blurNsfw,
                    value: instance.allowsNSFW ?? false
                )
                Divider()
                settingRow(
                    "Downvotes",
                    systemImage: Icons.downvote,
                    value: instance.allowsDownvotes ?? false
                )
                Divider()
                settingRow(
                    "Community Creation",
                    systemImage: "house",
                    value: instance.allowsCommunityCreation ?? false
                )
                Divider()
                settingRow(
                    "Slur Filter",
                    systemImage: Icons.filterFill,
                    value: instance.slurFilterRegex != nil
                )
            }
            .frame(maxWidth: .infinity)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .cornerRadius(AppConstants.largeItemCornerRadius)
            
            VStack(alignment: .leading, spacing: 0) {
                settingRow(
                    "Registration",
                    systemImage: Icons.person,
                    value: instance.registrationMode?.label ?? "Closed",
                    color: instance.registrationMode?.color ?? .red
                )
                if instance.registrationMode != .closed {
                    Divider()
                    settingRow(
                        "Email Verification",
                        systemImage: Icons.email,
                        value: instance.requiresEmailVerification ?? false
                    )
                    Divider()
                    settingRow(
                        "Captcha",
                        systemImage: Icons.photo,
                        value: captchaLabel,
                        color: instance.captchaDifficulty == nil ? .red : .green
                    )
                }
            }
            .frame(maxWidth: .infinity)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .cornerRadius(AppConstants.largeItemCornerRadius)
            
        }
        .padding(.horizontal, 16)
    }
    
    var captchaLabel: String {
        if let diff = instance.captchaDifficulty {
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
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(AppConstants.largeItemCornerRadius)
    }
    
    @ViewBuilder func settingRow(
        _ label: String,
        systemImage: String,
        value: String,
        color: Color = .primary
    ) -> some View {
        HStack {
            Image(systemName: systemImage)
                .foregroundStyle(.secondary)
                .frame(width: 30)
            Text(label)
            Spacer()
            Text(value)
                .foregroundStyle(color)
        }
        .padding(12)
    }
    
    @ViewBuilder func settingRow(_ label: String, systemImage: String, value: Bool) -> some View {
        HStack {
            Image(systemName: systemImage)
                .foregroundStyle(.secondary)
                .frame(width: 30)
            Text(label)
            Spacer()
            Text(value ? "Yes" : "No")
                .foregroundStyle(value ? .green : .red)
        }
        .padding(12)
    }
    
    @ViewBuilder
    func activeUserBox(_ label: String, value: Int) -> some View {
        VStack {
            Text(abbreviateNumber(value))
                .font(.title3)
                .fontWeight(.semibold)
            Text(label)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        
    }
}
