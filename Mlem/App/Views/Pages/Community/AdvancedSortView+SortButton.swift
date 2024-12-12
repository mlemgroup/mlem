//
//  AdvancedSortView+SortButton.swift
//  Mlem
//
//  Created by Sjmarf on 2024-12-12.
//

import MlemMiddleware
import SwiftUI

extension AdvancedSortView {
    struct SortButton: View {
        @Environment(AppState.self) var appState
        @Environment(Palette.self) var palette
        @Environment(\.dismiss) var dismiss

        let type: ApiSortType
        var topFormat: ApiSortType.TopSortModeFormatStyle = .timescaleFull

        @Binding var selectedSort: ApiSortType
        
        @State var showingExplanation: Bool = false
        
        var body: some View {
            HStack(spacing: Constants.main.standardSpacing) {
                Button {
                    selectedSort = type
                    dismiss()
                } label: {
                    HStack(spacing: Constants.main.standardSpacing) {
                        Image(systemName: type.systemImage)
                            .frame(width: 30, alignment: .center)
                            .foregroundStyle(palette.secondary)
                        VStack(alignment: .leading) {
                            titleView
                            if (appState.firstApi.fetchedVersion ?? .infinity) < type.minimumVersion {
                                Text("Requires Lemmy \(type.minimumVersion) or later")
                                    .multilineTextAlignment(.leading)
                                    .foregroundStyle(palette.warning)
                                    .font(.footnote)
                            }
                        }
                        .padding(.vertical, Constants.main.halfSpacing)
                        Spacer()
                        if selectedSort == type {
                            Image(systemName: "checkmark")
                                .fontWeight(.semibold)
                                .foregroundStyle(palette.accent)
                                .padding(.trailing, Constants.main.halfSpacing)
                        }
                    }
                    .frame(minHeight: 45)
                    .foregroundStyle(palette.primary)
                    .buttonStyle(.plain)
                    .padding(.horizontal, Constants.main.standardSpacing)
                    .background(palette.secondaryGroupedBackground, in: .rect(cornerRadius: Constants.main.standardSpacing))
                    .paletteBorder(cornerRadius: Constants.main.standardSpacing)
                }
                Button("Pin", systemImage: PinnedSortTracker.main.pinnedSortTypes.contains(type) ? Icons.pinFill : Icons.pin) {
                    HapticManager.main.play(haptic: .gentleInfo, priority: .low)
                    if PinnedSortTracker.main.pinnedSortTypes.contains(type) {
                        PinnedSortTracker.main.pinnedSortTypes.remove(type)
                    } else {
                        PinnedSortTracker.main.pinnedSortTypes.insert(type)
                    }
                }
                .labelStyle(.iconOnly)
                .padding(.horizontal, Constants.main.standardSpacing)
                .frame(maxHeight: .infinity)
                .background(palette.secondaryGroupedBackground, in: .rect(cornerRadius: Constants.main.standardSpacing))
                .paletteBorder(cornerRadius: Constants.main.standardSpacing)
            }
            .disabled((appState.firstApi.fetchedVersion ?? .infinity) < type.minimumVersion)
        }
        
        @ViewBuilder
        var titleView: some View {
            HStack(spacing: Constants.main.standardSpacing) {
                Text(type.label(topFormat: topFormat))
                if let explanation = type.explanation {
                    Button {
                        showingExplanation.toggle()
                    } label: {
                        Image(systemName: "questionmark.circle")
                            .foregroundStyle(palette.secondary)
                            .foregroundStyle(palette.primary)
                    }
                    .popover(isPresented: $showingExplanation) {
                        Text(explanation)
                            .fixedSize(horizontal: false, vertical: true)
                            .font(.footnote)
                            .frame(maxWidth: 200)
                            .padding(10)
                            .presentationCompactAdaptation(.popover)
                    }
                    .environment(\.isEnabled, true) // Janky fix to override the higher-level `.disabled` modifier.
                }
            }
        }
    }
}
