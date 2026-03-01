//
//  InstanceListRowBody.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-07.
//

import Icons
import MlemMiddleware
import SwiftUI
import Theming

struct InstanceListRowBody<Content: View>: View {
    enum Readout { case users }

    @Setting(\.safety_blurNsfw) var blurNsfw
    
    @Environment(\.isEnabled) var isEnabled
    
    let instance: (any Instance)?
    let summary: InstanceSummary?
    let readout: Readout?
    let showBlockStatus: Bool
    
    @ViewBuilder let content: () -> Content

    init(
        _ instance: any Instance,
        @ViewBuilder content: @escaping () -> Content = { EmptyView() },
        showBlockStatus: Bool = true,
        readout: Readout? = nil
    ) {
        self.instance = instance
        self.summary = nil
        self.showBlockStatus = showBlockStatus
        self.content = content
        self.readout = readout
    }
    
    init(
        _ summary: InstanceSummary,
        @ViewBuilder content: @escaping () -> Content = { EmptyView() },
        showBlockStatus: Bool = true,
        readout: Readout? = nil
    ) {
        self.summary = summary
        self.instance = nil
        self.showBlockStatus = showBlockStatus
        self.content = content
        self.readout = readout
    }
    
    var isBlocked: Bool {
        guard showBlockStatus else { return false }
        if let instance {
            return instance.blockedValue
        }
        if let summary, let session = AppState.main.firstSession as? UserSession, let blocks = session.blocks {
            let actorId = ActorIdentifier.instance(host: summary.host)
            return blocks.contains(instanceActorId: actorId)
        }
        return false
    }
    
    var title: String {
        let hostText = instance?.host ?? summary?.host ?? ""
        if isBlocked {
            return hostText + " ∙ " + String(localized: "Blocked")
        }
        return hostText
    }
    
    var avatar: URL? {
        instance?.avatar ?? summary?.avatar
    }
    
    var software: SiteSoftware? {
        instance?.software_ ?? summary?.software
    }

    var body: some View {
        HStack(spacing: Constants.main.standardSpacing) {
            if isBlocked {
                Image(icon: .general.hide)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .padding(9)
            } else {
                CircleCroppedImageView(
                    url: avatar?.withIconSize(128),
                    frame: Constants.main.listRowAvatarSize,
                    fallback: .instanceAvatar
                )
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .foregroundStyle(isEnabled ? .themedPrimary : .themedSecondary)
                    .lineLimit(1)
                if let software {
                    Text(software.label)
                        .font(.footnote)
                        .foregroundStyle(.themedSecondary)
                        .lineLimit(1)
                }
            }
            Spacer()
            switch readout {
            case .users:
                userCountReadout
            case nil:
                content()
            }
        }
        .padding(.horizontal)
        .contentShape(.rect)
    }
    
    var userCountReadout: some View {
        HStack {
            Text((instance?.userCount_ ?? summary?.totalUsers ?? 0).abbreviated)
            Image(icon: .lemmy.person)
                .symbolVariant(.fill)
                .fontWeight(.semibold)
        }
        .monospacedDigit()
        .foregroundStyle(.themedSecondary)
        .symbolRenderingMode(.hierarchical)
    }
}
