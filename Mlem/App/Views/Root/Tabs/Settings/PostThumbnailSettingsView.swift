//
//  PostThumbnailSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-18.
//

import SwiftUI

struct PostThumbnailSettingsView: View {
    @Environment(Palette.self) var palette
    
    @Setting(\.thumbnailLocation) var thumbnailLocation
    @Setting(\.websiteThumbnailIcon) var websiteThumbnailIcon
    
    var body: some View {
        Form {
            Section {
                alignmentPreview(location: thumbnailLocation)
                    .animation(.easeInOut(duration: 0.2), value: thumbnailLocation)
            }
            
            Section {
                Picker("Thumbnail Location", selection: $thumbnailLocation) {
                    ForEach(ThumbnailLocation.allCases, id: \.self) { location in
                        Text(location.label).tag(location)
                    }
                }
                .labelsHidden()
                .pickerStyle(.inline)
            }
            
            Section {
                Toggle("Website Icon", isOn: $websiteThumbnailIcon)
            } footer: {
                Text("Indicate link thumbnails with an icon.")
            }
        }
        .navigationTitle("Thumbnail")
    }
    
    @ViewBuilder
    func alignmentPreview(location: ThumbnailLocation) -> some View {
        HStack(spacing: 8) {
            thumbnailView(active: location == .left)
            
            GeometryReader { geometry in
                VStack(alignment: .leading, spacing: 5) {
                    Capsule()
                        .fill(.opacity(0.7))
                        .frame(width: geometry.size.width / 2, height: geometry.size.height / 6)
                    Capsule()
                        .frame(width: geometry.size.width * 4 / 5, height: geometry.size.height / 4)
                    Capsule()
                        .fill(.opacity(0.7))
                        .frame(width: geometry.size.width / 3, height: geometry.size.height / 6)
                }
                .foregroundStyle(palette.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 2)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.leading, location == .left ? 0 : -8)
            
            thumbnailView(active: location == .right)
        }
        .aspectRatio(8 / 2, contentMode: .fit)
        .padding(8)
        .background(palette.tertiaryGroupedBackground, in: .rect(cornerRadius: Constants.main.mediumItemCornerRadius))
    }
    
    @ViewBuilder
    func thumbnailView(active: Bool) -> some View {
        RoundedRectangle(cornerRadius: Constants.main.smallItemCornerRadius)
            .fill(palette.accent.opacity(0.4))
            .frame(maxHeight: .infinity)
            .aspectRatio(.init(width: active ? 1 : 0, height: 1), contentMode: .fit)
            .overlay {
                Image(systemName: Icons.browser)
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(.white)
                    .background(.ultraThinMaterial, in: .circle)
                    .padding(6)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .opacity(websiteThumbnailIcon ? 1 : 0)
                    .opacity(active ? 1 : 0)
                    .animation(.easeIn(duration: 0.2), value: websiteThumbnailIcon)
            }
    }
}
