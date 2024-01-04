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
        VStack(spacing: 16) {
            VStack(spacing: 5) {
                Text("Subscribers")
                    .foregroundStyle(.secondary)
                Text("\(community.subscriberCount ?? 0)")
                    .fontWeight(.semibold)
                    .font(.title)
                
            }
            .padding(.vertical)
            .frame(maxWidth: .infinity)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .cornerRadius(AppConstants.largeItemCornerRadius)
            HStack(spacing: 16) {
                
                VStack(spacing: 5) {
                    HStack {
                        Text("Posts")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("\(abbreviateNumber(community.postCount ?? 0))")
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundStyle(.pink)
                    }
                }
                .padding(10)
                .frame(maxWidth: .infinity)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .cornerRadius(AppConstants.largeItemCornerRadius)
                
                VStack(spacing: 5) {
                    HStack {
                        Text("Comments")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("\(abbreviateNumber(community.commentCount ?? 0))")
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundStyle(.orange)
                    }
                }
                .padding(10)
                .frame(maxWidth: .infinity)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .cornerRadius(AppConstants.largeItemCornerRadius)
            }
            .frame(maxWidth: .infinity)
            
            if let activeUserCount = community.activeUserCount {
                VStack(spacing: 8) {
                    Text("Active Users")
                        .foregroundStyle(.secondary)
                    HStack(spacing: 16) {
                        activeUserBox("6mo", value: activeUserCount.sixMonths)
                        activeUserBox("1mo", value: activeUserCount.month)
                        activeUserBox("1w", value: activeUserCount.week)
                        activeUserBox("1d", value: activeUserCount.day)
                    }
                }
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .cornerRadius(AppConstants.largeItemCornerRadius)
            }
        }
        .padding(.horizontal, 16)
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
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(uiColor: .systemGroupedBackground))
}
