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
    
    @State var configuration: Configuration {
        didSet { onSet(configuration) }
    }
    
    @State var barPickedUpIndex: Int?
    @State var trayPickedUpItem: Configuration.Item?
    @State var dragLocation: CGPoint = .zero
    @State var dragTranslation: CGSize = .zero
    @State var hoveredDropLocation: DropLocation?
    @State var hoveredDropIndexDistance: CGFloat = .infinity
    @State var showingApplyToAllConfirmation: Bool = false
    
    let onSet: (Configuration) -> Void
    
    let dropIndicatorWidth: CGFloat = 2
    
    init(configuration: Configuration, onSet: @escaping (Configuration) -> Void) {
        self.configuration = configuration
        self.onSet = onSet
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
                .padding(.bottom, Constants.main.doubleSpacing)
            
            postPreview
                .padding(.bottom, Constants.main.doubleSpacing)
            
            Divider()
            
            trayInfoItems
            
            Divider()
            
            HFlow(horizontalAlignment: .center, verticalAlignment: .center, distributeItemsEvenly: true) {
                ForEach(Array(Configuration.Item.allCases.enumerated()), id: \.offset) { trayItem($1) }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(Constants.main.standardSpacing)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(palette.groupedBackground)
        .coordinateSpace(.named("editor"))
    }
    
    @ViewBuilder
    var activeBar: some View {
        HStack(spacing: 0) {
            widgetStack(items: configuration.leading)
            
            readoutStack
            
            widgetStack(items: configuration.trailing, precedingItems: configuration.leading.count)
        }
        .padding(.horizontal, -Constants.main.standardSpacing)
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
    
    @ViewBuilder
    func dropIndicator(index: Int) -> some View {
        GeometryReader { geometry in
            Capsule()
                .fill(hoveredDropLocation == .bar(index: index) ? palette.accent : .clear)
                .frame(width: dropIndicatorWidth)
                .padding(.horizontal, -2)
                .frame(height: Constants.main.barIconSize + 24)
                .contentShape(.rect)
                .onChange(of: dragLocation) {
                    let frame = geometry.frame(in: .named("editor"))
                    if let barPickedUpIndex, barPickedUpIndex == index || barPickedUpIndex == index - 1 { return }
                    
                    if dragLocation.y > frame.maxY + 60 {
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
                        if abs(frame.minX - dragLocation.x) < Constants.main.barIconSize + 12 + 4 {
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
        .frame(width: 0)
        .frame(height: Constants.main.barIconSize + 24)
        .transaction { $0.animation = nil }
    }
    
    @ViewBuilder
    func trayItem(_ item: Configuration.Item) -> some View {
        itemLabel(item)
            // .padding(10)
            .background {
                Capsule().fill(palette.background)
            }
            .opacity(items.contains(item) ? 0 : 1)
            .geometryGroup()
            .offset(trayPickedUpItem == item ? dragTranslation : .zero)
            .background(Capsule().stroke(palette.secondary).fill(trayItemOutlineColor(item)))
            .gesture(trayItemDragGesture(item: item))
            .zIndex(trayPickedUpItem == item ? 1 : 0)
    }
    
    @ViewBuilder
    var trayInfoItems: some View {
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
    func itemLabel(_ item: Configuration.Item) -> some View {
        Group {
            switch item {
            case let .action(action):
                InteractionBarActionLabelView(action.appearance)
            case let .counter(counter):
                InteractionBarCounterLabelView(counter.appearance)
                    .fixedSize()
            }
        }
        .padding(Constants.main.standardSpacing)
        .geometryGroup()
    }
    
    @ViewBuilder
    func widgetStack(items: [Configuration.Item], precedingItems: Int = 0) -> some View {
        ForEach(Array(items.enumerated()), id: \.offset) { index, item in
            let adjustedIndex = index + precedingItems
            let selected = barPickedUpIndex == adjustedIndex
            HStack(spacing: 0) {
                itemLabel(item)
                    // .padding(Constants.main.standardSpacing)
                    .background {
                        Capsule().fill(palette.background)
                    }
                    .zIndex(selected ? 1 : 0)
                    .offset(selected ? dragTranslation : .zero)
                    .background {
                        if selected && dragTranslation != .zero {
                            Capsule()
                                .fill(palette.accent.opacity(0.2))
                                .stroke(palette.accent)
                        }
                    }
                    .gesture(barItemDragGesture(index: adjustedIndex))
                
                dropIndicator(index: adjustedIndex)
            }
        }
    }
    
    @ViewBuilder
    var readoutStack: some View {
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
            
            activeBar
                .frame(height: Constants.main.barIconSize)
                .padding(.horizontal, 2) // TODO: NOW wtf?
                .padding(.vertical, Constants.main.barIconPadding)
                .zIndex(barPickedUpIndex == nil ? 0 : 1)
        }
        .padding(Constants.main.standardSpacing)
        .background(palette.background, in: .rect(cornerRadius: Constants.main.mediumItemCornerRadius))
    }
}

#Preview {
    NavigationStack {
        InteractionBarEditorView(configuration: PostBarConfiguration.default, onSet: { _ in })
    }
    .environment(Palette.main)
}
