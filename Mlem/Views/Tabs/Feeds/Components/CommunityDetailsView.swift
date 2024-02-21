//
//  CommunityDetailsView.swift
//  Mlem
//
//  Created by Sjmarf on 01/01/2024.
//

import SwiftUI

struct CommunityDetailsView: View {
    let community: any Community2Providing
    
    var body: some View {
        VStack(spacing: 16) {
            box {
                HStack {
                    Label(community.creationDate.dateString, systemImage: Icons.cakeDay)
                    Text("•")
                    Label(community.creationDate.getRelativeTime(date: Date.now, unitsStyle: .abbreviated), systemImage: Icons.time)
                }
                .foregroundStyle(.secondary)
                .font(.footnote)
            }
            box {
                Text("Subscribers")
                    .foregroundStyle(.secondary)
                Text("\(community.subscriberCount)")
                    .fontWeight(.semibold)
                    .font(.title)
            }
            HStack(spacing: 16) {
                box {
                    Text("Posts")
                        .foregroundStyle(.secondary)
                    Text("\(abbreviateNumber(community.postCount))")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundStyle(.pink)
                }
                
                box {
                    Text("Comments")
                        .foregroundStyle(.secondary)
                    Text("\(abbreviateNumber(community.commentCount))")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundStyle(.orange)
                }
            }
            .frame(maxWidth: .infinity)
            
            let activeUserCount = community.activeUserCount
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
        .padding(.horizontal, 16)
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

// #Preview {
//    VStack(spacing: 0) {
//        Divider()
//        CommunityDetailsView(community: Community3.mock())
//            .padding(.top, 10)
//    }
//    .frame(maxWidth: .infinity, maxHeight: .infinity)
//    .background(Color(uiColor: .systemGroupedBackground))
// }
