//
//  FeedHeaderView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-01-28.
//

import Foundation
import SwiftUI

struct FeedHeaderView<ImageContent: View>: View {
    @Environment(AppState.self) var appState
    
    enum DropdownStyle {
        case disabled
        case enabled(showBadge: Bool)
    }
    
    // Using `Text` rather than `String` here to avoid having to make 4 initializers to handle
    // all permutations of `String` and `LocalizedStringResource` for `title and `subtitle`.
    let title: Text
    let subtitle: Text
    
    let image: ImageContent
    let dropdownStyle: DropdownStyle
    
    init(
        title: Text,
        subtitle: Text,
        dropdownStyle: DropdownStyle,
        @ViewBuilder image: () -> ImageContent
    ) {
        self.title = title
        self.subtitle = subtitle
        self.dropdownStyle = dropdownStyle
        self.image = image()
    }
    
    init(
        feedDescription: FeedDescription,
        customSubtitle: LocalizedStringResource? = nil,
        dropdownStyle: DropdownStyle
    ) where ImageContent == FeedIconView {
        self.title = Text(feedDescription.label)
        self.subtitle = Text(customSubtitle ?? feedDescription.subtitle)
        self.image = FeedIconView(feedDescription: feedDescription, size: Constants.main.feedHeaderSize)
        self.dropdownStyle = dropdownStyle
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: Constants.main.standardSpacing) {
                image
                    .frame(width: Constants.main.feedHeaderSize, height: Constants.main.feedHeaderSize)
                    .padding(.leading, Constants.main.standardSpacing)
                    
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: Constants.main.halfSpacing) {
                        title
                            .lineLimit(1)
                            .minimumScaleFactor(0.01)
                            .fontWeight(.semibold)
                            .foregroundStyle(.themedPrimary)
                        
                        if case let .enabled(showBadge) = dropdownStyle {
                            Image(icon: .general.dropDown)
                                .foregroundStyle(.themedSecondary)
                                .overlay(alignment: .topTrailing) {
                                    if showBadge {
                                        Circle()
                                            .frame(width: 6, height: 6)
                                            .foregroundStyle(.themedWarning)
                                    }
                                }
                        }
                    }
                    .font(.title2)
                        
                    subtitle
                        .font(.footnote)
                        .foregroundStyle(.themedSecondary)
                }
                .frame(height: Constants.main.feedHeaderSize)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.top, Constants.main.halfSpacing)
        }
    }
}
