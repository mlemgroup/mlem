//
//  ImageViewer+Views.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-01-18.
//

import SwiftUI
import Icons

extension ImageViewer {
    struct ControlTranslationEffect: GeometryEffect {
        var offset: CGFloat
        var isDismissing: Bool

        var animatableData: CGFloat {
            get { isDismissing ? 0 : offset }
            set { offset = newValue }
        }

        func effectValue(size: CGSize) -> ProjectionTransform {
            return ProjectionTransform(.init(translationX: 0, y: offset))
        }
    }

    @ViewBuilder
    var controlOverlay: some View {
        VStack {
            topControlBar
                .modifier(ControlTranslationEffect(offset: -controlOffset, isDismissing: isDismissing))
            Spacer()
            bottomControlBar
                .modifier(ControlTranslationEffect(offset: controlOffset, isDismissing: isDismissing))
        }
        .font(.title2)
        .fontWeight(.light)
        .buttonStyle(.plain)
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
            buttonLabel(text: "Close", icon: .general.close, frameSize: 18, padding: Constants.main.standardSpacing + 6)
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
                    buttonLabel(
                        text: "Toggle Developer Tools",
                        icon: .settings.developerMode,
                        frameSize: 22,
                        padding: Constants.main.standardSpacing + 4
                    )
                }
                .contentShape(.rect)
                .environment(\.colorScheme, .dark)
            } else {
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
                .font(.footnote)
                .glassEffect(.regular.interactive(), in: .rect(cornerRadius: Constants.main.standardSpacing))
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
                
                HStack {
                    saveButton
                    shareButton
                    quickLookButton
                }
                .padding(.horizontal, Constants.main.halfSpacing)
                .glassEffect(.regular.interactive())
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
            
            Color.clear.contentShape(.rect)
                .glassEffect()
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
            videoStateButtonLabel(
                isOn: controlState.animating,
                text: (on: "Pause", off: "Play"),
                icons: (on: .general.pause, off: .general.play))
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
            videoStateButtonLabel(
                isOn: controlState.muted,
                text: (on: "Mute", off: "Unmute"),
                icons: (on: .general.mute, off: .general.unmute))
            .padding(.trailing, Constants.main.standardSpacing)
            .padding([.top, .leading], Constants.main.doubleSpacing)
            .contentShape(.rect)
        }
    }
    
    // MARK: Zoom and Scale
    
    @ViewBuilder
    var scaleDisplay: some View {
        Text(String(format: "%.1fx", scaleDisplayValue))
            .padding(Constants.main.standardSpacing)
            .padding(.horizontal, Constants.main.halfSpacing)
            .glassEffect()
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
        .glassEffect(.regular.interactive())
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
        .glassEffect(.regular.interactive())
    }
}
