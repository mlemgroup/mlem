//
//  FeedHeaderView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-01-28.
//

import Foundation
import SwiftUI

struct FeedHeaderView: View {
    @EnvironmentObject var appState: AppState
    
    let feedType: FeedType
    
    var subtitle: String {
        switch feedType {
        case .all:
            return "Posts from all federated instances"
        case .local:
            return "Posts from \(appState.currentActiveAccount?.instanceLink.host() ?? "your instance's") communities"
        case .subscribed:
            return "Posts from all subscribed communities"
        case .moderated:
            return "Posts from communities you moderate"
        case .saved:
            return "Your saved posts and comments"
        default:
            assertionFailure("We shouldn't be here...")
            return ""
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: AppConstants.standardSpacing) {
                FeedIconView(feedType: feedType, size: 44)
                    .padding(.leading, AppConstants.standardSpacing)
                    
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 5) {
                        Text(feedType.label)
                            .lineLimit(1)
                            .minimumScaleFactor(0.01)
                            .fontWeight(.semibold)
                        Image(systemName: Icons.dropdown)
                            .foregroundStyle(.secondary)
                    }
                    .font(.title2)
                        
                    Text(subtitle)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .frame(height: 44)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, 5)
            .padding(.bottom, 3)
            
            Divider()
        }
    }
}
