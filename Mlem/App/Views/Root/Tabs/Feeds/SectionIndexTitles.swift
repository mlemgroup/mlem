//
//  SectionIndexTitles.swift
//  Mlem
//
//  Created by mormaer on 13/08/2023.
//
//

import Dependencies
import Haptics
import Icons
import SwiftUI

struct SectionIndexTitles: View {
    @Environment(HapticManager.self) var hapticManager
    
    struct Section: Identifiable {
        let label: String
        var icon: Icon?
        var id: String { label }
    }
    
    let sections: [Section]
    @Binding var sectionScroller: Int
    
    init(sections: [SubscriptionListSection], sectionScroller: Binding<Int>) {
        self.sections = sections.map {
            .init(label: $0.label, icon: $0.icon)
        }
        self._sectionScroller = sectionScroller
    }
    
    @GestureState private var dragLocation: CGPoint = .zero

    // Track which sidebar label we picked last so we
    // only send a haptic when selecting a new one
    @State var lastSelectedLabel: String = ""

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
                                        sectionScroller = sectionIndex
                                        hapticManager.play(haptic: .rigidInfo, tier: .low)
                                    }
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
    if let icon = section.icon {
        SectionIndexImage(icon: icon)
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
            .foregroundStyle(.themedPrimary)
    }
}

struct SectionIndexImage: View {
    let icon: Icon
    
    var body: some View {
        Image(icon: icon)
            .resizable()
            .frame(width: 8, height: 8)
            .symbolVariant(.fill)
    }
}
