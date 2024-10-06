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
    struct Section: Identifiable {
        let label: String
        var systemImage: String?
        var id: String { label }
    }
    
    let proxy: ScrollViewProxy
    let sections: [Section]
    @GestureState private var dragLocation: CGPoint = .zero

    // Track which sidebar label we picked last so we
    // only send a haptic when selecting a new one
    @State var lastSelectedLabel: String = ""
    
    @State var debounce: Date = .now

    var body: some View {
        VStack {
            ForEach(sections) { communitySection in
                sectionTitle(for: communitySection)
                    .frame(width: 12, height: 6)
            }
        }
        .overlay {
            GeometryReader { geo in
                Color.clear
                    .contentShape(.rect)
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
                                let sectionIndex = min(
                                    Int((value.location.y * Double(sections.count)) / geo.size.height),
                                    sections.count - 1
                                )
                                
                                let sectionLabel = sections[sectionIndex].label
                                
                                if sectionLabel != lastSelectedLabel {
                                    Task { @MainActor in
                                        lastSelectedLabel = sectionLabel
                                        HapticManager.main.play(haptic: .rigidInfo, priority: .low)
                                        
                                        if debounce.advanced(by: 0.25) < .now {
                                            debounce = .now
                                            withAnimation {
                                                proxy.scrollTo(sectionLabel, anchor: .top)
                                            }
                                        }
                                    }
                                }
                            }
                            .onEnded { _ in
                                withAnimation {
                                    proxy.scrollTo(lastSelectedLabel, anchor: .top)
                                }
                            }
                    )
            }
        }
    }
}

// Sidebar Label Views
@ViewBuilder
func sectionTitle(for section: SectionIndexTitles.Section) -> some View {
    if let systemImage = section.systemImage {
        SectionIndexImage(image: systemImage)
    } else {
        SectionIndexText(label: section.label)
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
