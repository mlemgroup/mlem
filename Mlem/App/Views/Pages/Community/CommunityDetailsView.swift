//
//  CommunityDetailsView.swift
//  Mlem
//
//  Created by Sjmarf on 08/08/2024.
//

import MlemMiddleware
import SwiftUI

struct CommunityDetailsView: View {
    @Environment(Palette.self) private var palette
    
    let community: any Community
    
    var body: some View {
        VStack(spacing: 16) {
            FormSection {
                ProfileDateView(profilable: community)
                    .padding(.vertical, AppConstants.standardSpacing)
            }
            
            FormSection {
                VStack(spacing: AppConstants.halfSpacing) {
                    Text("Subscribers")
                        .foregroundStyle(palette.secondary)
                    Text(String(community.subscriberCount_ ?? 0))
                        .font(.title)
                        .fontWeight(.semibold)
                        .contentTransition(.numericText(value: Double(community.subscriberCount_ ?? 0)))
                    
                    if let localSubscriberCount = community.localSubscriberCount_ {
                        Text(localSubscriberCountText)
                            .contentTransition(.numericText(value: Double(localSubscriberCount)))
                            .foregroundStyle(palette.secondary)
                    }
                }
                .monospacedDigit()
                .animation(.default, value: community.subscriberCount_)
                .padding(.vertical, AppConstants.standardSpacing)
            }
            
            HStack(spacing: 16) {
                FormReadout("Posts", value: community.postCount_ ?? 0)
                    .tint(palette.postAccent)
                FormReadout("Comments", value: community.commentCount_ ?? 0)
                    .tint(palette.commentAccent)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(16)
        .background(palette.groupedBackground)
    }
    
    var localSubscriberCountText: String {
        guard let count = community.localSubscriberCount_ else { return "" }
        if let host = community.host {
            return String(localized: "\(count) on \(host)")
        }
        return String(localized: "\(count) on your instance")
    }
}
