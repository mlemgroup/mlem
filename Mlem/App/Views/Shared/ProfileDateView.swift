//
//  ProfileDateView.swift
//  Mlem
//
//  Created by Sjmarf on 31/05/2024.
//

import Icons
import MlemMiddleware
import SwiftUI
import Theming

struct ProfileDateView: View {
    var profilable: any Profile2Providing
    
    var body: some View {
        Label(format(profilable.created), icon: icon)
            .symbolVariant(profilable.createdRecently || profilable.isCakeDay ? .fill : .none)
            .foregroundStyle(color)
            .font(.footnote)
    }
    
    var color: ThemedColor {
        if profilable.createdRecently {
            .themedColorfulAccent(3)
        } else if profilable.isCakeDay {
            .themedColorfulAccent(1)
        } else {
            .themedSecondary
        }
    }
    
    var icon: Icon {
        profilable.createdRecently ? .lemmy.newAccountFlair : .lemmy.cakeDay
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
