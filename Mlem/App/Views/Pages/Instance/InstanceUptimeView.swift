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
    @Environment(\.palette) var palette
    
    @State var showingExactTime: Bool = false
    @State var showingAllDowntimes: Bool = false
    
    let instance: any Instance
    @State var uptimeData: UptimeData
    
    var uptimeRefreshTimer = Timer.publish(every: 30, tolerance: 0.5, on: .main, in: .common)
        .autoconnect()
    
    var body: some View {
        ScrollView {
            content
                .padding(.top, 16)
        }
        .background(.themedGroupedBackground)
        .onReceive(uptimeRefreshTimer) { _ in
            Task {
                let uptimeStatus = await loadUptimeData(instance: instance)
                switch uptimeStatus {
                case .success(let uptimeData):
                    withAnimation(.easeOut(duration: 0.2)) {
                        self.uptimeData = uptimeData
                    }
                case .unavailable:
                    assertionFailure("Uptime data unavailable.")
                case .failure(let error):
                    handleError(error)
                }
            }
        }
        .navigationTitle("Uptime")
    }
    
    @ViewBuilder
    var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            section { summary }
                .padding(.bottom, 10)
            section("Recent Checks") {
                RecentUptimeChecks(results: uptimeData.results)
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
            .foregroundStyle(.themedSecondary)
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
                    .foregroundStyle(.themedAccent)
                    .padding(.leading, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 10)
                    .background(.themedSecondaryGroupedBackground, in: .rect(cornerRadius: Constants.main.standardSpacing))
            }
            .buttonStyle(.empty)
            
            if let url = instance.uptimeFrontendUrl {
                // Extra string interpolation used here to avoid unnecessary localization
                Text(
                    (try? AttributedString(
                        markdown: .init(localized: "Uptime data fetched from \("[lemmy-status.org](\(url))")"))
                    ) ?? .init()
                )
                .font(.footnote)
                .foregroundStyle(.themedSecondary)
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
                    summaryHeader(isHealthy: false)
                    footnote("\(instance.name) has been unresponsive recently.")
                } else {
                    summaryHeader(isHealthy: true)
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
    func summaryHeader(isHealthy: Bool) -> some View {
        HStack(spacing: 5) {
            summaryHeaderText(isHealthy: isHealthy)
                .font(.title2)
            Image(icon: isHealthy ? .uptime.online : .uptime.outage)
                .symbolVariant(.circle.fill)
                .foregroundStyle(isHealthy ? .themedPositive : .themedNegative)
        }
        .fontWeight(.semibold)
    }
    
    func summaryHeaderText(isHealthy: Bool) -> some View {
        let resource: LocalizedStringResource
        let color: Color
        if isHealthy {
            resource = .init(
                "\(instance.name) is {{online}}",
                comment: "The word(s) within the curly brackets will be colored green."
            )
            color = palette.positive
        } else {
            resource = .init(
                "\(instance.name) is {{unhealthy}}",
                comment: "The word(s) within the curly brackets will be colored red."
            )
            color = palette.negative
        }
        let string = String(localized: resource)
        let parts = string.split(separator: /\{\{|\}\}/, omittingEmptySubsequences: false)
        guard parts.count == 3 else {
            assertionFailure()
            return Text(string)
        }
        return Text(parts[0]) + Text(parts[1]).foregroundColor(color) + Text(parts[2])
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
            .background(.themedSecondaryGroupedBackground)
            .cornerRadius(Constants.main.standardSpacing)
            .paletteBorder(cornerRadius: Constants.main.standardSpacing)
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
            .foregroundStyle(.themedSecondary)
    }
    
    @_disfavoredOverload
    @ViewBuilder
    func footnote(_ title: String) -> some View {
        Text(title)
            .font(.footnote)
            .foregroundStyle(.themedSecondary)
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
    let event: DowntimePeriod
    let showingExactTime: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(icon: .uptime.outage)
                    .symbolVariant(.fill)
                    .foregroundStyle(event.severityColor)
                    .foregroundStyle(.themedSecondary)
                Text("Unhealthy for \(event.differenceTitle())")
            }
            Text(showingExactTime ? event.differenceCaption : event.relativeTimeCaption)
                .font(.footnote)
                .foregroundStyle(.themedSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(.rect)
    }
}
