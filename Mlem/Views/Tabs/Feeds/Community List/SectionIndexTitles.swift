//
//  SectionIndexTitles.swift
//  Mlem
//
//  Created by mormaer on 13/08/2023.
//
//

import Dependencies
import SwiftUI

// Original article here: https://www.fivestars.blog/code/section-title-index-swiftui.html
struct SectionIndexTitles: View {
    @Dependency(\.hapticManager) var hapticManager
    
    let proxy: ScrollViewProxy
    let communitySections: [CommunityListSection]
    @GestureState private var dragLocation: CGPoint = .zero

    // Track which sidebar label we picked last to we
    // only haptic when selecting a new one
    @State var lastSelectedLabel: String = ""

    var body: some View {
        VStack {
            ForEach(communitySections) { communitySection in
                HStack {
                    if let icon = communitySection.sidebarEntry.sidebarIcon {
                        SectionIndexImage(image: icon)
                    } else if let label = communitySection.sidebarEntry.sidebarLabel {
                        SectionIndexText(label: label)
                    } else {
                        EmptyView()
                    }
                }
                .background(dragObserver(viewId: communitySection.viewId))
            }
        }
        .padding(2)
        .padding(.top, 4)
        .background {
            Capsule()
                .foregroundStyle(.ultraThinMaterial)
        }
        .gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .global)
                .updating($dragLocation) { value, state, _ in
                    state = value.location
                }
        )
    }

    func dragObserver(viewId: String) -> some View {
        GeometryReader { geometry in
            dragObserver(geometry: geometry, viewId: viewId)
        }
    }

    func dragObserver(geometry: GeometryProxy, viewId: String) -> some View {
        if geometry.frame(in: .global).contains(dragLocation) {
            if viewId != lastSelectedLabel {
                DispatchQueue.main.async {
                    lastSelectedLabel = viewId
                    proxy.scrollTo(viewId, anchor: .center)

                    // Play nice tappy taps
                    hapticManager.play(haptic: .rigidInfo, priority: .low)
                }
            }
        }
        return Rectangle().fill(Color.clear)
    }
}

// Sidebar Label Views
struct SectionIndexText: View {
    let label: String
    var body: some View {
        Text(label).font(.system(size: 11)).fontWeight(.semibold)
    }
}

struct SectionIndexImage: View {
    let image: String
    var body: some View {
        Image(systemName: image).resizable()
            .frame(width: 8, height: 8)
    }
}
