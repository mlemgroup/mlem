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
    
    init(configuration: Configuration) {
        // Where `nil` represents the info stack
        self._items = .init(initialValue: configuration.leading + [nil] + configuration.trailing)
    }
    
    var body: some View {
        ScrollView {
            VStack {
                HStack(spacing: 5) {
                    dropLocation(index: 0)
                    ForEach(Array(items.enumerated()), id: \.element) { index, item in
                        Group {
                            switch item {
                            case let .action(action):
                                actionView(action)
                            default:
                                RoundedRectangle(cornerRadius: Constants.main.smallItemCornerRadius)
                                    .fill(palette.secondaryGroupedBackground)
                                    .frame(height: Constants.main.barIconSize + 24)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .offset(pickedUpIndex == index ? dragTranslation : .zero)
                        .background(
                            pickedUpIndex == index && dragTranslation != .zero ? palette.accent.opacity(0.2) : Color.clear,
                            in: .rect(cornerRadius: Constants.main.smallItemCornerRadius)
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
                                    withAnimation {
                                        pickedUpIndex = nil
                                        dragTranslation = .zero
                                        hoveredDropIndex = nil
                                    }
                                }
                        )
                        dropLocation(index: index + 1)
                    }
                }
                .zIndex(1)
                Divider()
                HFlow(justification: .none) {
                    ForEach(Array(Configuration.ActionType.allCases.enumerated()), id: \.offset) { _, action in
                        actionView(action)
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
    func actionView(_ actionType: Configuration.ActionType) -> some View {
        InteractionBarActionLabelView(actionType.appearance)
            .frame(width: Constants.main.barIconSize, height: Constants.main.barIconSize)
            .padding(12)
            .background(palette.secondaryGroupedBackground, in: .rect(cornerRadius: Constants.main.smallItemCornerRadius))
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
                    if isHovered, hoveredDropIndex == nil {
                        hoveredDropIndex = index
                    } else if !isHovered, hoveredDropIndex == index {
                        hoveredDropIndex = nil
                    }
                }
        }
        .frame(width: 2)
        .frame(height: Constants.main.barIconSize + 24)
    }
}

#Preview {
    NavigationStack {
        InteractionBarEditorView(configuration: PostBarConfiguration.default)
    }
    .environment(Palette.main)
}
