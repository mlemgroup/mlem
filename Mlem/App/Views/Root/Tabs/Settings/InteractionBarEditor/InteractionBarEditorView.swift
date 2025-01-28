//
//  InteractionBarEditorView.swift
//  Mlem
//
//  Created by Sjmarf on 15/08/2024.
//

import Flow
import SwiftUI

// NOTE: zIndex
// This view relies on the careful arrangement of z-indexes:
// 0: inactive components
// 1: active block (e.g., interaction bar or tray)
// 2: drop indicators
// 3: drop indicator masks
// 4: currently dragged item

struct InteractionBarEditorView<Configuration: InteractionBarConfiguration>: View {
    @Environment(Palette.self) var palette
    
    @State var configuration: Configuration {
        didSet {
            onSet(configuration)
        }
    }
    
    @State var trayItems: [Configuration.Item] = Configuration.Item.allCases
    @State var barItems: [BarItem] = .init()
    
    @State var barPickedUpItem: BarItem?
    @State var trayPickedUpItem: Configuration.Item?
    
    @State var hoveredDropLocation: DropLocation? {
        didSet {
            guard case let .bar(side, barItem) = hoveredDropLocation,
                  barItem != barPickedUpItem else { return }
            
            switch oldValue {
            case .tray:
                // moving from tray to bar
                HapticManager.main.play(haptic: .gentleInfo, priority: .low)
            case let .bar(oldSide, oldBarItem):
                // moving from left side to right side on the same bar item--this prevents double taps
                // when moving from one bar item to another
                if oldSide != side && oldBarItem == barItem {
                    HapticManager.main.play(haptic: .gentleInfo, priority: .low)
                }
            default:
                return
            }
        }
    }
    @State var dragLocation: CGPoint = .zero
    @State var dragTranslation: CGSize = .zero
    
    @State var showingApplyToAllConfirmation: Bool = false
    
    let onSet: (Configuration) -> Void
    
    let barAnimationDuration: CGFloat = 0.1
    
    @ScaledMetric(relativeTo: .body) var baseInfoCapsuleHeight: CGFloat = 22
    var infoCapsuleHeight: CGFloat { baseInfoCapsuleHeight + Constants.main.doubleSpacing }
    
    init(configuration: Configuration, onSet: @escaping (Configuration) -> Void) {
        self.configuration = configuration
        self.onSet = onSet
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
        VStack(spacing: Constants.main.standardSpacing) {
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
            
            bottomBarActions
            
            infoCapsule
            
            postPreview
                .zIndex(barPickedUpItem == nil ? 0 : 1)
            
            Divider()
            
            readoutSelectors
            
            Divider()
            
            HFlow(horizontalAlignment: .center, verticalAlignment: .center, distributeItemsEvenly: true) {
                ForEach(trayItems, id: \.self) { trayItem($0) }
            }
            .zIndex(trayPickedUpItem == nil ? 0 : 1)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(Constants.main.standardSpacing)
        .background(palette.groupedBackground)
        .coordinateSpace(.named("editor"))
    }
}

#Preview {
    NavigationStack {
        InteractionBarEditorView(configuration: PostBarConfiguration.default, onSet: { _ in })
    }
    .environment(Palette.main)
}
