//
//  AdvancedSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 25/08/2024.
//

import Nuke
import SwiftUI

struct AdvancedSettingsView: View {
    @Environment(Palette.self) var palette

    var body: some View {
        PaletteForm {
            PaletteSection {
                HStack {
                    Text("Cache")
                    Spacer()
                    Text(ByteCountFormatter.string(fromByteCount: Int64(URLCache.shared.currentDiskUsage), countStyle: .file))
                        .foregroundStyle(palette.secondary)
                }
            }
            header: {
                Text("Disk Usage")
            }
            footer: {
                // Nesting "500 MB" so we can change it later without re-localizing
                Text("Images are cached on your device for fast reuse. The maximum cache size is around \("500 MB").")
            }
            Button("Clear Cache") {
                URLCache.shared.removeAllCachedResponses()
                ImagePipeline.shared.cache.removeAll()
            }
        }
        .navigationTitle("Advanced")
    }
}
