//
//  FeedHeaderView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-01-28.
//

import Foundation
import SwiftUI

struct FeedHeaderView: View {
    @Environment(AppState.self) var appState
    @Environment(Palette.self) var palette
    
    enum DropdownStyle {
        case disabled
        case enabled(showBadge: Bool)
    }
    
    let feedDescription: FeedDescription
    let subtitle: LocalizedStringResource
    let dropdownStyle: DropdownStyle
    
    init(
        feedDescription: FeedDescription,
        customSubtitle: LocalizedStringResource? = nil,
        dropdownStyle: DropdownStyle
    ) {
        self.feedDescription = feedDescription
        self.subtitle = customSubtitle ?? feedDescription.subtitle
        self.dropdownStyle = dropdownStyle
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: AppConstants.standardSpacing) {
                FeedIconView(feedDescription: feedDescription, size: 44)
                    .padding(.leading, AppConstants.standardSpacing)
                    
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: AppConstants.halfSpacing) {
                        Text(feedDescription.label)
                            .lineLimit(1)
                            .minimumScaleFactor(0.01)
                            .fontWeight(.semibold)
                        
                        if case let .enabled(showBadge) = dropdownStyle {
                            Image(systemName: Icons.dropdown)
                                .foregroundStyle(palette.secondary)
                                .overlay(alignment: .topTrailing) {
                                    if showBadge {
                                        Circle()
                                            .frame(width: 6, height: 6)
                                            .foregroundStyle(palette.warning)
                                    }
                                }
                        }
                    }
                    .font(.title2)
                        
                    Text(subtitle)
                        .font(.footnote)
                        .foregroundStyle(palette.secondary)
                }
                .frame(height: 44)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.top, AppConstants.halfSpacing)
            .padding(.bottom, AppConstants.standardSpacing)
        }
    }
}
