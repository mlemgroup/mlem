//
//  InstanceStatsView.swift
//  Mlem
//
//  Created by Sjmarf on 20/01/2024.
//

import SwiftUI

struct InstanceStatsView: View {
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
                    "Federates",
                    systemImage: Icons.federation,
                    value: instance.federates ?? false
                )
                Divider()
                settingRow(
                    "Allows NSFW",
                    systemImage: Icons.blurNsfw,
                    value: instance.allowsNSFW ?? false
                )
                Divider()
                settingRow(
                    "Has Downvotes",
                    systemImage: Icons.downvote,
                    value: instance.allowsDownvotes ?? false
                )
                Divider()
                settingRow(
                    "Allows Community Creation",
                    systemImage: Icons.community,
                    value: instance.allowsCommunityCreation ?? false
                )
                Divider()
                settingRow(
                    "Has a Slur Filter",
                    systemImage: Icons.filterFill,
                    value: instance.slurFilterRegex != nil
                )
                Divider()
                settingRow(
                    "Requires Email Verification",
                    systemImage: Icons.email,
                    value: instance.requiresEmailVerification ?? false
                )
                Divider()
                
                settingRow(
                    "Requires Captcha",
                    systemImage: Icons.photo,
                    value: captchaLabel,
                    color: instance.captchaDifficulty == nil ? .red : .green
                )
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
    
    @ViewBuilder func settingRow(_ label: String, systemImage: String, value: String, color: Color) -> some View {
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
