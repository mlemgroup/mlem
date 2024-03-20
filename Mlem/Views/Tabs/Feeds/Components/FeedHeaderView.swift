//
//  FeedHeaderView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-01-28.
//

import Foundation
import SwiftUI

protocol FeedType {
    var label: String { get }
    var subtitle: String { get }
    var color: Color? { get }
    var iconNameFill: String { get }
    var iconScaleFactor: CGFloat { get }
}

struct FeedHeaderView: View {
    @EnvironmentObject var appState: AppState
    
    let feedType: any FeedType
    let suppressDropdownIndicator: Bool
    
    init(feedType: any FeedType, suppressDropdownIndicator: Bool = false) {
        self.feedType = feedType
        self.suppressDropdownIndicator = suppressDropdownIndicator
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
                        
                        if !suppressDropdownIndicator {
                            Image(systemName: Icons.dropdown)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .font(.title2)
                        
                    Text(feedType.subtitle)
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
