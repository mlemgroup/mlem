//
//  AdvancedSettingsView.swift
//  Mlem
//
//  Created by Sam Marfleet on 14/07/2023.
//

import Nuke
import SwiftUI

struct AdvancedSettingsView: View {
    @AppStorage("developerMode") var developerMode: Bool = false
    
    @State private var diskUsage: Int64 = 0
    
    var body: some View {
        List {
            Section {
                SwitchableSettingsItem(
                    settingPictureSystemName: Icons.developerMode,
                    settingName: "Developer Mode",
                    isTicked: $developerMode
                )
            }
            
            Section {
                HStack {
                    Text("Cache")
                    Spacer()
                    Text("\(ByteCountFormatter.string(fromByteCount: diskUsage, countStyle: .file))")
                        .foregroundStyle(.secondary)
                }
            }
            header: {
                Text("Disk Usage")
            }
            footer: {
                Text("Images are cached on your device for fast reuse. The maximum cache size is around 500 MB.")
            }
            Section {
                Button("Clear Cache") {
                    URLCache.shared.removeAllCachedResponses()
                    ImagePipeline.shared.cache.removeAll()
                    diskUsage = Int64(URLCache.shared.currentDiskUsage)
                }
            }
        }
        .onAppear {
            diskUsage = Int64(URLCache.shared.currentDiskUsage)
        }
        .refreshable {
            diskUsage = Int64(URLCache.shared.currentDiskUsage)
        }
        .navigationTitle("Advanced")
        .navigationBarColor()
    }
}
