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
    @Environment(NavigationLayer.self) var navigation
    
    @State var configuration: Configuration {
        didSet {
            onSet(configuration)
        }
    }
    
    @State var trayItems: [TrayItem] = .init()
    @State var barItems: [BarItem] = .init()
    
    @State var barPickedUpItem: (barItem: BarItem, index: Int)?
    @State var trayPickedUpItem: TrayItem?
    
    /// Current entity the dragged item is hovered over. -1 indicates the tray.
    @State var dropLocation: DropLocation?
    @State var dragLocation: CGPoint = .zero
    @State var dragTranslation: CGSize = .zero
    
    @State var showingApplyToAllConfirmation: Bool = false
    
    let onSet: (Configuration) -> Void
    
    let barAnimationDuration: CGFloat = 0.15
    
    @ScaledMetric(relativeTo: .body) var baseInfoCapsuleHeight: CGFloat = 22
    var infoCapsuleHeight: CGFloat { baseInfoCapsuleHeight + Constants.main.doubleSpacing }
    
    let configurationType: ConfigurationType
    
    init(configuration: Configuration, onSet: @escaping (Configuration) -> Void) {
        self.configuration = configuration
        self.onSet = onSet
        let configurationItems: [Configuration.Item?] = configuration.leading + [nil] + configuration.trailing
        self._barItems = .init(wrappedValue: configurationItems.map { item in
            .init(item: item, expanded: true, visible: true)
        })
        if configuration is PostBarConfiguration {
            configurationType = .post
        } else {
            configurationType = .comment
        }
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
            buttons
            Spacer()
            infoCapsule
            contentPreview.zIndex(barPickedUpItem == nil ? 0 : 1)
            Divider()
            readoutSelectors
            Divider()
            tray.zIndex(trayPickedUpItem == nil ? 0 : 1)
            
            Button("More Widgets...") {
                navigation.openSheet(.settings(configuration.widgetPickerPage($configuration)))
            }
        }
        .onChange(of: configuration.availableWidgets, initial: true) {
            onSet(configuration)
            let configurationItems: [Configuration.Item?] = configuration.leading + [nil] + configuration.trailing
            trayItems = Configuration.Item.allCases
                .filter { configuration.availableWidgets.contains($0) }
                .map { TrayItem(item: $0, visible: !configurationItems.contains($0)) }
        }
        .frame(maxWidth: .infinity)
        .padding(Constants.main.standardSpacing)
        .padding(.bottom, Constants.main.standardSpacing)
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
