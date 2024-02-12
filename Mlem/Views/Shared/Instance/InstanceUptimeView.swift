//
//  InstanceUptimeView.swift
//  Mlem
//
//  Created by Sjmarf on 28/01/2024.
//

import SwiftUI
import Charts
import Dependencies
import Foundation

struct InstanceUptimeView: View {
    @Dependency(\.errorHandler) var errorHandler
    
    @Environment(\.accessibilityDifferentiateWithoutColor) var diffWithoutColor: Bool
    @Environment(\.colorScheme) var colorScheme
    
    @State var showingExactTime: Bool = false
    
    let instance: InstanceModel
    let uptimeData: UptimeData
    
    @ViewBuilder
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            section { summary }
            .padding(.top, 16)
            .padding(.bottom, 10)
            section("Recent Checks") {
                recentChecks
                    .padding(.horizontal)
                    .padding(.vertical, 15)
            }
            .padding(.top, 20)
            footnote("Mlem will refresh this automatically every 30 seconds.")
            .padding(.top, 8)
            .padding(.leading, 6)
            .padding(.bottom, 30)
            section("Response Time") {
                VStack(alignment: .leading, spacing: 4) {
                    responseTimeChart
                        .padding(.horizontal, 20)
                    footnote("Average: \(uptimeData.results.map(\.durationMs).reduce(0, +) / uptimeData.results.count)ms")
                        .padding(.leading, 20)
                }
                .padding(.top, 17)
                .padding(.bottom, 8)
            }
            section("Incidents", spacing: 0) {
                ForEach(uptimeData.downtimes) { event in
                    if event.id != uptimeData.downtimes.first?.id {
                        Divider()
                    }
                    IncidentRow(event: event, showingExactTime: showingExactTime)
                    .padding(.vertical, 10)
                    .padding(.leading)
                }
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showingExactTime.toggle()
                    }
                }
            }
            .padding(.top, 30)
            if let url = instance.uptimeFrontendUrl {
                Text("Uptime data fetched from [lemmy-status.org](\(url))")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 8)
                    .padding(.leading, 6)
            }
            if colorScheme == .light {
                Divider()
            }
        }
        .padding(.horizontal, 16)
        .background(Color(uiColor: .systemGroupedBackground))
    }
    
    @ViewBuilder
    var summary: some View {
        VStack(alignment: .leading) {
            if let mostRecentOutage = uptimeData.downtimes.first {
                if uptimeData.results.filter(\.success).count < 15 {
                    if mostRecentOutage.endTime == nil {
                        summaryHeader(statusText: "offline", systemImage: Icons.uptimeOffline, color: .red)
                        footnote("Outage started \(mostRecentOutage.startTime.getRelativeTime()).")
                    } else {
                        summaryHeader(statusText: "unhealthy", systemImage: Icons.uptimeOutage, color: .red)
                        footnote("\(instance.name) has been unresponsive recently.")
                    }
                } else {
                    summaryHeader(statusText: "online", systemImage: Icons.uptimeOnline, color: .green)
                    if mostRecentOutage.endTime != nil {
                        let relTime = mostRecentOutage.relativeTimeCaption
                        let length = mostRecentOutage.differenceTitle(unitsStyle: .full)
                        footnote("The most recent outage was \(relTime), and lasted for \(length).")
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 10)
        .padding(.horizontal)
    }
    
    @ViewBuilder
    func summaryHeader(statusText: String, systemImage: String, color: Color) -> some View {
        HStack(spacing: 5) {
            (Text("\(instance.name) is ") + Text(statusText).foregroundColor(color))
                .font(.title2)
                .fontWeight(.semibold)
            Image(systemName: systemImage)
                .foregroundStyle(color)
        }
    }
    
    @ViewBuilder
    var recentChecks: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 3) {
                ForEach(uptimeData.results) { result in
                    if diffWithoutColor {
                        Image(systemName: result.success ? Icons.uptimeOnline : Icons.uptimeOffline)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundStyle(result.success ? .green : .red)
                            .frame(maxWidth: 20)
                            .frame(maxWidth: 25)
                    } else {
                        Circle()
                            .fill(result.success ? .green : .red)
                            .frame(maxWidth: 20)
                            .frame(maxWidth: 25)
                    }
                }
            }
            HStack {
                footnote(timeOnlyFormatter.string(from: uptimeData.results.first?.timestamp ?? .now))
                Spacer()
                footnote(timeOnlyFormatter.string(from: uptimeData.results.last?.timestamp ?? .now))
            }
            .frame(maxWidth: CGFloat(uptimeData.results.count*25 + (uptimeData.results.count-1)*3))
            .padding(.top, 4)
        }
    }
    
    @ViewBuilder
    var responseTimeChart: some View {
        Chart {
            ForEach(uptimeData.results) { node in
                let time = Int(node.durationMs)
                LineMark(
                    x: .value("Time", node.timestamp),
                    y: .value("Response Time", time)
                )
            }
        }
        .frame(height: 200)
        .chartXAxis {
            let marks = [uptimeData.results.first?.timestamp ?? .distantPast, uptimeData.results.last?.timestamp ?? .distantFuture]
            AxisMarks(format: .dateTime.hour(.defaultDigits(amPM: .abbreviated)).minute(.twoDigits), values: marks)
        }
        .chartYScale(domain: [0, max(1000, (uptimeData.results.map(\.durationMs).max() ?? 0) + 100)])
        .chartYAxis {
            AxisMarks(values: .automatic) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let intValue = value.as(Int.self) {
                        Text("\(intValue)ms")
                    }
                }
            }
        }
    }
    
    @ViewBuilder func section(_ title: String? = nil, spacing: CGFloat = 5, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            if let title {
                subHeading(title)
            }
            VStack(alignment: .leading, spacing: spacing) {
                content()
            }
            .frame(maxWidth: .infinity)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .cornerRadius(AppConstants.largeItemCornerRadius)
        }
    }
    
    @ViewBuilder
    func subHeading(_ title: String) -> some View {
        Text(title)
            .font(.title2)
            .fontWeight(.semibold)
            .padding(.leading, 6)
    }
    
    @ViewBuilder
    func footnote(_ title: String) -> some View {
        Text(title)
            .font(.footnote)
            .foregroundStyle(.secondary)
    }
    
    var timeOnlyFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .none
        return dateFormatter
    }
}

private struct IncidentRow: View {
    let event: DowntimePeriod
    let showingExactTime: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: Icons.uptimeOutage)
                    .foregroundStyle(event.severityColor)
                    .foregroundStyle(.secondary)
                Text("Unhealthy for \(event.differenceTitle())")
            }
            Text(showingExactTime ? event.differenceCaption : event.relativeTimeCaption)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(.rect)
    }
}
