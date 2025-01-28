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
// 3: currently dragged item

struct InteractionBarEditorView<Configuration: InteractionBarConfiguration>: View {
    @Environment(Palette.self) var palette
    
    @State var configuration: Configuration {
        didSet {
            onSet(configuration)
        }
    }
    
    @State var trayItems: [Configuration.Item] = Configuration.Item.allCases
    @State var barItems: [BarItem] = .init()
    
    @State var barPickedUpItem: (item: BarItem, index: Int)?
    @State var trayPickedUpItem: Configuration.Item?
    
    @State var hoveredDropIndex: Int?
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
                .init(item: item, expanded: true, visible: true)
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
            header
            
            bottomBarActions
            
            infoCapsule
            
            postPreview.zIndex(barPickedUpItem == nil ? 0 : 1)
            
            Divider()
            
            readoutSelectors
            
            Divider()
            
            tray.zIndex(trayPickedUpItem == nil ? 0 : 1)
            
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
