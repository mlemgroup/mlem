//
//  InteractionBarEditorView.swift
//  Mlem
//
//  Created by Sjmarf on 15/08/2024.
//

import Flow
import SwiftUI

struct InteractionBarEditorView<Configuration: InteractionBarConfiguration>: View {
    @Environment(Palette.self) private var palette
    
    @State var items: [Configuration.Item?]
    @State var pickedUpIndex: Int?
    @State var dragLocation: CGPoint = .zero
    @State var dragTranslation: CGSize = .zero
    @State var hoveredDropIndex: Int?
    @State var hoveredDropIndexDistance: CGFloat = .infinity
    
    init(configuration: Configuration) {
        // Where `nil` represents the info stack
        self._items = .init(initialValue: configuration.leading + [nil] + configuration.trailing)
    }
    
    var body: some View {
        ScrollView {
            VStack {
                activeBar()
                    .zIndex(1)
                Divider()
                HFlow(justification: .none) {
                    ForEach(Array(Configuration.CounterType.allCases.enumerated()), id: \.offset) { _, counter in
                        cell { InteractionBarCounterLabelView(counter.appearance) }
                    }
                    ForEach(Array(Configuration.ActionType.allCases.enumerated()), id: \.offset) { _, action in
                        cell {
                            InteractionBarActionLabelView(action.appearance)
                                .frame(width: Constants.main.barIconSize)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
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
    func activeBar() -> some View {
        HStack(spacing: 5) {
            dropLocation(index: 0)
            ForEach(Array(items.enumerated()), id: \.element) { index, item in
                cell {
                    switch item {
                    case let .action(action):
                        InteractionBarActionLabelView(action.appearance)
                            .frame(width: Constants.main.barIconSize)
                    case let .counter(counter):
                        InteractionBarCounterLabelView(counter.appearance)
                    default:
                        Spacer()
                    }
                }
                .offset(pickedUpIndex == index ? dragTranslation : .zero)
                .background(
                    RoundedRectangle(cornerRadius: Constants.main.smallItemCornerRadius)
                        .fill(pickedUpIndex == index && dragTranslation != .zero ? palette.accent.opacity(0.2) : Color.clear)
                        .transaction { $0.animation = nil }
                )
                .zIndex(pickedUpIndex == index ? 1 : 0)
                .gesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .named("editor"))
                        .onChanged { gesture in
                            pickedUpIndex = index
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
    func dropLocation(index: Int) -> some View {
        GeometryReader { geometry in
            let frame = geometry.frame(in: .named("editor"))
            let point = CGPoint(x: frame.minX, y: frame.minY)
            let isHovered = point.distance(to: dragLocation) < 50 && pickedUpIndex != index && pickedUpIndex != index - 1
            Capsule()
                .fill(hoveredDropIndex == index ? palette.accent : .clear)
                .frame(width: 2)
                .frame(height: Constants.main.barIconSize + 24)
                .contentShape(.rect)
                .onChange(of: dragLocation) {
                    if pickedUpIndex != nil {
                        if isHovered, hoveredDropIndex == nil {
                            hoveredDropIndex = index
                            HapticManager.main.play(haptic: .gentleInfo, priority: .low)
                        } else if !isHovered, hoveredDropIndex == index {
                            hoveredDropIndex = nil
                        }
                    }
                }
        }
        .frame(width: 2)
        .frame(height: Constants.main.barIconSize + 24)
        .transaction { $0.animation = nil }
    }
    
    @ViewBuilder
    func cell(@ViewBuilder _ view: () -> some View) -> some View {
        view()
            .frame(height: Constants.main.barIconSize)
            .padding(12)
            .background(palette.secondaryGroupedBackground, in: .rect(cornerRadius: Constants.main.smallItemCornerRadius))
    }
    
    func completeDrag() {
        defer {
            self.pickedUpIndex = nil
            self.hoveredDropIndex = nil
        }
        guard let pickedUpIndex, let hoveredDropIndex else { return }
        let item = items.remove(at: pickedUpIndex)
        let newIndex = hoveredDropIndex > pickedUpIndex ? hoveredDropIndex - 1 : hoveredDropIndex
        items.insert(item, at: newIndex)
    }
}

#Preview {
    NavigationStack {
        InteractionBarEditorView(configuration: PostBarConfiguration.default)
    }
    .environment(Palette.main)
}
