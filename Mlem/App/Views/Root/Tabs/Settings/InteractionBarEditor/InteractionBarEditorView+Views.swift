//
//  InteractionBarEditorView+Views.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-01-27.
//

import SwiftUI
import Flow

extension InteractionBarEditorView {
    
    // MARK: - Post Preview
    
    @ViewBuilder
    var postPreview: some View {
        VStack(alignment: .leading, spacing: Constants.main.standardSpacing) {
            Group {
                MockTextView()
                    .frame(width: 200, height: 13)
                
                HStack(alignment: .top, spacing: 8) {
                    RoundedRectangle(cornerRadius: Constants.main.smallItemCornerRadius)
                        .fill(palette.accent.opacity(0.6))
                        .frame(width: Constants.main.thumbnailSize, height: Constants.main.thumbnailSize)
                        .overlay {
                            Image(systemName: "mountain.2.fill")
                                .font(.system(size: 23))
                                .foregroundStyle(.white)
                        }
                    
                    VStack(alignment: .leading, spacing: 5) {
                        MockTextView()
                            .frame(maxWidth: .infinity)
                            .frame(height: 15)
                        MockTextView()
                            .frame(maxWidth: 200)
                            .frame(height: 15)
                    }
                }
                
                MockTextView()
                    .frame(width: 200, height: 13)
            }
            .opacity(0.75)
            
            interactionBar
                .frame(height: Constants.main.barIconSize)
                .padding(.horizontal, 2)
                .padding(.vertical, Constants.main.barIconPadding)
        }
        .padding(Constants.main.standardSpacing)
        .background(palette.background, in: .rect(cornerRadius: Constants.main.mediumItemCornerRadius))
    }
    
    @ViewBuilder
    var interactionBar: some View {
        HStack(spacing: 0) {
            ForEach(barItems, id: \.uuid) { item in
                barItem(item)
            }
        }
        .padding(.horizontal, -Constants.main.standardSpacing)
    }
    
    @ViewBuilder
    func barItem(_ barItem: BarItem) -> some View {
        HStack(spacing: 0) {
            dropIndicator(barItem: barItem, side: .left)
            indicatorMask(barItem: barItem)
            
            itemLabel(barItem.item)
                .offset(barPickedUpItem == barItem ? dragTranslation : .zero)
                .background {
                    if barPickedUpItem == barItem && dragTranslation != .zero {
                        Capsule()
                            .fill(palette.accent.opacity(0.2))
                            .stroke(palette.accent)
                            .padding(4)
                    }
                }
                .overlay {
                    GeometryReader { geometry in
                        Color.clear
                            .contentShape(.rect)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .onChange(of: dragLocation) {
                                guard allowNewItemInsertion else { return }
                                
                                let frame = geometry.frame(in: .named("editor"))
                                
                                // if outside of bar zone, reset newHoveredDropLocation
                                guard dragLocation.y <= frame.maxY + 30 else {
                                    hoveredDropLocation = .tray
                                    return
                                }
                                
                                // check if within this item's hitbox
                                if dragLocation.x > frame.minX,
                                   dragLocation.x < frame.maxX {
                                    // pick left/right side and update hoveredDropLocation, item.hover appropriately
                                    hoveredDropLocation = .bar(dragLocation.x < frame.midX ? .left : .right, of: barItem)
                                }
                            }
                    }
                }
                .gesture(barItemDragGesture(item: barItem))
                .onAppear {
                    withAnimation(.easeInOut(duration: barAnimationDuration)) {
                        barItem.ancestor?.active = false
                        barItem.active = true
                    }
                }
                .frame(maxWidth: barItem.active ? nil : 0)
                .opacity(barItem.visible ? 1 : 0)
                .zIndex(barPickedUpItem == barItem ? 4 : 0)
            
            indicatorMask(barItem: barItem)
            dropIndicator(barItem: barItem, side: .right)
        }
        .zIndex(barPickedUpItem === barItem ? 4 : 0)
    }
    
    // MARK: - Palette
    
    @ViewBuilder
    func trayItem(_ item: Configuration.Item, selected: Bool) -> some View {
        itemLabel(item)
            .opacity(barItems.contains(where: { $0.item == item }) ? 0 : 1)
            .geometryGroup()
            .offset(trayPickedUpItem == item ? dragTranslation : .zero)
            .background {
                Capsule()
                    .fill(trayItemOutlineColor(item).opacity(0.2))
                    .stroke(trayItemOutlineColor(item))
                    .background(palette.background, in: .capsule)
            }
            .gesture(trayItemDragGesture(item: item))
            .zIndex(trayPickedUpItem == item ? 1 : 0)
    }
    
