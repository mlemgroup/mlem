//
//  Timestamp View.swift
//  Mlem
//
//  Created by Sjmarf on 06/07/2023.
//

import SwiftUI

struct TimestampView: View {
    
    var spacing: Int
    @State var date: Date
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "clock")
            Text(getTimeIntervalFromNow(date: date))
        }
        .foregroundColor(.secondary)
        .accessibilityAddTraits(.isStaticText)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Published \(getTimeIntervalFromNow(date: date, unitsStyle: .full)) ago")
    }
}
