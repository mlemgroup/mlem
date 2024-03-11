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
    
    // I wanted to use DisclosureGroup but nesting ModlogContextLinkView inside it breaks animations -Eric 2024.03.11
    @State var collapsed: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.standardSpacing) {
            HStack {
                Text(modlogEntry.description)
                
                Spacer()
                
                Image(systemName: Icons.forward)
                    .foregroundColor(.secondary)
                    .rotationEffect(collapsed ? Angle.zero : Angle(degrees: 90.0))
            }
            
            if !collapsed {
                VStack(spacing: AppConstants.standardSpacing) {
                    ForEach(modlogEntry.context) { context in
                        ModlogContextLinkView(context: context)
                    }
                }
            }
            
            Text(modlogEntry.date.formatted())
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation {
                collapsed = !collapsed
            }
        }
    }
}
