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
    
    /// Returns a `String` with the cake date and a custom message depending to if today is cake day or not.
    /// If the current day is not the cake day, forges a `String` with relative time between the cake date and today.
    /// In that case the result string is in *full* unit style so as to improve vocalization of the date with *Voice Over¨.
    /// - Parameter date: the date to process, here the profile creation daye
    /// - Returns String: The enriched string to add in the profile
    func format(_ date: Date) -> String {
        if profilable.isCakeDay {
            // It's possible for it to be a user's cake day without their account age quite being 365 days.
            // To account for this we subtrat 1 day from the start date, to push it over the 1 year mark.
            let startDate = profilable.created.addingTimeInterval(-60 * 60 * 24)
            let components = Calendar.current.dateComponents([.year], from: startDate, to: .now)
            return "\(date.dateString), " + String(localized: "\(components.year ?? 0) years ago today!")
        }
        return "\(date.dateString), \(date.getRelativeTime(unitsStyle: .full))"
    }
}
