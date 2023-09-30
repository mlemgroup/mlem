//
//  UpdatedTimestampView.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-09-30.
//

import SwiftUI

struct UpdatedTimestampView: View {
    let date: Date
    var spacing: CGFloat = 4
    
    var body: some View {
        HStack(spacing: spacing) {
            Image(systemName: Icons.updated)
            Text(getTimeIntervalFromNow(date: date))
        }
        .foregroundColor(.secondary)
        .accessibilityAddTraits(.isStaticText)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Updated \(getTimeIntervalFromNow(date: date, unitsStyle: .full)) ago")
    }
}
