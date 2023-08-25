//
//  TimestampView.swift
//  Mlem
//
//  Created by Sjmarf on 07/07/2023.
//

import SwiftUI

struct TimestampView: View {
    let date: Date
    var spacing: CGFloat = 4
    
    var body: some View {
        HStack(spacing: spacing) {
            Image(systemName: "clock")
            Text(getTimeIntervalFromNow(date: date))
        }
        .foregroundColor(.secondary)
        .accessibilityAddTraits(.isStaticText)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Published \(getTimeIntervalFromNow(date: date, unitsStyle: .full)) ago")
    }
}