    @ViewBuilder
    var readoutSelectors: some View {
        HFlow(spacing: Constants.main.standardSpacing) {
            ForEach(Array(Configuration.ReadoutType.allCases.enumerated()), id: \.offset) { _, readout in
                let isActive = configuration.readouts.contains(readout)
                let disabled = !readout.compatibleWith(otherReadouts: Set(configuration.readouts))
                Button {
                    if isActive {
                        if let index = configuration.readouts.firstIndex(of: readout) {
                            configuration.readouts.remove(at: index)
                        }
                    } else {
                        // Insert and sort the new `ReadoutType`. In future these could be re-arrangable too
                        // but I need to think about how the UI would work
                        configuration.readouts = Configuration.ReadoutType.allCases.filter {
                            configuration.readouts.contains($0) || $0 == readout
                        }
                    }
                    HapticManager.main.play(haptic: .gentleInfo, priority: .low)
                } label: {
                    let color = disabled ? palette.primary : palette.accent
                    HStack(spacing: 2) {
                        Image(systemName: readout.appearance.icon)
                        Text(readout.appearance.label)
                    }
                    .font(.footnote)
                    .foregroundStyle(isActive ? palette.selectedInteractionBarItem : color)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background {
                        Capsule().fill(isActive ? color : color.opacity(0.2)).stroke(color)
                    }
                    .transaction { $0.animation = nil }
                }
                .buttonStyle(.plain)
                .disabled(disabled)
            }
        }
    }
    
    // MARK: - General Page Views
    
    @ViewBuilder
    var infoCapsule: some View {
        if !allowNewItemInsertion {
            Text("Too many items")
                .padding(Constants.main.standardSpacing)
                .padding(.horizontal, Constants.main.halfSpacing)
                .foregroundStyle(palette.negative)
                .background {
                    Capsule()
                        .fill(palette.negative.opacity(0.2))
                        .stroke(palette.negative)
                        .background(palette.background, in: .capsule)
                }
                .frame(height: infoCapsuleHeight)
        } else if let trayPickedUpItem {
            Group {
                switch trayPickedUpItem {
                case let .action(action):
                    HStack {
                        Image(systemName: action.appearance.barIcon)
                        Text(action.appearance.label)
                    }
                case let .counter(counter):
                    HStack {
                        InteractionBarCounterLabelView(counter.appearance)
                            .fixedSize()
                        Text(counter.appearance.label)
                    }
                }
            }
            .padding(Constants.main.standardSpacing)
            .padding(.horizontal, Constants.main.halfSpacing)
            .background {
                Capsule()
                    .fill(palette.background)
                    .stroke(palette.tertiary)
            }
            .frame(height: infoCapsuleHeight)
        } else {
            Color.clear.frame(height: infoCapsuleHeight)
        }
    }
    
    // MARK: - Helpers
    
    @ViewBuilder
    func itemLabel(_ item: Configuration.Item?) -> some View {
        Group {
            switch item {
            case let .action(action):
                InteractionBarActionLabelView(action.appearance)
            case let .counter(counter):
                InteractionBarCounterLabelView(counter.appearance)
                    .fixedSize()
            default:
                infoStack
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(Constants.main.standardSpacing)
        .background {
            Capsule()
                .fill(palette.background.opacity(0.85))
        }
        .geometryGroup()
    }
    
    @ViewBuilder
    var infoStack: some View {
        HStack(spacing: 12) {
            ForEach(configuration.readouts, id: \.hashValue) { readout in
                HStack(spacing: 2) {
                    Image(systemName: readout.appearance.icon)
                    Text(readout.appearance.label)
                }
                .font(.footnote)
            }
        }
        .foregroundStyle(palette.secondary)
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    func dropIndicator(barItem: BarItem, side: Side) -> some View {
        if case let .bar(hoverSide, of: hoveredItem) = hoveredDropLocation,
           hoverSide == side,
           hoveredItem == barItem,
           barPickedUpItem != barItem,
           isDraggingItem {
            Capsule()
                .fill(palette.accent)
                .frame(width: 2, height: 40)
                .padding(-2)
                .frame(width: 0)
                .zIndex(2)
        }
    }
    
    /// Masks the drop indicators to either side of the given barItem
    /// This isn't as beautiful as simply disabling the indicators but it works with no indexing logic
    @ViewBuilder
    func indicatorMask(barItem: BarItem) -> some View {
        if barPickedUpItem == barItem {
            Rectangle()
                .fill(palette.background)
                .frame(width: 2, height: 40)
                .padding(-2)
                .frame(width: 0)
                .zIndex(3)
        }
    }
}
