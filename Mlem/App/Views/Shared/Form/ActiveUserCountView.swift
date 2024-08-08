//
//  ActiveUserCountView.swift
//  Mlem
//
//  Created by Sjmarf on 08/08/2024.
//

import MlemMiddleware
import SwiftUI

struct ActiveUserCountView: View {
    @Environment(Palette.self) private var palette
    
    let activeUserCount: ActiveUserCount
    
    var body: some View {
        FormSection {
            VStack(spacing: 8) {
                Text("Active Users")
                    .foregroundStyle(palette.secondary)
                HStack(spacing: 16) {
                    section(.init(month: 6), value: activeUserCount.sixMonths)
                    section(.init(month: 1), value: activeUserCount.month)
                    section(.init(weekOfMonth: 1), value: activeUserCount.week)
                    section(.init(day: 1), value: activeUserCount.day)
                }
            }
            .padding(.vertical, Constants.main.standardSpacing)
        }
    }
    
    @ViewBuilder
    func section(_ components: DateComponents, value: Int) -> some View {
        VStack {
            Text(value.abbreviated)
                .font(.title3)
                .fontWeight(.semibold)
            Text(formatter.string(from: components) ?? "")
                .foregroundStyle(palette.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    var formatter: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.maximumUnitCount = 1
        return formatter
    }
}
