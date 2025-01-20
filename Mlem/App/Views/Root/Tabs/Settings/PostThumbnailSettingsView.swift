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
            VStack(spacing: Constants.main.doubleSpacing) {
                ForEach(ThumbnailLocation.allCases, id: \.self) { location in
                    alignmentPickerItem(location: location)
                }
            }
            .padding(Constants.main.doubleSpacing)
            .listRowInsets(EdgeInsets())
        }
        .animation(.easeOut(duration: 0.1), value: thumbnailLocation)
        .navigationTitle("Thumbnail")
    }
    
    @ViewBuilder
    func alignmentPickerItem(location: ThumbnailLocation) -> some View {
        alignmentPreview(location: location)
        
        .frame(maxWidth: .infinity)
        .onTapGesture {
            HapticManager.main.play(haptic: .gentleInfo, priority: .low)
            thumbnailLocation = location
        }
    }
    
    @ViewBuilder
    func alignmentPreview(location: ThumbnailLocation) -> some View {
        let color: Color = location == thumbnailLocation ? palette.accent : palette.secondary
        HStack(spacing: 6) {
            if location == .left {
                thumbnailView(color)
            }
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
                .foregroundStyle(color)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 2)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            if location == .right {
                thumbnailView(color)
            }
        }
        .aspectRatio(8 / 2, contentMode: .fit)
        .padding(6)
        .background(palette.tertiaryGroupedBackground, in: .rect(cornerRadius: Constants.main.mediumItemCornerRadius))
        .overlay {
            RoundedRectangle(cornerRadius: Constants.main.mediumItemCornerRadius)
                .stroke(location == thumbnailLocation ? palette.accent : .clear, lineWidth: 3)
        }
    }
    
    @ViewBuilder
    func thumbnailView(_ color: Color) -> some View {
        RoundedRectangle(cornerRadius: Constants.main.smallItemCornerRadius)
            .fill(color.opacity(0.3))
            .frame(maxHeight: .infinity)
            .aspectRatio(1, contentMode: .fit)
    }
}
