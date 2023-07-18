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
    
    let tagHash: Int?
    let symbolName: String?
    let activeSymbolName: String?
    let text: String?
    let color: Color?
    
    init(tagHash: Int? = nil,
         symbolName: String? = nil,
         activeSymbolName: String? = nil,
         text: String? = nil,
         color: Color? = Color(uiColor: .darkGray)) {
        self.tagHash = tagHash
        self.symbolName = symbolName
        self.activeSymbolName = activeSymbolName
        self.text = text
        self.color = color
    }
    
    var body: some View {
        VStack(spacing: 4) {
            if let symbolName = symbolName {
                Image(systemName: symbolName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: tabIconSize, height: tabIconSize)
            }
            
            if tagHash == selectedTagHashValue {
                Image(systemName: "tree")
            }
            
            if let hash = selectedTagHashValue {
                Text(hash.description)
            }
            
            if showTabNames, let text = text {
                Text(text)
                    .font(.caption2)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 10)
        .foregroundColor(color)
    }
}
