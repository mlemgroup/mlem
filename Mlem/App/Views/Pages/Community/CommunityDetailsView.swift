//
//  CommunityDetailsView.swift
//  Mlem
//
//  Created by Sjmarf on 08/08/2024.
//

import MlemMiddleware
import SwiftUI
import Theming

struct CommunityDetailsView: View {
    let community: any DeprecatedCommunity
    
    var body: some View {
        VStack(spacing: 16) {
            FormSection {
                ProfileDateView(profilable: community)
                    .padding(.vertical, Constants.main.standardSpacing)
            }
            
            FormSection {
                VStack(spacing: Constants.main.halfSpacing) {
                    Text("Subscribers")
                        .foregroundStyle(.themedSecondary)
                    Text(community.subscriberCount_ ?? 0, format: .number)
                        .font(.title)
                        .fontWeight(.semibold)
                        .contentTransition(.numericText(value: Double(community.subscriberCount_ ?? 0)))
                        .animation(.default, value: Double(community.subscriberCount_ ?? 0))
                    
                    if let localSubscriberCount = community.localSubscriberCount_ {
                        Text(localSubscriberCountText)
                            .contentTransition(.numericText(value: Double(localSubscriberCount)))
                            .animation(.default, value: Double(localSubscriberCount))
                            .foregroundStyle(.themedSecondary)
                            .font(.footnote)
                    }
                }
                .monospacedDigit()
                .padding(.vertical, Constants.main.standardSpacing)
            }

            HStack(spacing: 16) {
                FormReadout("Posts", value: community.postCount_ ?? 0)
                    .tint(.themedPostAccent)
                FormReadout("Comments", value: community.commentCount_ ?? 0)
                    .tint(.themedCommentAccent)
            }
            .frame(maxWidth: .infinity)
            
            if let activeUserCount = community.activeUserCount_,
               community.api.supports(.viewCommunityActiveUsers, defaultValue: true) {
                ActiveUserCountView(activeUserCount: activeUserCount)
            }
        }
        .padding([.horizontal, .bottom], 16)
    }
    
    var localSubscriberCountText: String {
        guard let count = community.localSubscriberCount_ else { return "" }
        return .init(
            localized: .init(
                "local.subscriber.count.text",
                defaultValue: "\(count) on \(community.api.host)",
                // swiftlint:disable:next line_length
                comment: "Used in the \"Details\" tab of a community page to indicate how many local subscribers use the instance. E.g. \"56 on lemmy.world\"."
            )
        )
    }
}
