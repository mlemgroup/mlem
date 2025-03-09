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
        @Setting(\.postSize) var postSize
        
        var body: some View {
            Section("Size") {
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
        }
        
        @ViewBuilder var largeItem: some View {
            DevicePickerItem(PostSize.large.label, item: .large, selected: $postSize) {
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
            DevicePickerItem(PostSize.headline.label, item: .headline, selected: $postSize) {
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
            DevicePickerItem(PostSize.tile.label, item: .tile, selected: $postSize) {
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
            DevicePickerItem(PostSize.compact.label, item: .compact, selected: $postSize) {
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
    }
}
