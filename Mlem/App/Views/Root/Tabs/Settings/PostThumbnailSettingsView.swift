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
    
    var body: some View {
        Form {
            Toggle(
                "Show Thumbnails",
                isOn: .init(
                    get: { thumbnailLocation != .none },
                    set: { newValue in
                        withAnimation {
                            thumbnailLocation = newValue ? .left : .none
                        }
                    }
                )
            )
            if thumbnailLocation != .none {
                Section("Alignment") {
                    HStack {
                        alignmentPickerItem(location: .left)
                        alignmentPickerItem(location: .right)
                    }
                }
            }
        }
        .navigationTitle("Thumbnail")
    }
    
    @ViewBuilder
    func alignmentPickerItem(location: ThumbnailLocation) -> some View {
        VStack(spacing: Constants.main.standardSpacing) {
            alignmentPreview(location: location)
                .padding(.horizontal, Constants.main.standardSpacing)
            HStack {
                Text(location.label)
                Checkbox(isOn: thumbnailLocation == location)
            }
        }
        .frame(maxWidth: .infinity)
        .onTapGesture {
            HapticManager.main.play(haptic: .gentleInfo, priority: .low)
            thumbnailLocation = location
        }
    }
    
    @ViewBuilder
    func alignmentPreview(location: ThumbnailLocation) -> some View {
        HStack(spacing: 5) {
            if location == .left {
                thumbnailView
            }
            GeometryReader { geometry in
                VStack(alignment: .leading, spacing: 4) {
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
            if location == .right {
                thumbnailView
            }
        }
        .aspectRatio(8 / 2, contentMode: .fit)
        .frame(maxWidth: 300)
        .padding(5)
        .background(palette.tertiaryGroupedBackground, in: .rect(cornerRadius: 7))
    }
    
    @ViewBuilder
    var thumbnailView: some View {
        RoundedRectangle(cornerRadius: 5)
            .fill(palette.secondary.opacity(0.3))
            .frame(maxHeight: .infinity)
            .aspectRatio(1, contentMode: .fit)
    }
}
