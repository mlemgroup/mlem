//
//  InteractionBarEditorView.swift
//  Mlem
//
//  Created by Sjmarf on 15/08/2024.
//

import Flow
import SwiftUI

// swiftlint:disable:next type_body_length
struct InteractionBarEditorView<Configuration: InteractionBarConfiguration>: View {
    @Environment(Palette.self) var palette
    
    enum DropLocation: Equatable {
        case bar(index: Int), tray
    }
    
    @State var configuration: Configuration {
        didSet {
            onSet(configuration)

            let newTrayItems: [TrayItem] = Configuration.Item.allCases.reduce(into: []) { result, item in
                result.append(.init(item: item, selected: configuration.all.contains(item)))
            }
            
            trayItems = newTrayItems
        }
    }
    
    @State var trayItems: [TrayItem] = .init()
    @State var barItems: [BarItem] = .init()
    
    @State var barPickedUpIndex: Int?
    @State var trayPickedUpItem: Configuration.Item?
    @State var dragLocation: CGPoint = .zero
    @State var dragTranslation: CGSize = .zero
    @State var hoveredDropLocation: DropLocation?
    @State var hoveredDropIndexDistance: CGFloat = .infinity
    @State var showingApplyToAllConfirmation: Bool = false
    
    let onSet: (Configuration) -> Void
    
    let dropIndicatorWidth: CGFloat = 2
    let barAnimationDuration: CGFloat = 0.2
    
    @ScaledMetric(relativeTo: .body) var baseInfoCapsuleHeight: CGFloat = 22
    var infoCapsuleHeight: CGFloat { baseInfoCapsuleHeight + Constants.main.doubleSpacing }
    
    init(configuration: Configuration, onSet: @escaping (Configuration) -> Void) {
        self.configuration = configuration
        self.onSet = onSet
        self._trayItems = .init(wrappedValue: Configuration.Item.allCases.reduce(into: []) { result, item in
            result.append(.init(item: item, selected: configuration.all.contains(item)))
        })
        self._barItems = .init(wrappedValue: (configuration.leading + [nil] + configuration.trailing).map { item in
                .init(item: item, active: true, visible: true)
        })
    }
    
    init(setting: WritableKeyPath<InteractionBarTracker, Configuration>) {
        self.init(configuration: InteractionBarTracker.main[keyPath: setting]) {
            var main = InteractionBarTracker.main
            main[keyPath: setting] = $0
        }
    }
    
    var body: some View {
        VStack {
            SettingsHeaderView(
                title: "Interaction Bar",
                description: "Tap and hold items to add, remove, or rearrange them") {
                    Image(systemName: Icons.votesSquare)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 64)
                        .foregroundStyle(palette.accent)
                        .padding([.horizontal, .top], 20)
                }
                .background(palette.background, in: .rect(cornerRadius: Constants.main.largeItemCornerRadius))
            
            infoCapsule
                .padding(.vertical, 15)
            
            postPreview
                .padding(.bottom, Constants.main.doubleSpacing)
                .zIndex(barPickedUpIndex == nil ? -1 : 1)
            
            Divider()
            
            readoutSelectors
                .zIndex(-2)
            
            Divider()
            
            HFlow(horizontalAlignment: .center, verticalAlignment: .center, distributeItemsEvenly: true) {
                ForEach(trayItems, id: \.item) { item in
                    trayItem(item.item, selected: item.selected)
                }
            }
            .zIndex(trayPickedUpItem == nil ? -1 : 1)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(Constants.main.standardSpacing)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(palette.groupedBackground)
        .coordinateSpace(.named("editor"))
    }
    
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
    
