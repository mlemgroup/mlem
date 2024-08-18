//
//  InteractionBarEditorView.swift
//  Mlem
//
//  Created by Sjmarf on 15/08/2024.
//

import Flow
import SwiftUI

struct InteractionBarEditorView<Configuration: InteractionBarConfiguration>: View {
    @Environment(Palette.self) var palette
    
    enum DropLocation: Equatable {
        case bar(index: Int), tray
    }
    
    @State var items: [Configuration.Item?]
    @State var barPickedUpIndex: Int?
    @State var trayPickedUpItem: Configuration.Item?
    @State var dragLocation: CGPoint = .zero
    @State var dragTranslation: CGSize = .zero
    @State var hoveredDropLocation: DropLocation?
    @State var hoveredDropIndexDistance: CGFloat = .infinity
    
    init(configuration: Configuration) {
        // Where `nil` represents the info stack
        self._items = .init(initialValue: configuration.leading + [nil] + configuration.trailing)
    }
    
    var body: some View {
        ScrollView {
            VStack {
                activeBar
                    .zIndex(barPickedUpIndex == nil ? 0 : 1)
                Divider()
                tray
                    .frame(maxWidth: .infinity)
                    .zIndex(trayPickedUpItem == nil ? 0 : 1)
            }
            .frame(maxWidth: .infinity)
            .padding(Constants.main.standardSpacing)
        }
        .navigationTitle("Interaction Bar")
        .navigationBarTitleDisplayMode(.inline)
        .frame(maxWidth: .infinity)
        .background(palette.groupedBackground)
        .coordinateSpace(.named("editor"))
    }
    
    @ViewBuilder
    var activeBar: some View {
        HStack(spacing: 5) {
            dropLocation(index: 0)
            ForEach(Array(items.enumerated()), id: \.element) { index, item in
                cell { itemLabel(item) }
                    .offset(barPickedUpIndex == index ? dragTranslation : .zero)
                    .background(
                        RoundedRectangle(cornerRadius: Constants.main.smallItemCornerRadius)
                            .fill(barPickedUpIndex == index && dragTranslation != .zero ? palette.accent.opacity(0.2) : Color.clear)
                            .transaction { $0.animation = nil }
                    )
                    .zIndex(barPickedUpIndex == index ? 1 : 0)
                    .gesture(
                        DragGesture(minimumDistance: 0, coordinateSpace: .named("editor"))
                            .onChanged { gesture in
                                barPickedUpIndex = index
                                dragLocation = gesture.location
                                dragTranslation = gesture.translation
                            }
                            .onEnded { _ in
                                withAnimation(.easeOut(duration: 0.1)) {
                                    completeDrag()
                                    dragTranslation = .zero
                                }
                            }
                    )
                dropLocation(index: index + 1)
            }
        }
    }

    @ViewBuilder
    var tray: some View {
        HFlow(justification: .none) {
            ForEach(Array(Configuration.CounterType.allCases.enumerated()), id: \.offset) { _, counter in
                trayItem(.counter(counter))
            }
            ForEach(Array(Configuration.ActionType.allCases.enumerated()), id: \.offset) { _, action in
                trayItem(.action(action))
            }
        }
    }
    
    @ViewBuilder
    func dropLocation(index: Int) -> some View {
        GeometryReader { geometry in
            Capsule()
                .fill(hoveredDropLocation == .bar(index: index) ? palette.accent : .clear)
                .frame(width: 2)
                .frame(height: Constants.main.barIconSize + 24)
                .contentShape(.rect)
                .onChange(of: dragLocation) {
                    let frame = geometry.frame(in: .named("editor"))
                    if let barPickedUpIndex, barPickedUpIndex == index || barPickedUpIndex == index - 1 { return }
                    
                    if let barPickedUpIndex, items[barPickedUpIndex] != nil, dragLocation.y > frame.maxY + 20 {
                        if hoveredDropLocation != .tray {
                            hoveredDropLocation = .tray
                            HapticManager.main.play(haptic: .gentleInfo, priority: .low)
                        }
                        return
                    }
                    if hoveredDropLocation == .tray { hoveredDropLocation = nil }

                    if barPickedUpIndex != nil || trayPickedUpItem != nil {
                        if abs(frame.minX - dragLocation.x) < 50 {
                            if hoveredDropLocation == nil {
                                hoveredDropLocation = .bar(index: index)
                                HapticManager.main.play(haptic: .gentleInfo, priority: .low)
                            }
                        } else {
                            if hoveredDropLocation == .bar(index: index) {
                                hoveredDropLocation = nil
                            }
                        }
                    }
                }
        }
        .frame(width: 2)
        .frame(height: Constants.main.barIconSize + 24)
        .transaction { $0.animation = nil }
    }
    
    @ViewBuilder
    func trayItem(_ item: Configuration.Item) -> some View {
        cell { itemLabel(item) }
            .opacity(items.contains(item) ? 0 : 1)
            .transaction { $0.animation = nil }
            .offset(trayPickedUpItem == item ? dragTranslation : .zero)
            .background {
                RoundedRectangle(cornerRadius: Constants.main.smallItemCornerRadius)
                    .strokeBorder(trayItemOutlineColor(item), lineWidth: 2)
            }
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .named("editor"))
                    .onChanged { gesture in
                        trayPickedUpItem = item
                        dragLocation = gesture.location
                        dragTranslation = gesture.translation
                    }
                    .onEnded { _ in
                        withAnimation(.easeOut(duration: 0.1)) {
                            completeDrag()
                            dragTranslation = .zero
                        }
                    }
            )
            .zIndex(trayPickedUpItem == item ? 1 : 0)
    }
    
    @ViewBuilder
    func itemLabel(_ item: Configuration.Item?) -> some View {
        switch item {
        case let .action(action):
            InteractionBarActionLabelView(action.appearance)
                .frame(width: Constants.main.barIconSize)
        case let .counter(counter):
            InteractionBarCounterLabelView(counter.appearance)
                .fixedSize()
        default:
            Spacer()
        }
    }
    
    @ViewBuilder
    func cell(@ViewBuilder _ view: () -> some View) -> some View {
        view()
            .frame(height: Constants.main.barIconSize)
            .padding(12)
            .background(palette.secondaryGroupedBackground, in: .rect(cornerRadius: Constants.main.smallItemCornerRadius))
    }
}

#Preview {
    NavigationStack {
        InteractionBarEditorView(configuration: PostBarConfiguration.default)
    }
    .environment(Palette.main)
}
