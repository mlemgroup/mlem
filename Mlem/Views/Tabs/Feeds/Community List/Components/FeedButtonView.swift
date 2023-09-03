//
//  FeedButtonView.swift
//  Mlem
//
//  Created by Sam Marfleet on 25/08/2023.
//

import SwiftUI

struct FeedButtonView: View {
    @State var feedType: FeedType
    
    let title: String
    let iconName: String
    let iconColor: Color
    
    var body: some View {
        NavigationLink(value: CommunityLinkWithContext(community: nil, feedType: feedType)) {
            HStack(spacing: 12) {
                Image(systemName: iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(.white)
                    .padding(8)
                    .frame(width: 36, height: 36)
                    .background(iconColor)
                    .clipShape(Circle())
                Text(title)
                Spacer()
            }
            .contentShape(Rectangle())
        }
        .padding(.leading, 15)
        .frame(maxWidth: .infinity)
        .frame(height: 60)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .buttonStyle(.plain)
    }
}
