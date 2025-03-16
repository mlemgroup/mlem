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
        HStack(alignment: .top) {
            Spacer()
            if developerMode {
                devTools
            }
            closeButton
                .padding(.trailing, Constants.main.standardSpacing)
        }
    }
    
    @ViewBuilder
    var closeButton: some View {
        Button {
            fadeDismiss()
        } label: {
            Image(systemName: Icons.close)
                .resizable()
                .scaledToFit()
                .frame(width: 18, height: 18)
                .accessibilityLabel("Close")
                .padding(Constants.main.standardSpacing + 6)
                .background(.ultraThinMaterial, in: .circle)
        }
        .contentShape(.rect)
        .environment(\.colorScheme, .dark)
    }
    
    @ViewBuilder
    var devTools: some View {
        Group {
            if !devToolsShown {
                Button {
                    devToolsShown = true
                } label: {
                    Image(systemName: Icons.developerMode)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                        .accessibilityLabel("Close")
                        .padding(Constants.main.standardSpacing + 4)
                        .background(.ultraThinMaterial, in: .circle)
                }
                .contentShape(.rect)
                .environment(\.colorScheme, .dark)
            } else {
                VStack(alignment: .leading, spacing: Constants.main.halfSpacing) {
                    let imageType: String = url.proxyAwarePathExtension?.lowercased() ?? "Unknown"
                    Text("Media Type: \(imageType) ")
                    Text("Playback Position: \(String(format: "%.4f", controlState.playbackPosition))")
                        .monospacedDigit()
                    if let target = controlState.scrubTarget {
                        Text("Scrub Target: \(String(format: "%.4f", target))")
                            .monospacedDigit()
                    } else {
                        Text("Scrub Target: None")
                    }
                }
                .padding(Constants.main.standardSpacing)
                .foregroundStyle(.white)
                .font(.footnote)
                .background(.ultraThinMaterial, in: .rect(cornerRadius: Constants.main.standardSpacing))
                .onTapGesture {
                    devToolsShown = false
                }
            }
        }
        .environment(\.colorScheme, .dark)
    }
    
    // MARK: Bottom control bar
    
    @ViewBuilder
    var bottomControlBar: some View {
        VStack(spacing: 0) {
            if controlState.animationAvailable {
                playbackBar
            }
            
            ZStack(alignment: .bottom) {
                if controlState.animationAvailable {
                    playButton
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                HStack {
                    saveButton
                    shareButton
                    quickLookButton
                }
                .padding(.horizontal, Constants.main.halfSpacing)
                .background {
                    Capsule().fill(.ultraThinMaterial)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                
                if controlState.audioAvailable {
                    muteButton
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
        }
        .environment(\.colorScheme, .dark)
    }
    
    @ViewBuilder
    var playbackBar: some View {
        Capsule()
            .fill(.ultraThinMaterial)
            .frame(maxWidth: .infinity)
            .frame(height: 20)
            .overlay {
                GeometryReader { geo in
                    // prevent circle from being dragged over the edge of the capsule
                    let draggableWidth = geo.size.width - 20
                    Circle()
                        .fill(.white)
                        .frame(width: 20, height: 20)
                        .offset(x: (controlState.scrubTarget ?? controlState.playbackPosition) * draggableWidth)
                        .highPriorityGesture(DragGesture()
                            .onChanged { value in
                                if value.location.x >= 0, value.location.x <= draggableWidth {
                                    controlState.scrubTarget = value.location.x / draggableWidth
                                }
                            }
                            .onEnded { _ in
                                controlState.scrubTarget = nil
                            }
                        )
                }
            }
            .padding(.horizontal, Constants.main.standardSpacing)
    }
    
    @ViewBuilder
    var playButton: some View {
        Button {
            controlState.animating.toggle()
        } label: {
            Image(systemName: controlState.animating ? Icons.pause : Icons.play)
                .scaledToFit()
                .frame(width: 22, height: 22)
                .contentTransition(.symbolEffect(.replace, options: .speed(2)))
                .padding(Constants.main.standardSpacing + 4) // +4 to match .title2 implicit padding plus offset
                .background(.ultraThinMaterial, in: .circle)
                .padding(.leading, Constants.main.standardSpacing)
                .padding([.top, .trailing], Constants.main.doubleSpacing)
                .contentShape(.rect)
        }
    }
    
    @ViewBuilder
    var saveButton: some View {
        Button {
            Task { await saveMedia(url: url) }
        } label: {
            Label("Save", systemImage: Icons.import)
                .padding(Constants.main.standardSpacing)
                .contentShape(.rect)
        }
        .offset(y: -2)
    }
    
    @ViewBuilder
    var shareButton: some View {
        Button {
            Task { await shareImage(url: url, navigation: navigation) }
        } label: {
            Label("Share", systemImage: Icons.share)
                .padding(Constants.main.standardSpacing)
                .contentShape(.rect)
        }
        .offset(y: -2)
    }
    
    @ViewBuilder
    var quickLookButton: some View {
        Button {
            Task { await showQuickLook(url: url) }
        } label: {
            Label("Quick Look", systemImage: Icons.menuCircle)
                .padding(Constants.main.standardSpacing)
                .contentShape(.rect)
        }
    }
    
    @ViewBuilder
    var muteButton: some View {
        Button {
            controlState.muted.toggle()
        } label: {
            Image(systemName: controlState.muted ? Icons.muted : Icons.unmuted)
                .scaledToFit()
                .frame(width: 22, height: 22)
                .contentTransition(.symbolEffect(.replace, options: .speed(2)))
                .padding(Constants.main.standardSpacing + 4) // +3 to match .title2 implicit padding plus offset
                .background(.ultraThinMaterial, in: .circle)
                .padding(.trailing, Constants.main.standardSpacing)
                .padding([.top, .leading], Constants.main.doubleSpacing)
                .contentShape(.rect)
        }
    }
    
    // MARK: Zoom and Scale
    
    @ViewBuilder
    var scaleDisplay: some View {
        Text(String(format: "%.1fx", currentScale))
            .foregroundStyle(.white)
            .padding(Constants.main.standardSpacing)
            .padding(.horizontal, Constants.main.halfSpacing)
            .background {
                Capsule().fill(.ultraThinMaterial)
                    .environment(\.colorScheme, .dark)
            }
            .padding(.leading, Constants.main.standardSpacing)
            .opacity(scaleDisplayShown ? 1 : 0)
    }
    
    @ViewBuilder
    var zoomSliderOverlay: some View {
        HStack {
            if zoomSliderLocation == .left || zoomSliderLocation == .either {
                zoomSlider
            }
            
            Spacer()
            
            if zoomSliderLocation == .right || zoomSliderLocation == .either {
                zoomSlider
            }
        }
    }
    
    @ViewBuilder
    var zoomSlider: some View {
        Color.clear
            .contentShape(.rect)
            .frame(width: 40)
            .frame(maxHeight: .infinity)
            .highPriorityGesture(DragGesture()
                .onChanged { value in
                    guard offset == 0 else { return }
                    
                    let baseScale: CGFloat
                    if let dragStartedScale {
                        baseScale = dragStartedScale
                    } else {
                        baseScale = currentScale
                        dragStartedScale = currentScale
                    }
                    
                    let newScale = baseScale + (value.translation.height / -60)
                    if newScale <= 1.0 {
                        currentScale = 1.0
                    } else if newScale >= 4.0 {
                        currentScale = 4.0
                    } else {
                        currentScale = newScale
                    }
                }
                .onEnded { _ in
                    dragStartedScale = nil
                }
                .updating($scaleDragState) { _, state, _ in
                    state = true
                })
            .padding(.vertical, 70) // avoid conflict with control bars
    }
}
