//
//  ImageViewer+Views.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-01-18.
//

import SwiftUI
import Icons

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
            if showCloseButton {
                closeButton
                    .padding(.trailing, Constants.main.standardSpacing)
            }
        }
    }
    
    @ViewBuilder
    var closeButton: some View {
        Button {
            fadeDismiss()
        } label: {
            if #available(iOS 26, *) {
                closeButtonContent
                    .glassEffect(.regular.interactive())
            } else {
                closeButtonContent
                    .background(.ultraThinMaterial, in: .circle)
            }
        }
        .contentShape(.rect)
        .environment(\.colorScheme, .dark)
    }
    
    @ViewBuilder
    var devTools: some View {
        Group {
            if !devToolsShown {
                Button {
                    withAnimation {
                        devToolsShown = true
                    }
                } label: {
                    if #available(iOS 26, *) {
                        devToolsButtonContent
                            .glassEffect(.regular.interactive())
                    } else {
                        devToolsButtonContent
                            .background(.ultraThinMaterial, in: .circle)
                    }
                }
                .contentShape(.rect)
                .environment(\.colorScheme, .dark)
            } else {
                Group {
                    if #available(iOS 26, *) {
                        devToolsContent
                            .glassEffect(.regular.interactive(), in: .rect(cornerRadius: Constants.main.standardSpacing))
                    } else {
                        devToolsContent
                            .background(.ultraThinMaterial, in: .rect(cornerRadius: Constants.main.standardSpacing))
                    }
                }
                .onTapGesture {
                    withAnimation {
                        devToolsShown = false
                    }
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
                
                Group {
                    if #available(iOS 26, *) {
                        bottomControlBarContent
                            .glassEffect(.regular.interactive())
                    } else {
                        bottomControlBarContent
                            .background {
                                Capsule().fill(.ultraThinMaterial)
                            }
                    }
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
        VStack(spacing: Constants.main.halfSpacing) {
            if let readouts = controlState.playbackReadouts {
                HStack {
                    Text(readouts.position)
                    Spacer()
                    Text(readouts.duration)
                }
                .font(.footnote)
                .fontWeight(.semibold)
                .shadow(radius: 2)
            }
            
            playbackBarBaseCapsule
                .frame(maxWidth: .infinity)
                .frame(height: 10)
                .overlay {
                    GeometryReader { geo in
                        let width = geo.size.width - 10 // prevent circle going past end of capsule
                        Circle()
                            .fill(.white)
                            .frame(width: 6, height: 6)
                            .padding(2)
                            .offset(x: (controlState.scrubTarget ?? controlState.playbackPosition) * width)
                            .onAppear {
                                // set playbackBarHitbox to be a bit thicker than the real hitbox
                                let realHitbox = geo.frame(in: .global)
                                playbackBarHitbox = .init(
                                    x: realHitbox.minX,
                                    y: realHitbox.maxY - 80,
                                    width: realHitbox.width,
                                    height: 100
                                )
                            }
                    }
                }
                .environment(\.colorScheme, .dark)
        }
        .padding(.horizontal, Constants.main.standardSpacing)
        .allowsHitTesting(false)
    }
    
    @ViewBuilder
    var playButton: some View {
        Button {
            controlState.animating.toggle()
        } label: {
            Group {
                if #available(iOS 26, *) {
                    playButtonContent
                        .glassEffect(.regular.interactive())
                } else {
                    playButtonContent
                        .background(.ultraThinMaterial, in: .circle)
                }
            }
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
            Label("Save", icon: .general.import)
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
            Label("Share", icon: .general.share)
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
            Label("Quick Look", icon: .general.menu)
                .symbolVariant(.circle)
                .padding(Constants.main.standardSpacing)
                .contentShape(.rect)
        }
    }
    
    @ViewBuilder
    var muteButton: some View {
        Button {
            controlState.muted.toggle()
        } label: {
            Group {
                if #available(iOS 26, *) {
                    muteButtonContent
                        .glassEffect(.regular.interactive())
                } else {
                    muteButtonContent
                        .background(.ultraThinMaterial, in: .circle)
                }
            }
            .padding(.trailing, Constants.main.standardSpacing)
            .padding([.top, .leading], Constants.main.doubleSpacing)
            .contentShape(.rect)
        }
    }
    
    // MARK: Zoom and Scale
    
    @ViewBuilder
    var scaleDisplay: some View {
        Group {
            if #available(iOS 26, *) {
                scaleDisplayContent
                    .glassEffect()
            } else {
                scaleDisplayContent
                    .background {
                        Capsule().fill(.ultraThinMaterial)
                    }
            }
        }
        .environment(\.colorScheme, .dark)
        .padding(.leading, Constants.main.standardSpacing)
        .opacity(scaleDisplayShown ? 1 : 0)
    }
    
    @ViewBuilder
    func buttonLabel(text: LocalizedStringResource, icon: Icon, frameSize: CGFloat, padding: CGFloat) -> some View {
        Label {
            Text(text)
        } icon: {
            Image(icon: icon)
                .resizable()
                .scaledToFit()
                .frame(width: frameSize, height: frameSize)
                .padding(padding)
        }
        .labelStyle(.iconOnly)
    }
    
    @ViewBuilder
    func videoStateButtonLabel(
        isOn: Bool,
        text: (on: LocalizedStringResource, off: LocalizedStringResource),
        icons: (on: Icon, off: Icon)) -> some View {
        Label {
            Text(isOn ? text.on : text.off)
        } icon: {
            Image(icon: isOn ? icons.on : icons.off)
                .symbolVariant(.fill)
                .scaledToFit()
                .frame(width: 22, height: 22)
                .contentTransition(.symbolEffect(.replace, options: .speed(2)))
                .padding(Constants.main.standardSpacing + 4) // +4 to match .title2 implicit padding plus offset
        }
        .labelStyle(.iconOnly)
    }
    
    // MARK: Platform Compatibility
    // TODO: iOS 18 deprecation remove
    
    @ViewBuilder
    var closeButtonContent: some View {
        buttonLabel(text: "Close", icon: .general.close, frameSize: 18, padding: Constants.main.standardSpacing + 6)
    }
    
    @ViewBuilder
    var devToolsButtonContent: some View {
        buttonLabel(
            text: "Toggle Developer Tools",
            icon: .settings.developerMode,
            frameSize: 22,
            padding: Constants.main.standardSpacing + 4
        )
    }
    
    @ViewBuilder
    var devToolsContent: some View {
        VStack(alignment: .leading, spacing: Constants.main.halfSpacing) {
            let imageType: String = url.proxyAwarePathExtension?.lowercased() ?? "Unknown"
            Text(verbatim: "Media Type: \(imageType) ")
            if let duration = controlState.duration {
                Text(verbatim: "Duration: \(String(format: "%.4fs", duration))")
                    .monospacedDigit()
            } else {
                Text(verbatim: "Duration: None")
            }
            Text(verbatim: "Playback Position: \(String(format: "%.4f", controlState.playbackPosition))")
                .monospacedDigit()
            if let target = controlState.scrubTarget {
                Text(verbatim: "Scrub Target: \(String(format: "%.4f", target))")
                    .monospacedDigit()
            } else {
                Text(verbatim: "Scrub Target: None")
            }
            Text(verbatim: "Scrub Rate: \(String(format: "%.4f", scrubRate))")
                .monospacedDigit()
        }
        .padding(Constants.main.standardSpacing)
        .contentShape(.rect)
        .foregroundStyle(.white)
        .font(.footnote)
    }
    
    @ViewBuilder
    var playbackBarBaseCapsule: some View {
        if #available(iOS 26, *) {
            Color.clear.contentShape(.rect)
                .glassEffect()
        } else {
            Capsule()
                .fill(.ultraThinMaterial)
        }
    }
    
    @ViewBuilder
    var bottomControlBarContent: some View {
        HStack {
            saveButton
            shareButton
            quickLookButton
        }
        .padding(.horizontal, Constants.main.halfSpacing)
    }
    
    @ViewBuilder
    var playButtonContent: some View {
        videoStateButtonLabel(
            isOn: controlState.animating,
            text: (on: "Pause", off: "Play"),
            icons: (on: .general.pause, off: .general.play))
    }
    
    @ViewBuilder
    var muteButtonContent: some View {
        videoStateButtonLabel(
            isOn: controlState.muted,
            text: (on: "Mute", off: "Unmute"),
            icons: (on: .general.mute, off: .general.unmute))
    }
    
    @ViewBuilder
    var scaleDisplayContent: some View {
        Text(String(format: "%.1fx", scaleDisplayValue))
            .foregroundStyle(.white)
            .padding(Constants.main.standardSpacing)
            .padding(.horizontal, Constants.main.halfSpacing)
    }
}
