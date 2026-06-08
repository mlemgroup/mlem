//
//  AccountListRowBody.swift
//  Mlem
//
//  Created by Sjmarf on 24/05/2024.
//

import NukeUI
import SwiftUI
import Theming

struct AccountListRowBody: View {
    @Environment(AppState.self) private var appState
    @Environment(\.palette) var palette
    
    enum Complication: CaseIterable {
        case instance, lastUsed, responseTime, isActive, unreadCount
    }
    
    let account: any Account
    var unreadCount: Int?
    var responseTime: TimeInterval?
    var complications: Set<Complication> = .instanceAndTime
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            CircleCroppedImageView(account, frame: 40, showProgress: false)
                .padding(.leading, -5)
            VStack(alignment: .leading) {
                Text(account.nickname)
                if let captionText {
                    Text(captionText)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, -2)
            Spacer()
            AccountListRowBodyReadoutView(
                isActive: appState.firstSession.actorId == account.actorId,
                unreadCount: unreadCount,
                complications: complications
            )
        }
        .contentShape(.rect)
        .animation(.easeOut(duration: 0.1), value: animationHash)
    }
    
    var animationHash: Int {
        var hasher = Hasher()
        hasher.combine(unreadCount)
        hasher.combine(responseTime)
        return hasher.finalize()
    }
    
    var timeText: String? {
        switch account.activityState {
        case let .inactive(lastUsed):
            guard let lastUsed else { return nil }
            if abs(lastUsed.timeIntervalSinceNow) < 5 {
                return .init(localized: "Just Now")
            }
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .short
            return formatter.localizedString(for: lastUsed, relativeTo: Date.now)
        case .active:
            return .init(localized: "Now")
        }
    }
    
    var captionText: AttributedString? {
        var output: [AttributedString] = []
        if complications.contains(.instance) {
            if account is GuestAccount {
                output.append(.init(localized: "Guest"))
            } else {
                output.append(.init("@\(account.api.host)"))
            }
        }

        // The responseTime check ensures that we are not showing stale data.
        // Once the unread count has been fetched, the version will have been updated.
        if let software = account.siteSoftware, !software.isSupported, responseTime != nil {
            var str = AttributedString(localized: "Unsupported")
            str.foregroundColor = ThemedColor.themedWarning.resolve(with: palette)
            output.append(str)
        } else {
            if complications.contains(.lastUsed), let timeText {
                if (account as? GuestAccount)?.isSaved ?? true {
                    output.append(.init(timeText))
                } else {
                    output.append(.init(localized: "Temporary"))
                }
            }
            if complications.contains(.responseTime), let responseTime {
                let measurement = Measurement(value: Double(Int(responseTime * 1000)), unit: UnitDuration.milliseconds)
                let formatter = MeasurementFormatter()
                formatter.unitOptions = .providedUnit
                formatter.unitStyle = .short
                output.append(.init(formatter.string(from: measurement)))
            }
        }

        var result = AttributedString()
        for (index, item) in output.enumerated() {
            result += item
            if index < output.count - 1 {
                result += AttributedString(" • ")
            }
        }
        return result
    }
}

private struct AccountListRowBodyReadoutView: View {
    let isActive: Bool
    let unreadCount: Int?
    let complications: Set<AccountListRowBody.Complication>
    
    var body: some View {
        if complications.contains(.isActive), isActive {
            Image(icon: .general.circle)
                .symbolVariant(.fill)
                .foregroundStyle(.themedPositive)
                .font(.system(size: 10.0))
                .padding(.trailing, 7)
        } else {
            Image(icon: .lemmy.notificationCount(unreadCount ?? 0))
                .foregroundStyle(.themedContrastingLabel, .themedWarning)
                .imageScale(.large)
                // For some reason, the animations don't work if we use an `if` statement
                .opacity(unreadCount == nil ? 0 : 1)
        }
    }
}

extension Set<AccountListRowBody.Complication> {
    static let instanceAndTime: Self = [.instance, .lastUsed, .isActive, .unreadCount]
    static let instanceOnly: Self = [.instance, .isActive, .unreadCount]
    static let timeOnly: Self = [.lastUsed, .isActive, .unreadCount]
}
