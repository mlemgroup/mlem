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
    @State var infoStackFrame: CGRect?
    
    let onSet: (Configuration) -> Void
    
    let dropIndicatorWidth: CGFloat = 2
    
    init(configuration: Configuration, onSet: @escaping (Configuration) -> Void) {
        self.configuration = configuration
        self.onSet = onSet
    }
    
    init(setting: WritableKeyPath<Settings, Configuration>) {
        self.init(configuration: Settings.main[keyPath: setting]) {
            var main = Settings.main
            main[keyPath: setting] = $0
        }
    }
    
    var body: some View {
        VStack {
            activeBar
                .zIndex(barPickedUpIndex == nil ? 0 : 1)
            polygon()
            Divider()
            infoText
            Divider()
            HFlow(spacing: Constants.main.standardSpacing) {
                ForEach(Array(Configuration.Item.allCases.enumerated()), id: \.offset) { trayItem($1) }
            }
            .frame(maxWidth: .infinity)
            .zIndex(trayPickedUpItem == nil ? 0 : 1)
            Spacer()
            bottomBarActions
        }
        .frame(maxWidth: .infinity)
        .padding(Constants.main.standardSpacing)
        .navigationTitle("Interaction Bar")
        .navigationBarTitleDisplayMode(.inline)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(palette.groupedBackground)
        .coordinateSpace(.named("editor"))
    }
    
    @ViewBuilder
    var activeBar: some View {
        HStack(spacing: (Constants.main.standardSpacing - dropIndicatorWidth) / 2) {
            dropIndicator(index: 0)
            ForEach(Array(items.enumerated()), id: \.element) { index, item in
                cell { itemLabel(item) }
                    .offset(barPickedUpIndex == index ? dragTranslation : .zero)
                    .background(
                        RoundedRectangle(cornerRadius: Constants.main.smallItemCornerRadius)
                            .fill(barPickedUpIndex == index && dragTranslation != .zero ? palette.accent.opacity(0.2) : Color.clear)
                            .transaction { $0.animation = nil }
                    )
                    .zIndex(barPickedUpIndex == index ? 1 : 0)
                    .gesture(barItemDragGesture(index: index))
                dropIndicator(index: index + 1)
            }
        }
    }
    
    @ViewBuilder
    var infoText: some View {
        Text(
            allowNewItemInsertion ? "Tap and hold items to add, remove or rearrange them." : "Too many items!"
        )
        .lineLimit(2, reservesSpace: true)
        .font(.callout)
        .multilineTextAlignment(.center)
        .foregroundStyle(allowNewItemInsertion ? palette.secondary : palette.negative)
        .padding()
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
                        Settings.main.interactionBarConfigurations = .init(
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
        .frame(width: dropIndicatorWidth)
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
            .gesture(trayItemDragGesture(item: item))
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
            GeometryReader { geometry in
                Spacer()
                    .onChange(of: geometry.frame(in: .named("editor")), initial: true) { _, newValue in
                        infoStackFrame = newValue
                    }
            }
        }
    }
    
    @ViewBuilder
    func cell(@ViewBuilder _ view: () -> some View) -> some View {
        view()
            .frame(height: Constants.main.barIconSize)
            .padding(12)
            .background(palette.secondaryGroupedBackground, in: .rect(cornerRadius: Constants.main.smallItemCornerRadius))
    }
    
    @ViewBuilder
    func polygon() -> some View {
        if let infoStackFrame {
            Path { path in
                path.move(to: CGPoint(x: infoStackFrame.minX, y: 0))
                path.addLine(to: CGPoint(x: infoStackFrame.maxX, y: 0))
                path.addLine(to: CGPoint(x: infoStackFrame.minX, y: 30))
                path.addLine(to: CGPoint(x: infoStackFrame.maxX, y: 30))
            }
            .fill(.blue)
        }
    }
}

#Preview {
    NavigationStack {
        InteractionBarEditorView(configuration: PostBarConfiguration.default, onSet: { _ in })
    }
    .environment(Palette.main)
}
