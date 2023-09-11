//
//  FancyTabBarLabel.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-18.
//

import Foundation
import SwiftUI

struct FancyTabBarLabel: View {
    struct SymbolConfiguration {
        let symbol: String
        let activeSymbol: String
        let remoteSymbolUrl: URL?
        
        static var feed: Self { .init(symbol: "scroll", activeSymbol: "scroll.fill", remoteSymbolUrl: nil) }
        static var inbox: Self { .init(symbol: "mail.stack", activeSymbol: "mail.stack.fill", remoteSymbolUrl: nil) }
        static var profile: Self { .init(symbol: "person.circle", activeSymbol: "person.circle.fill", remoteSymbolUrl: nil) }
        static var search: Self { .init(symbol: "magnifyingglass", activeSymbol: "text.magnifyingglass", remoteSymbolUrl: nil) }
        static var settings: Self { .init(symbol: "gear", activeSymbol: "gear", remoteSymbolUrl: nil) }
    }
    
    @Environment(\.tabSelectionHashValue) private var selectedTagHashValue
    @AppStorage("showTabNames") var showTabNames: Bool = true
    
    let tabIconSize: CGFloat = 24
    
    let tagHash: Int
    let symbolConfiguration: SymbolConfiguration
    let labelText: String?
    let color: Color
    let activeColor: Color
    let badgeCount: Int?
    
    var active: Bool { tagHash == selectedTagHashValue }
    
    /// Initializer. Most of these are optional or have default values--the logic on those is as follows:
    /// REQUIRED
    ///  - tag: FancyTabBarSelection. By default, the label will display its labelText.
    /// OPTIONAL
    /// - customText: overrides the default labelText from tag
    /// - symbolName: if present, label will display this symbol
    /// - activeSymbolName: if present and symbolName is present, label will display this symbol when active
    /// - customColor: overrides the default color (UIColor.darkGray)
    /// - activeColor: overrides the default active color (Color.accentColor)
    /// - badgeCount: count to display as badge
    init(
        tag: any FancyTabBarSelection,
        customText: String? = nil,
        symbolConfiguration: SymbolConfiguration,
        customColor: Color = Color.primary,
        activeColor: Color = .accentColor,
        badgeCount: Int? = nil
    ) {
        self.tagHash = tag.hashValue
        self.symbolConfiguration = symbolConfiguration
        self.labelText = customText ?? tag.labelText
        self.color = customColor
        self.activeColor = activeColor
        self.badgeCount = badgeCount
    }
    
    var body: some View {
        labelDisplay
            .accessibilityShowsLargeContentViewer {
                labelDisplay
            }
            .customBadge(badgeCount)
            .padding(.top, 10)
            .frame(maxWidth: .infinity)
            .frame(height: AppConstants.fancyTabBarHeight)
            .contentShape(Rectangle())
            .foregroundColor(active ? activeColor : color.opacity(0.4))
            .animation(.linear(duration: 0.1), value: active)
    }
    
    @ViewBuilder
    var labelDisplay: some View {
        VStack(spacing: 4) {
            if let remoteSymbolUrl = symbolConfiguration.remoteSymbolUrl {
                CachedImage(
                    url: remoteSymbolUrl,
                    shouldExpand: false,
                    fixedSize: .init(width: tabIconSize, height: tabIconSize),
                    imageNotFound: { defaultTabIcon(for: symbolConfiguration) },
                    errorBackgroundColor: .clear,
                    contentMode: .fill
                )
                .frame(width: tabIconSize, height: tabIconSize)
                .clipShape(Circle())
                .overlay(Circle()
                    .stroke(.gray.opacity(0.3), lineWidth: 1))
                .opacity(active ? 1 : 0.7)
                .accessibilityHidden(true)
            } else {
                Image(systemName: active ? symbolConfiguration.activeSymbol : symbolConfiguration.symbol)
                    .resizable()
                    .scaledToFit()
                    .frame(width: tabIconSize, height: tabIconSize)
            }
            
            if showTabNames, let text = labelText {
                Text(text)
                    .font(.system(size: 10))
            }
        }
    }
    
    private func defaultTabIcon(for configuration: SymbolConfiguration) -> AnyView {
        AnyView(Image(systemName: active ? configuration.activeSymbol : configuration.symbol)
            .resizable()
            .scaledToFill()
            .frame(width: tabIconSize, height: tabIconSize)
        )
    }
}