    @ViewBuilder
    var postPreview: some View {
        // capsule color gradient configuration
        let gradientBegin: CGFloat = 0.45
        let gradientEnd: CGFloat = 0.35
        
        VStack(alignment: .leading, spacing: Constants.main.standardSpacing) {
            Capsule()
                .fill(LinearGradient(
                    colors: [palette.secondary.opacity(gradientBegin), palette.secondary.opacity(gradientEnd)],
                    startPoint: .leading,
                    endPoint: .trailing
                ))
                .frame(width: 200, height: 13)
            
            HStack(alignment: .top, spacing: 8) {
                RoundedRectangle(cornerRadius: Constants.main.smallItemCornerRadius)
                    .fill(palette.accent.opacity(0.4))
                    .frame(width: Constants.main.thumbnailSize, height: Constants.main.thumbnailSize)
                    .overlay {
                        Image(systemName: "mountain.2.fill")
                            .font(.system(size: 23))
                            .foregroundStyle(.white)
                            .opacity(0.9)
                    }
                
                VStack(alignment: .leading, spacing: 5) {
                    Capsule()
                        .fill(LinearGradient(
                            colors: [palette.secondary.opacity(gradientBegin), palette.secondary.opacity(gradientEnd)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(maxWidth: .infinity)
                        .frame(height: 15)
                    
                    Capsule()
                        .fill(LinearGradient(
                            colors: [palette.secondary.opacity(gradientBegin), palette.secondary.opacity(gradientEnd)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(maxWidth: 200)
                        .frame(height: 15)
                }
            }
            
            Capsule()
                .fill(LinearGradient(
                    colors: [palette.secondary.opacity(gradientBegin), palette.secondary.opacity(gradientEnd)],
                    startPoint: .leading,
                    endPoint: .trailing
                ))
                .frame(width: 200, height: 13)
            
            interactionBar
                .frame(height: Constants.main.barIconSize)
                .padding(.horizontal, 2) // TODO: NOW wtf?
                .padding(.vertical, Constants.main.barIconPadding)
        }
        .padding(Constants.main.standardSpacing)
        .background(palette.background, in: .rect(cornerRadius: Constants.main.mediumItemCornerRadius))
    }
    
    @ViewBuilder
    var interactionBar: some View {
        HStack(spacing: 0) {
            ForEach(Array(barItems.enumerated()), id: \.offset) { index, item in
                dropIndicator(index: index)
                barItem(item, index: index)
            }
            
            dropIndicator(index: items.count)
        }
        .padding(.horizontal, -Constants.main.standardSpacing)
    }
    
    @ViewBuilder
    func barItem(_ item: BarItem, index: Int) -> some View {
        itemLabel(item.item)
            .frame(maxWidth: item.active ? nil : 0)
            .opacity(item.visible ? 1 : 0)
            .offset(barPickedUpIndex == index ? dragTranslation : .zero)
            .background {
                if barPickedUpIndex == index && dragTranslation != .zero {
                    Capsule()
                        .fill(palette.accent.opacity(0.2))
                        .stroke(palette.accent)
                        .padding(4)
                }
            }
            .gesture(barItemDragGesture(index: index))
            .zIndex(barPickedUpIndex == index ? 1 : 0)
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
    func dropIndicator(index: Int) -> some View {
        GeometryReader { geometry in
            Capsule()
                .fill(hoveredDropLocation == .bar(index: index) ? palette.accent : .clear)
                .frame(width: 2)
                .padding(-2)
                .contentShape(.rect)
                .onChange(of: dragLocation) {
                    let frame = geometry.frame(in: .named("editor"))
                    if let barPickedUpIndex, barPickedUpIndex == index || barPickedUpIndex == index - 1 { return }
                    
                    if dragLocation.y > frame.maxY + 30 {
                        if let barPickedUpIndex, items[barPickedUpIndex] != nil {
                            if hoveredDropLocation != .tray {
                                hoveredDropLocation = .tray
                                HapticManager.main.play(haptic: .gentleInfo, priority: .low)
                            }
                            return
                        } else {
                            hoveredDropLocation = nil
                            return
                        }
                    }
                    if hoveredDropLocation == .tray { hoveredDropLocation = nil }
                    
                    guard allowNewItemInsertion else { return }
                    
                    if barPickedUpIndex != nil || trayPickedUpItem != nil {
                        // 18 = half of width plus wiggle room
                        // if abs(frame.minX - dragLocation.x) < 18 || abs(frame.maxX - dragLocation.x) < 18 {
                            // if dragged item is within 22 (half of socket width) of this socket, update hoveredDropLocation to be this socket
                        if abs(frame.minX - dragLocation.x) < 22 {
                            if hoveredDropLocation == nil {
                                hoveredDropLocation = .bar(index: index)
                                HapticManager.main.play(haptic: .gentleInfo, priority: .low)
                            }
                        } else {
                            // if dragged item is outside of the drop range for this socket, reset hoverDropLocation to nil
                            if hoveredDropLocation == .bar(index: index) {
                                hoveredDropLocation = nil
                            }
                        }
                    }
                }
        }
        .frame(width: 0, height: Constants.main.barIconHitbox)
        .transaction { $0.animation = nil }
    }
    
    @ViewBuilder
    func trayItem(_ item: Configuration.Item, selected: Bool) -> some View {
        itemLabel(item)
            .opacity(selected ? 0 : 1)
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
    
    @ViewBuilder
    var bottomBarActions: some View {
        HStack {
            Button("Apply to All Interaction Bars") { showingApplyToAllConfirmation = true }
                .confirmationDialog(
                    "Really apply configuration to all?",
                    isPresented: $showingApplyToAllConfirmation,
                    titleVisibility: .visible
                ) {
                    Button("Yes") {
                        InteractionBarTracker.main.interactionBarConfigurations = .init(
                            post: configuration.convert(),
                            comment: configuration.convert(),
                            reply: configuration.convert()
                        )
                    }
                }
            Spacer()
            Button("Reset") { configuration = .default }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
    }
}

#Preview {
    NavigationStack {
        InteractionBarEditorView(configuration: PostBarConfiguration.default, onSet: { _ in })
    }
    .environment(Palette.main)
}
