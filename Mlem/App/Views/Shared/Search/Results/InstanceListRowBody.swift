//
//  InstanceListRowBody.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-07.
//

import MlemMiddleware
import SwiftUI

struct InstanceListRowBody<Content: View>: View {
    enum Readout { case users }

    @Setting(\.blurNsfw) var blurNsfw
    
    @Environment(Palette.self) var palette
    
    let instance: (any Instance)?
    let summary: InstanceSummary?
    let readout: Readout?
    
    @ViewBuilder let content: () -> Content

    init(
        _ instance: any Instance,
        @ViewBuilder content: @escaping () -> Content = { EmptyView() },
        readout: Readout? = nil
    ) {
        self.instance = instance
        self.summary = nil
        self.content = content
        self.readout = readout
    }
    
    init(
        _ summary: InstanceSummary,
        @ViewBuilder content: @escaping () -> Content = { EmptyView() },
        readout: Readout? = nil
    ) {
        self.summary = summary
        self.instance = nil
        self.content = content
        self.readout = readout
    }
    
    var host: String {
        instance?.host ?? summary?.host ?? ""
    }
    
    var avatar: URL? {
        instance?.avatar ?? summary?.avatar
    }
    
    var version: SiteVersion? {
        instance?.version_ ?? summary?.version
    }

    var body: some View {
        HStack(spacing: Constants.main.standardSpacing) {
            CircleCroppedImageView(
                url: avatar?.withIconSize(128),
                size: Constants.main.listRowAvatarSize,
                fallback: .instance
            )
            .frame(width: Constants.main.listRowAvatarSize, height: Constants.main.listRowAvatarSize)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(host)
                    .lineLimit(1)
                Text(version?.description ?? "")
                    .font(.footnote)
                    .foregroundStyle(palette.secondary)
                    .lineLimit(1)
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
            Text((instance?.userCount_ ?? summary?.userCount ?? 0).abbreviated)
            Image(systemName: Icons.personFill)
                .fontWeight(.semibold)
        }
        .monospacedDigit()
        .foregroundStyle(palette.secondary)
        .symbolRenderingMode(.hierarchical)
    }
}
