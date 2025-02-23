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
        Label(format(profilable.created), systemImage: systemImage)
            .foregroundStyle(color)
            .font(.footnote)
    }
    
    var color: Color {
        if profilable.createdRecently {
            palette.colorfulAccent(3)
        } else if profilable.isCakeDay {
            palette.colorfulAccent(1)
        } else {
            palette.secondary
        }
    }
    
    var systemImage: String {
        if profilable.createdRecently {
            Icons.newAccountFlair
        } else if profilable.isCakeDay {
            Icons.cakeDayFill
        } else {
            Icons.cakeDay
        }
    }
    
    func format(_ date: Date) -> String {
        if profilable.isCakeDay {
            // It's possible for it to be a user's cake day without their account age quite being 365 days.
            // To account for this we subtrat 1 day from the start date, to push it over the 1 year mark.
            let startDate = profilable.created.addingTimeInterval(-60 * 60 * 24)
            let components = Calendar.current.dateComponents([.year], from: startDate, to: .now)
            return "\(date.dateString), " + String(localized: "\(components.year ?? 0) years ago today!")
        }
        return "\(date.dateString), \(date.getRelativeTime(unitsStyle: .abbreviated))"
    }
}
