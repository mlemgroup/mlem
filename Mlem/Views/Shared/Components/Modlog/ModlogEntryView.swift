//
//  ModlogEntryView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-11.
//

import Foundation
import SwiftUI

struct ModlogEntryView: View {
    let modlogEntry: ModlogEntry

    var body: some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(AppConstants.standardSpacing)
            .background(Color(uiColor: .systemBackground))
            .contextMenu {
                ForEach(modlogEntry.contextLinks) { menuFunction in
                    MenuButton(menuFunction: menuFunction, menuFunctionPopup: .constant(nil))
                }
            }
    }
    
    var content: some View {
        VStack(alignment: .leading, spacing: AppConstants.standardSpacing) {
            HStack {
                Text("\(modlogEntry.date.formatted()) (\(modlogEntry.date.getRelativeTime()))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                EllipsisMenu(size: 20, menuFunctions: modlogEntry.contextLinks)
            }
            
            description
        }
    }
    
    @ViewBuilder
    var description: some View {
        HStack(alignment: .top, spacing: AppConstants.standardSpacing) {
            Image(systemName: modlogEntry.icon.imageName)
                .foregroundColor(modlogEntry.icon.color)
                .padding(.top, 3)
            
            VStack(alignment: .leading, spacing: AppConstants.standardSpacing) {
                Text(modlogEntry.description)
                
                switch modlogEntry.reason {
                case .inapplicable:
                    EmptyView()
                case .noneGiven:
                    Text("No reason given")
                        .italic()
                        .foregroundColor(.secondary)
                case let .reason(reason):
                    Text("Reason: \(reason)")
                }
                
                switch modlogEntry.expires {
                case .inapplicable:
                    EmptyView()
                case .permanent:
                    Text("Permanent")
                        .italic()
                        .foregroundColor(.secondary)
                case let .date(date):
                    Text("Expires \(date.getRelativeTime())")
                        .italic()
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}
