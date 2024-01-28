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
    
    let instance: InstanceModel
    @Binding var uptimeData: UptimeData?
    
    var body: some View {
        VStack {
            if let uptimeData {
                content(uptimeData: uptimeData)
                    .padding(.top)
            } else {
                ProgressView()
                    .padding(.top)
            }
        }
        .onAppear {
            if uptimeData == nil, let url = instance.uptimeDataUrl {
                Task {
                    do {
                        let data = try await URLSession.shared.data(from: url).0
                        uptimeData = try JSONDecoder.defaultDecoder.decode(UptimeData.self, from: data)
                    } catch {
                        errorHandler.handle(error)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func content(uptimeData: UptimeData) -> some View {
        VStack(alignment: .leading) {
            Text("Response Time")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.leading)
            responseTimeChart(uptimeData: uptimeData)
            Divider()
            if let url = instance.uptimeFrontendUrl {
                Text("Uptime data fetched from [lemmy-status.org](\(url))")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    @ViewBuilder
    func responseTimeChart(uptimeData: UptimeData) -> some View {
        Chart {
            ForEach(uptimeData.results) { node in
                LineMark(
                    x: .value("Time", node.timestamp),
                    y: .value("Response Time", Int(node.duration / 1000000))
                )
            }
        }
        .frame(height: 200)
        .padding(.horizontal, 20)
        .chartXAxis {
            let marks = [uptimeData.results.first?.timestamp ?? .distantPast, uptimeData.results.last?.timestamp ?? .distantFuture]
            AxisMarks(format: .dateTime.hour(.twoDigits(amPM: .omitted)).minute(.twoDigits), values: marks)
        }
        .chartYScale(domain: .automatic(includesZero: false))
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
}
