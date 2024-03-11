//
//  ModlogEntryView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-11.
//

import Foundation
import SwiftUI

struct ModlogEntryView: View {
    
    let modlogEntry: AnyModlogEntry
    
    // plain DisclosureGroup has compatibility issues with LazyVStack (some items just won't open after scrolling a bit), so doing it manually
    @State var collapsed: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.standardSpacing) {
            HStack {
                Text(modlogEntry.description)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Image(systemName: Icons.forward)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .rotationEffect(collapsed ? Angle.zero : Angle(degrees: 90.0))
            }
            
            if !collapsed {
                VStack(spacing: AppConstants.standardSpacing) {
                    ForEach(modlogEntry.contextLinks) { link in
                        EasyTapLinkView(linkType: link, showCaption: false)
                    }
                }
            }
            
            Text(modlogEntry.date.formatted())
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation {
                collapsed = !collapsed
            }
        }
    }
}
