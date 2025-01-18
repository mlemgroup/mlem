//
//  PostSettingsView+PostSizePicker.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-18.
//

import Flow
import SwiftUI

extension PostSettingsView {
    struct PostSizePicker: View {
        @Environment(Palette.self) var palette
        
        @Setting(\.postSize) var postSize
        
        var body: some View {
            Section("Post Size") {
                ViewThatFits {
                    HStack(spacing: 0) {
                        largeItem
                        headlineItem
                        tiledItem
                        compactItem
                    }
                    VStack {
                        HStack { largeItem; headlineItem }
                        HStack { tiledItem; compactItem }
                    }
                }
                .listRowInsets(.init(top: 16, leading: 5, bottom: 16, trailing: 5))
            }
            .font(.footnote)
        }
        
        @ViewBuilder var largeItem: some View {
            pickerItem(type: .large) {
                VStack(spacing: 3) {
                    ForEach(0 ..< 2) { _ in
                        RoundedRectangle(cornerRadius: 2)
                            .overlay {
                                RoundedRectangle(cornerRadius: 1)
                                    .opacity(0.5)
                                    .padding(.horizontal, 3)
                                    .padding(.top, 8)
                                    .padding(.bottom, 6)
                                    .blendMode(.destinationOut)
                            }
                            .compositingGroup()
                            .aspectRatio(3 / 4, contentMode: .fit)
                    }
                }
                .padding(.top, 4)
            }
        }
        
        @ViewBuilder var headlineItem: some View {
            pickerItem(type: .headline) {
                VStack(spacing: 3) {
                    ForEach(0 ..< 7) { _ in
                        RoundedRectangle(cornerRadius: 2)
                            .frame(height: 18)
                            .overlay(alignment: .topLeading) {
                                RoundedRectangle(cornerRadius: 1)
                                    .opacity(0.5)
                                    .frame(width: 7, height: 7)
                                    .padding(.top, 5)
                                    .padding(.leading, 2)
                                    .blendMode(.destinationOut)
                            }
                            .compositingGroup()
                    }
                }
                .padding(.top, 4)
            }
        }
        
        @ViewBuilder var tiledItem: some View {
            pickerItem(type: .tile) {
                VStack(spacing: 3) {
                    ForEach(0 ..< 5) { _ in
                        HStack(spacing: 3) {
                            ForEach(0 ..< 2) { _ in
                                Rectangle()
                                    .overlay(alignment: .topLeading) {
                                        RoundedRectangle(cornerRadius: 1)
                                            .opacity(0.5)
                                            .padding(.bottom, 6)
                                            .blendMode(.destinationOut)
                                    }
                                    .clipShape(.rect(cornerRadius: 2))
                                    .aspectRatio(3 / 4, contentMode: .fit)
                            }
                        }
                    }
                }
                .padding(.top, 4)
            }
        }
        
        @ViewBuilder var compactItem: some View {
            pickerItem(type: .compact) {
                VStack(spacing: 3) {
                    ForEach(0 ..< 7) { _ in
                        RoundedRectangle(cornerRadius: 2)
                            .frame(height: 11)
                            .overlay(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 1)
                                    .opacity(0.5)
                                    .aspectRatio(1, contentMode: .fit)
                                    .padding(2)
                                    .blendMode(.destinationOut)
                            }
                            .compositingGroup()
                    }
                }
                .padding(.top, 4)
            }
        }
        
        @ViewBuilder
        func pickerItem(
            type: PostSize,
            @ViewBuilder screenContent: @escaping () -> some View
        ) -> some View {
            VStack {
                SettingsDeviceView(selected: postSize == type, screenContent: screenContent)
                Text(type.label)
                    .lineLimit(1)
                    .foregroundStyle(postSize == type ? palette.selectedInteractionBarItem : palette.primary)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 10)
                    .background(postSize == type ? palette.accent : .clear, in: .capsule)
            }
            .onTapGesture {
                HapticManager.main.play(haptic: .gentleInfo, priority: .low)
                withAnimation(.easeOut(duration: 0.1)) {
                    postSize = type
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}
