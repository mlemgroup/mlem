//
//  InstanceUptimeView+Views.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-05-09.
//

import SwiftUICore

struct RecentUptimeChecks: View {
    @Environment(\.accessibilityDifferentiateWithoutColor) var diffWithoutColor: Bool
    
    let results: [UptimeResponseTime]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 3) {
                ForEach(results) { result in
                    Group {
                        if diffWithoutColor {
                            Image(icon: result.success ? .uptime.online : .uptime.offline)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .symbolVariant(.circle.fill)
                        } else {
                            Circle()
                        }
                    }
                    .foregroundStyle(result.success ? .themedPositive : .themedNegative)
                    .frame(maxWidth: 20)
                    .frame(maxWidth: 25)
                }
            }
            HStack {
                Text(timeOnlyFormatter.string(from: results.first?.timestamp ?? .now))
                Spacer()
                Text(timeOnlyFormatter.string(from: results.last?.timestamp ?? .now))
            }
            .font(.footnote)
            .foregroundStyle(.themedSecondary)
            .frame(maxWidth: CGFloat(results.count * 25 + (results.count - 1) * 3))
            .padding(.top, 4)
        }
    }
    
    var timeOnlyFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .none
        return dateFormatter
    }
}
