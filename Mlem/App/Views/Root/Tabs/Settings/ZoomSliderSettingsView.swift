//
//  ZoomSliderSettingsView.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-02-02.
//

import SwiftUI

enum AnimationPhase: CaseIterable {
    case slideUp, slideDown, hide, show
    
    var circleOffset: CGFloat {
        switch self {
        case .slideUp: -50
        case .slideDown: 50
        case .hide: 50
        case .show: 50
        }
    }
    
    var circleOpacity: CGFloat {
        switch self {
        case .slideUp: 1
        case .slideDown: 1
        case .hide: 0
        case .show: 1
        }
    }
    
    var imageScale: CGFloat {
        switch self {
        case .slideUp: 2.0
        case .slideDown: 0.8
        case .hide: 0.8
        case .show: 0.8
        }
    }
    
    var imageSize: CGFloat {
        switch self {
        case .slideUp: 400
        case .slideDown: 150
        case .hide: 150
        case .show: 150
        }
    }
}

struct ZoomSliderSettingsView: View {
    @Setting(\.zoomSliderLocation) var zoomSliderLocation
    
    var body: some View {
        Form {
            SettingsHeaderView(
                title: "Slide to Zoom",
                description: "Zoom the image viewer with a slide gesture on the selected side."
            ) {
                ZoomSliderAnimation()
            }
            
            Picker("Location", selection: $zoomSliderLocation) {
                ForEach(ZoomSliderLocation.allCases, id: \.self) { location in
                    Label(String(localized: location.label), systemImage: location.systemImage)
                        .tag(location)
                }
            }
            .labelsHidden()
            .pickerStyle(.inline)
        }
        .labelStyle(.conditional)
        .contentMargins(.top, 16)
    }
}

struct ZoomSliderAnimation: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(.black)
            .frame(width: 72, height: 152)
            .phaseAnimator(AnimationPhase.allCases) { content, phase in
                content
                    .overlay {
                        Image(systemName: "bird.fill")
                            .resizable()
                            .scaledToFit()
                            .scaleEffect(phase.imageScale)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    .clipped()
                    .overlay(alignment: .leading) {
                        Circle()
                            .frame(width: 10, height: 10)
                            .foregroundStyle(.themedAccent)
                            .opacity(phase.circleOpacity)
                            .offset(y: phase.circleOffset)
                            .padding(.leading, 4)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } animation: { phase in
                switch phase {
                case .hide: .easeOut(duration: 1.0)
                case .show: .easeOut(duration: 0.1)
                default: .easeInOut(duration: 0.75)
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(.themedNeutralAccent, lineWidth: 2)
            }
    }
}
