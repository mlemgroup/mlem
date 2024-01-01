//
//  CommunityStatsView.swift
//  Mlem
//
//  Created by Sjmarf on 01/01/2024.
//

import SwiftUI

struct CommunityStatsView: View {
    let community: CommunityModel
    
    var body: some View {
        VStack(spacing: 0) {
            VStack {
                Text("\(community.subscriberCount ?? 0)")
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("Subscribers")
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, AppConstants.postAndCommentSpacing)
            .padding(.bottom, 10)
            Divider()
            HStack {
                Spacer()
                Label("\(community.postCount ?? 0)", systemImage: Icons.posts)
                Spacer()
                Label("\(community.commentCount ?? 0)", systemImage: Icons.replies)
                Spacer()
            }
            .padding(.horizontal, AppConstants.postAndCommentSpacing)
            .padding(.vertical, 10)
            Divider()
            VStack {
                Text("Active users")
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 2)
                HStack {
                    activeUserBox("6mo", value: community.activeUserCount?.sixMonths ?? 0)
                    activeUserBox("1mo", value: community.activeUserCount?.month ?? 0)
                    activeUserBox("1w", value: community.activeUserCount?.week ?? 0)
                    activeUserBox("1d", value: community.activeUserCount?.day ?? 0)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, AppConstants.postAndCommentSpacing)
            .padding(.vertical, 10)
            Divider()
        }
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

#Preview {
    VStack(spacing: 0) {
        Divider()
        CommunityStatsView(community: .mock())
            .padding(.top, 10)
            .background(Color.systemBackground)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.secondarySystemBackground)
}
