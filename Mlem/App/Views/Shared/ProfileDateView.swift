//
//  ProfileDateView.swift
//  Mlem
//
//  Created by Sjmarf on 31/05/2024.
//

import MlemMiddleware
import SwiftUI

struct ProfileDateView: View {
    var profilable: any Profile2Providing
    
    var body: some View {
        HStack {
            Label(format(profilable.created), systemImage: Icons.cakeDay)
            if let updated = profilable.updated {
                Label(format(updated), systemImage: Icons.edit)
                    .foregroundStyle(Color(uiColor: .tertiaryLabel))
            }
        }
        .foregroundStyle(.secondary)
        .font(.footnote)
    }
    
    func format(_ date: Date) -> String {
        let relTime = date.getRelativeTime(date: Date.now, unitsStyle: .abbreviated)
        return "\(date.dateString), \(relTime)"
    }
}
