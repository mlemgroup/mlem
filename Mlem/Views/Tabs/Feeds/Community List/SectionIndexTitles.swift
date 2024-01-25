//
//  SectionIndexTitles.swift
//  Mlem
//
//  Created by mormaer on 13/08/2023.
//
//

import Dependencies
import SwiftUI

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
                sectionTitle(for: communitySection)
                    .frame(width: 12, height: 6)
            }
        }
        .overlay {
            GeometryReader { geo in
                // Color.clear doesn't register gestures (presumably because it never gets drawn), so we fake it
                Color.black
                    .opacity(0.00000000001)
                    .gesture(
                        DragGesture(minimumDistance: 0, coordinateSpace: .local)
                            .updating($dragLocation) { value, _, _ in
                                // ignore if out of bounds--actually add a tiny bit of padding to the left side to make it feel right
                                guard value.location.x > -20.0, value.location.y >= 0.0, value.location.y <= geo.size.height else {
                                    return
                                }
                                
                                // compute which section is currently dragged
                                // height of one section is communitySections.count / geo.size.height
                                // drag is thus (value.location.y / (communitySections.count / geo.size.height )) sections up
                                // then do some algebra to make it prettier and round down to int
                                let sectionIndex = Int((value.location.y * Double(communitySections.count)) / geo.size.height)
                                
                                guard sectionIndex < communitySections.count else {
                                    assertionFailure("Invalid section index! The math must be wrong.")
                                    return
                                }
                                
                                let sectionLabel = communitySections[sectionIndex].viewId
                                
                                if sectionLabel != lastSelectedLabel {
                                    DispatchQueue.main.async {
                                        lastSelectedLabel = sectionLabel
                                        proxy.scrollTo(sectionLabel, anchor: .center)

                                        // Play nice tappy taps
                                        hapticManager.play(haptic: .rigidInfo, priority: .low)
                                    }
                                }
                            }
                    )
            }
        }
        .padding(.vertical, 6)
        .background {
            Capsule()
                .foregroundStyle(.ultraThinMaterial)
        }
    }
}

// Sidebar Label Views
@ViewBuilder
func sectionTitle(for communitySection: CommunityListSection) -> some View {
    if let icon = communitySection.sidebarEntry.sidebarIcon {
        SectionIndexImage(image: icon)
    } else if let label = communitySection.sidebarEntry.sidebarLabel {
        SectionIndexText(label: label)
    } else {
        EmptyView()
    }
}

struct SectionIndexText: View {
    let label: String
    var body: some View {
        Text(label)
            .font(.system(size: 11))
            .fontWeight(.semibold)
    }
}

struct SectionIndexImage: View {
    let image: String
    var body: some View {
        Image(systemName: image).resizable()
            .frame(width: 8, height: 8)
    }
}
