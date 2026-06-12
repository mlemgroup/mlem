//
//  CacheSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2026-06-08.
//

import Nuke
import SwiftUI

struct CacheSettingsView: View {
    var body: some View {
        Form {
            SettingsHeaderView(
                title: "Cache",
                description: "Images are cached on your device for fast reuse. The maximum cache size is around \(Self.maximumCacheSize).",
                icon: .settings.cache
            )
            .gradientTint(.themedColorfulAccent(5))

            Section {
                HStack {
                    Text("Disk Usage")
                    Spacer()
                    TimelineView(.periodic(from: .now, by: 0.5)) { _ in
                        Text(ByteCountFormatter.string(fromByteCount: Int64(URLCache.shared.currentDiskUsage), countStyle: .file))
                            .foregroundStyle(.themedSecondary)
                    }
                }
            }
            Button("Clear Cache") {
                URLCache.shared.removeAllCachedResponses()
                ImagePipeline.shared.cache.removeAll()
                ToastModel.main.add(.success("Cache Cleared"))
            }
        }
        .withConditionalLabelStyle()
        .contentMargins(.top, 16)
        .hiddenNavigationTitle("Cache")
    }

    static var maximumCacheSize: String {
        ByteCountFormatter.string(fromByteCount: 500_000_000, countStyle: .file)
    }
}
