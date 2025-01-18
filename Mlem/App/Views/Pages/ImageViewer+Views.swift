//
//  ImageViewer+Views.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-01-18.
//

import SwiftUI

extension ImageViewer {
    
    @ViewBuilder
    var controlOverlay: some View {
        VStack {
            topControlBar
                .offset(y: -controlOffset)

            Spacer()
            
            bottomControlBar
                .offset(y: controlOffset)
        }
        .font(.title2)
        .fontWeight(.light)
        .foregroundStyle(.white)
        .labelStyle(.iconOnly)
        .opacity(controlOpacity)
    }
    
    // MARK: Top control bar
    
    @ViewBuilder
    var topControlBar: some View {
        HStack {
            Spacer()
            closeButton
                .padding(.trailing, Constants.main.standardSpacing)
        }
    }
    
    @ViewBuilder
    var closeButton: some View {
        Button {
            fadeDismiss()
        } label: {
            Label("Close", systemImage: Icons.close)
        }
        .padding(Constants.main.standardSpacing)
        .contentShape(.rect)
        .background {
            Circle().fill(.ultraThinMaterial)
                .environment(\.colorScheme, .dark)
        }
    }
    
    // MARK: Bottom control bar
    
    @ViewBuilder
    var bottomControlBar: some View {
        HStack {
            saveButton
            shareButton
            quickLookButton
        }
        .padding(.horizontal, Constants.main.halfSpacing)
        .background {
            Capsule().fill(.ultraThinMaterial)
                .environment(\.colorScheme, .dark)
        }
    }
    
    @ViewBuilder
    var saveButton: some View {
        Button {
            Task { await saveImage(url: url) }
        } label: {
            Label("Save", systemImage: Icons.import)
        }
        .padding(Constants.main.standardSpacing)
        .contentShape(.rect)
        .offset(y: -2)
    }
    
    @ViewBuilder
    var shareButton: some View {
        Button {
            Task { await shareImage(url: url, navigation: navigation) }
        } label: {
            Label("Share", systemImage: Icons.share)
        }
        .padding(Constants.main.standardSpacing)
        .contentShape(.rect)
        .offset(y: -2)
    }
    
    @ViewBuilder
    var quickLookButton: some View {
        Button {
            Task { await showQuickLook(url: url) }
        } label: {
            Label("QuickLook", systemImage: Icons.menuCircle)
        }
        .padding(Constants.main.standardSpacing)
        .contentShape(.rect)
    }
}
