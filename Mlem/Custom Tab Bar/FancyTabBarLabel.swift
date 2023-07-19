//
//  FancyTabBarLabel.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-18.
//

import Foundation
import SwiftUI

struct FancyTabBarLabel: View {
    
    @Environment(\.tabSelectionHashValue) private var selectedTagHashValue
    @AppStorage("showTabNames") var showTabNames: Bool = true
    
    let tabIconSize: CGFloat = 24
    
    let tagHash: Int
    let symbolName: String?
    let activeSymbolName: String?
    let labelText: String?
    let color: Color
    let activeColor: Color
    
    var active: Bool { tagHash == selectedTagHashValue }
    
    /**
     Initializer. Most of these are optional or have default values--the logic on those is as follows:
     
     REQUIRED
     - tag: FancyTabBarSelection. By default, the label will display its labelText.
     
     OPTIONAL
     - customText: overrides the default labelText from tag
     - symbolName: if present, label will display this symbol
     - activeSymbolName: if present and symbolName is present, label will display this symbol when active
     - customColor: overrides the default color (UIColor.darkGray)
     - activeColor: overrides the default active color (Color.accentColor)
     */
    init(tag: any FancyTabBarSelection,
         customText: String? = nil,
         symbolName: String? = nil,
         activeSymbolName: String? = nil,
         customColor: Color = Color(uiColor: .darkGray),
         activeColor: Color = .accentColor) {
        self.tagHash = tag.hashValue
        self.symbolName = symbolName
        self.activeSymbolName = activeSymbolName
        self.labelText = customText ?? tag.labelText
        self.color = customColor
        self.activeColor = activeColor
    }
    
    var body: some View {
        VStack(spacing: 4) {
            if let symbolName = symbolName {
                Image(systemName: active ? activeSymbolName ?? symbolName : symbolName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: tabIconSize, height: tabIconSize)
            }
            
            if showTabNames, let text = labelText {
                Text(text)
                    .font(.caption2)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 10)
        .contentShape(Rectangle())
        .foregroundColor(active ? activeColor : color)
    }
}
