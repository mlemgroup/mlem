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
        var relTime = date.getRelativeTime(unitsStyle: .abbreviated)
        if profilable.isCakeDay {
            relTime = String(localized: "\(relTime) today!")
        }
        return "\(date.dateString), \(relTime)"
    }
}
