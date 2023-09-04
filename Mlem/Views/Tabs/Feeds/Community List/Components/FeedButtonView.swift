//
//  FeedButtonView.swift
//  Mlem
//
//  Created by Sam Marfleet on 25/08/2023.
//

import SwiftUI

struct FeedButtonView: View {
    @AppStorage("communityIconShape") var communityIconShape: IconShape = .circle
    
    @State var feedType: FeedType
    
    @EnvironmentObject var router: NavigationRouter
    
    let title: String
    let iconName: String
    let iconColor: Color
    
    var shape: AnyShape {
        if communityIconShape == .circle {
            AnyShape(Circle())
        } else {
            AnyShape(RoundedRectangle(cornerRadius: AppConstants.smallItemCornerRadius))
        }
    }
    
    var body: some View {
        NavigationLink(destination:
            FeedDetailRoot(rootDetails: CommunityLinkWithContext(community: nil, feedType: feedType))
            .id(UUID())
        ) {
            HStack(spacing: 12) {
                Image(systemName: iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(.white)
                    .padding(8)
                    .frame(width: 36, height: 36)
                    .background(iconColor)
                    .clipShape(shape)
                Text(title)
                    .padding(.trailing, -30)
                Spacer()
            }
            .contentShape(Rectangle())
        }
        .padding(.leading, 12)
        .frame(maxWidth: .infinity)
        .frame(height: 60)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .buttonStyle(.plain)
    }
}
