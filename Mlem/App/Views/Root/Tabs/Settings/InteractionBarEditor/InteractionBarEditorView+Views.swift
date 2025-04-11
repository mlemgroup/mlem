//
//  InteractionBarEditorView+Views.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-01-27.
//

import ComponentViews
import Flow
import SwiftUI
import Theming

extension InteractionBarEditorView {
    // MARK: - Previews
    
    @ViewBuilder
    var contentPreview: some View {
        VStack(alignment: .leading, spacing: Constants.main.standardSpacing) {
            Group {
                switch configurationType {
                case .post: postPreviewBody
                case .comment: commentPreviewBody
                }
            }
            .opacity(0.75)
            
            interactionBar
                .frame(height: Constants.main.barIconSize)
                .padding(.horizontal, 2)
                .padding(.vertical, Constants.main.barIconPadding)
        }
        .padding(Constants.main.standardSpacing)
        .background(.themedSecondaryGroupedBackground, in: .rect(cornerRadius: Constants.main.mediumItemCornerRadius))
        .paletteBorder(cornerRadius: Constants.main.mediumItemCornerRadius)
    }
    
    @ViewBuilder
    var postPreviewBody: some View {
        HStack(alignment: .top, spacing: 8) {
            RoundedRectangle(cornerRadius: Constants.main.smallItemCornerRadius)
                .fill(.themedAccent.opacity(0.6))
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
    }
    
    @ViewBuilder
    var commentPreviewBody: some View {
        HStack(spacing: 7) {
            Image(systemName: Icons.personCircleFill)
                .resizable()
                .scaledToFit()
                .symbolRenderingMode(.palette)
                .foregroundStyle(palette.contrastingLabel, palette.neutralAccent.gradient)
                .frame(width: Constants.main.smallAvatarSize, height: Constants.main.smallAvatarSize)
                .compositingGroup()
                .opacity(0.5)
            
            MockTextView(beginOpacity: 0.4, endOpacity: 0.3)
                .frame(maxWidth: 200)
                .frame(height: 13)
        }
        
        VStack(alignment: .leading, spacing: 5) {
            MockTextView()
                .frame(maxWidth: .infinity)
                .frame(height: 15)
            MockTextView()
                .frame(maxWidth: 250)
                .frame(height: 15)
        }
    }
    
    @ViewBuilder
    var interactionBar: some View {
        HStack(spacing: 0) {
            ForEach(Array(barItems.enumerated()), id: \.element.uuid) { index, item in
                if dropLocation?.index == index,
                   barPickedUpIndex != index,
                   barPickedUpIndex != index - 1 {
                    dropIndicator(index: index)
                }
                
                barItem(item, index: index)
            }
            
            if dropLocation?.index == barItems.count,
               barPickedUpIndex != barItems.count - 1 {
                dropIndicator(index: barItems.count)
            }
        }
        .padding(.horizontal, -Constants.main.standardSpacing)
    }
    
    @ViewBuilder
    func barItem(_ barItem: BarItem, index: Int) -> some View {
        itemLabel(barItem.item)
            .offset(barPickedUpIndex == index ? dragTranslation : .zero)
            .background {
                if barPickedUpIndex == index, dragTranslation != .zero {
                    Capsule()
                        .fill(.themedAccent.opacity(0.2))
                        .stroke(.themedAccent)
                        .padding(4)
                }
            }
            .overlay {
                GeometryReader { geometry in
                    Color.clear
                        .contentShape(.rect)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .onChange(of: dragLocation) {
                            guard allowNewItemInsertion, isDraggingItem else { return }
                            
                            let frame = geometry.frame(in: .named("editor"))
                            
                            // if outside of bar zone, reset newHoveredDropLocation
                            guard dragLocation.y <= frame.maxY + 30 else {
                                dropLocation = .tray
                                return
                            }
                            
                            // check if within this item's hitbox
                            if dragLocation.x > frame.minX,
                               dragLocation.x < frame.maxX {
                                // determine whether hovered over the left or the right side, update hoveredDropIndex accordingly
                                dropLocation = .bar(dragLocation.x < frame.midX ? index : index + 1)
                            }
                        }
                }
            }
            .gesture(barItemDragGesture(item: barItem, index: index))
            .onAppear {
                withAnimation(.easeOut(duration: barAnimationDuration)) {
                    barItem.ancestor?.collapse()
                    barItem.expand()
                }
            }
            .frame(maxWidth: barItem.maxWidth)
            .opacity(barItem.opacity)
            .zIndex(barPickedUpIndex == index ? 2 : 0)
    }
    
    // MARK: - Palette
    
    @ViewBuilder
    var tray: some View {
        HFlow(horizontalAlignment: .center, verticalAlignment: .center, distributeItemsEvenly: true) {
            ForEach(trayItems, id: \.item) { trayItem($0) }
        }
    }
    
    @ViewBuilder
    func trayItem(_ trayItem: TrayItem) -> some View {
        itemLabel(trayItem.item)
            .opacity(trayItem.opacity)
            .geometryGroup()
            .offset(trayPickedUpItem == trayItem ? dragTranslation : .zero)
            .background {
                Group {
                    switch trayItem.item {
                    case let .action(action):
                        InteractionBarActionLabelView(action.appearance)
                    case let .counter(counter):
                        InteractionBarCounterLabelView(counter.appearance)
                            .fixedSize()
                    }
                }
                .opacity(0.2)
                .padding(Constants.main.standardSpacing)
                .background {
                    Capsule()
                        .fill(trayItemOutlineColor(trayItem).opacity(0.2))
                        .stroke(trayItemOutlineColor(trayItem))
                        .background(.themedSecondaryGroupedBackground, in: .capsule)
                }
            }
            .gesture(trayItemDragGesture(trayItem: trayItem))
            .zIndex(trayPickedUpItem == trayItem ? 2 : 0)
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
                    let color: ThemedColor = disabled ? .themedPrimary : .themedAccent
                    HStack(spacing: 2) {
                        Image(systemName: readout.appearance.icon)
                        if readout.appearance.label != "" {
                            Text(readout.appearance.label)
                        }
                    }
                    .font(.footnote)
                    .foregroundStyle(isActive ? .themedContrastingLabel : color)
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
    var header: some View {
        SettingsHeaderView(
            title: "Interaction Bar",
            description: "Tap and hold items to add, remove, or rearrange them."
        ) {}
            .background(.themedSecondaryGroupedBackground, in: .rect(cornerRadius: Constants.main.largeItemCornerRadius))
    }
    
    @ViewBuilder
    var infoCapsule: some View {
        if !allowNewItemInsertion {
            Text("Too many items")
                .padding(7.5)
                .padding(.horizontal, 5)
                .foregroundStyle(.themedNegative)
                .background {
                    Capsule()
                        .fill(.themedNegative.opacity(0.2))
                        .stroke(.themedNegative)
                        .background(.themedSecondaryGroupedBackground, in: .capsule)
                }
                .frame(height: infoCapsuleHeight)
        } else if let trayPickedUpItem {
            Group {
                switch trayPickedUpItem.item {
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
            .padding(7.5)
            .padding(.horizontal, 5)
            .background {
                Capsule()
                    .fill(.themedSecondaryGroupedBackground)
                    .stroke(.themedTertiary)
            }
            .frame(height: infoCapsuleHeight)
        } else {
            Color.clear.frame(height: infoCapsuleHeight)
        }
    }
    
    @ViewBuilder
    var buttons: some View {
        HStack {
            Button("Reset") {
                assert(!(isReport && Configuration.reportDefault == nil), "isReport is true but no reportDefault found")
                let defaultConfiguration: Configuration = isReport ? .reportDefault ?? .default : .default
                var newConfiguration = configuration
                newConfiguration.leading = defaultConfiguration.leading
                newConfiguration.trailing = defaultConfiguration.trailing
                newConfiguration.readouts = defaultConfiguration.readouts
                self.configuration = newConfiguration
                infoStackAlignment = computeInfoStackAlignment(
                    infoStackIndex: configuration.leading.count,
                    totalItems: configuration.all.count
                )
                barItems = (configuration.leading + [nil] + configuration.trailing).map { item in
                    .init(item: item, expanded: true, visible: true)
                }
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)

            Spacer()
            
            Button("Apply to All") { showingApplyToAllConfirmation = true }
                .confirmationDialog(
                    "Really apply this configuration to all interaction bars?",
                    isPresented: $showingApplyToAllConfirmation,
                    titleVisibility: .visible
                ) {
                    Button("Yes") {
                        postInteractionBar = postInteractionBar.applying(other: configuration, types: [.bar])
                        commentInteractionBar = commentInteractionBar.applying(other: configuration, types: [.bar])
                        replyInteractionBar = replyInteractionBar.applying(other: configuration, types: [.bar])
                        // reports intentionally omitted
                    }
                }
        }
        .padding(.horizontal)
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
                .fill(.themedSecondaryGroupedBackground.opacity(0.85))
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
        .foregroundStyle(.themedSecondary)
        .frame(maxWidth: .infinity, alignment: infoStackAlignment)
    }
    
    @ViewBuilder
    func dropIndicator(index: Int) -> some View {
        Capsule()
            .fill(.themedAccent)
            .frame(width: 2, height: 40)
            .padding(-2)
            .frame(width: 0)
            .onAppear {
                HapticManager.main.play(haptic: .gentleInfo, priority: .low)
            }
    }
}
