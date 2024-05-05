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
    let showDropdownIndicator: Bool
    let subtitle: String
    let showDropdownBadge: Bool
    
    init(feedType: any FeedType, showDropdownIndicator: Bool = true, customSubtitle: String? = nil, showDropdownBadge: Bool = false) {
        assert(
            !showDropdownBadge || showDropdownIndicator,
            "showDropdownBadge (\(showDropdownBadge)) cannot be true if showDropdownIndicator (\(showDropdownIndicator)) false!"
        )
        
        self.feedType = feedType
        self.showDropdownIndicator = showDropdownIndicator
        self.subtitle = customSubtitle ?? feedType.subtitle
        self.showDropdownBadge = showDropdownBadge
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
                        
                        if showDropdownIndicator {
                            Image(systemName: Icons.dropdown)
                                .foregroundStyle(.secondary)
                                .overlay(alignment: .topTrailing) {
                                    if showDropdownBadge {
                                        Circle()
                                            .frame(width: 6, height: 6)
                                            .foregroundStyle(.red)
                                    }
                                }
                        }
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
            .padding(.bottom, 5)
            
            Divider()
        }
    }
}
