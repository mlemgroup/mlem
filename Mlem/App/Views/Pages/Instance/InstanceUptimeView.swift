//
//  InstanceUptimeView.swift
//  Mlem
//
//  Created by Sjmarf on 28/01/2024.
//

import Charts
import MlemMiddleware
import SwiftUI

struct InstanceUptimeView: View {
    @Environment(\.accessibilityDifferentiateWithoutColor) var diffWithoutColor: Bool
    @Environment(Palette.self) var palette
    
    @State var showingExactTime: Bool = false
    @State var showingAllDowntimes: Bool = false
    
    let instance: any Instance
    let uptimeData: UptimeData
    
    @ViewBuilder
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            section { summary }
                .padding(.bottom, 10)
            section("Recent Checks") {
                recentChecks
                    .padding(.horizontal)
                    .padding(.vertical, 15)
            }
            .padding(.top, 20)
            // String interpolation used here to avoid localizing the number
            footnote("Automatically refreshes every \(30) seconds.")
                .padding(.top, 8)
                .padding(.leading, 6)
                .padding(.bottom, 30)
            section("Response Time") {
                VStack(alignment: .leading, spacing: 4) {
                    responseTimeChart
                        .padding(.horizontal, 20)
                    let milliseconds = uptimeData.results.map(\.durationMs).reduce(0, +) / uptimeData.results.count
                    footnote("Average: \(formatMilliseconds(milliseconds))")
                        .padding(.leading, 20)
                }
                .padding(.top, 17)
                .padding(.bottom, 8)
            }
            subHeading("Incidents")
                .padding(.top, 30)
                .padding(.bottom, 3)
            let todayDowntimes = uptimeData.downtimes.filter { abs($0.endTime.timeIntervalSinceNow) < 60 * 60 * 24 }
            
            Text(
                todayDowntimes.count == 0
                    ? "There were no recorded incidents today."
                    : "There were \(todayDowntimes.count) recorded incidents today."
            )
            .font(.footnote)
            .foregroundStyle(palette.secondary)
            .padding(.leading, 6)
            .padding(.bottom, 7)
            
            let displayedIncidents = showingAllDowntimes ? uptimeData.downtimes : todayDowntimes
            if !displayedIncidents.isEmpty {
                section(spacing: 0) {
                    ForEach(displayedIncidents) { event in
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
                .padding(.bottom, 30)
            }
            Button {
                withAnimation {
                    showingAllDowntimes.toggle()
                }
            } label: {
                Text(showingAllDowntimes ? "Hide Older Incidents" : "Show Older Incidents")
                    .foregroundStyle(palette.accent)
                    .padding(.leading, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: Constants.main.standardSpacing)
                            .fill(palette.secondaryGroupedBackground)
                    )
            }
            .buttonStyle(EmptyButtonStyle())
            
            if let url = instance.uptimeFrontendUrl {
                // Extra string interpolation used here to avoid unnecessary localization
                Text((try? AttributedString(markdown: .init(localized: "Uptime data fetched from \("[lemmy-status.org](\(url))")"))) ?? .init())
                    .font(.footnote)
                    .foregroundStyle(palette.secondary)
                    .padding(.vertical, 8)
                    .padding(.leading, 6)
            }
        }
        .padding([.horizontal, .bottom], 16)
    }
    
    @ViewBuilder
    var summary: some View {
        VStack(alignment: .leading) {
            if let mostRecentOutage = uptimeData.downtimes.first {
                if uptimeData.results.filter(\.success).count < 15 {
                    summaryHeader(statusText: "unhealthy", systemImage: Icons.uptimeOutage, color: palette.negative)
                    footnote("\(instance.name) has been unresponsive recently.")
                } else {
                    summaryHeader(statusText: "online", systemImage: Icons.uptimeOnline, color: palette.positive)
                    let relTime = mostRecentOutage.relativeTimeCaption
                    let length = mostRecentOutage.differenceTitle(unitsStyle: .full)
                    footnote("The most recent outage was \(relTime), and lasted for \(length).")
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
                            .foregroundStyle(result.success ? palette.positive : palette.negative)
                            .frame(maxWidth: 20)
                            .frame(maxWidth: 25)
                    } else {
                        Circle()
                            .fill(result.success ? palette.positive : palette.negative)
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
            .frame(maxWidth: CGFloat(uptimeData.results.count * 25 + (uptimeData.results.count - 1) * 3))
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
                        Text(formatMilliseconds(intValue))
                    }
                }
            }
        }
    }
    
    @ViewBuilder func section(
        _ title: LocalizedStringResource? = nil,
        spacing: CGFloat = 5,
        @ViewBuilder content: () -> some View
    ) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            if let title {
                subHeading(title)
            }
            VStack(alignment: .leading, spacing: spacing) {
                content()
            }
            .frame(maxWidth: .infinity)
            .background(palette.secondaryGroupedBackground)
            .cornerRadius(Constants.main.standardSpacing)
        }
    }
    
    @ViewBuilder
    func subHeading(_ title: LocalizedStringResource) -> some View {
        Text(title)
            .font(.title2)
            .fontWeight(.semibold)
            .padding(.leading, 6)
    }
    
    @ViewBuilder
    func footnote(_ title: LocalizedStringResource) -> some View {
        Text(title)
            .font(.footnote)
            .foregroundStyle(palette.secondary)
    }
    
    @_disfavoredOverload
    @ViewBuilder
    func footnote(_ title: String) -> some View {
        Text(title)
            .font(.footnote)
            .foregroundStyle(palette.secondary)
    }
    
    var timeOnlyFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .none
        return dateFormatter
    }

    func formatMilliseconds(_ milliseconds: Int) -> String {
        let measurement = Measurement(value: Double(milliseconds), unit: UnitDuration.milliseconds)
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        formatter.unitStyle = .short
        return formatter.string(from: measurement)
    }
}

private struct IncidentRow: View {
    @Environment(Palette.self) var palette
    
    let event: DowntimePeriod
    let showingExactTime: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: Icons.uptimeOutage)
                    .foregroundStyle(event.severityColor)
                    .foregroundStyle(palette.secondary)
                Text("Unhealthy for \(event.differenceTitle())")
            }
            Text(showingExactTime ? event.differenceCaption : event.relativeTimeCaption)
                .font(.footnote)
                .foregroundStyle(palette.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(.rect)
    }
}
