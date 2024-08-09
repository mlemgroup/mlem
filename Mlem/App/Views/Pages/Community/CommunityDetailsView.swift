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
                    .padding(.vertical, Constants.main.standardSpacing)
            }
            
            FormSection {
                VStack(spacing: Constants.main.halfSpacing) {
                    Text("Subscribers")
                        .foregroundStyle(palette.secondary)
                    Text(community.subscriberCount_ ?? 0, format: .number)
                        .font(.title)
                        .fontWeight(.semibold)
                        .contentTransition(.numericText(value: Double(community.subscriberCount_ ?? 0)))
                        .animation(.default, value: community.subscriberCount_)
                    
                    if let localSubscriberCount = community.localSubscriberCount_ {
                        Text(localSubscriberCountText)
                            .contentTransition(.numericText(value: Double(localSubscriberCount)))
                            .animation(.default, value: localSubscriberCount)
                            .foregroundStyle(palette.secondary)
                            .font(.footnote)
                    }
                }
                .monospacedDigit()
                .padding(.vertical, Constants.main.standardSpacing)
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
