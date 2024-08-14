//
//  ProfileDateView.swift
//  Mlem
//
//  Created by Sjmarf on 31/05/2024.
//

import MlemMiddleware
import SwiftUI

struct ProfileDateView: View {
    @Environment(Palette.self) var palette

    var profilable: any Profile2Providing
    
    var body: some View {
        Label(format(profilable.created), systemImage: Icons.cakeDay)
            .foregroundStyle(palette.secondary)
            .font(.footnote)
    }
    
    func format(_ date: Date) -> String {
        let relTime = date.getRelativeTime(date: Date.now, unitsStyle: .abbreviated)
        return "\(date.dateString), \(relTime)"
    }
}
