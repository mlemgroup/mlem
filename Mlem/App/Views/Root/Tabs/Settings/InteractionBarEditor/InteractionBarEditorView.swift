//
//  InteractionBarEditorView.swift
//  Mlem
//
//  Created by Sjmarf on 15/08/2024.
//

import Flow
import SwiftUI

struct InteractionBarEditorView<Configuration: InteractionBarConfiguration>: View {
    @Environment(NavigationLayer.self) var navigation
    @Environment(\.palette) var palette
    
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
    
    @State var infoStackAlignment: Alignment
    
    @State var showingApplyToAllConfirmation: Bool = false
    
    let onSet: (Configuration) -> Void
    let configurationType: ConfigurationType
    let isReport: Bool
    
    let barAnimationDuration: CGFloat = 0.15
    let trayItemDuration: CGFloat = 0.5
    
    @ScaledMetric(relativeTo: .body) var baseInfoCapsuleHeight: CGFloat = 22
    var infoCapsuleHeight: CGFloat { baseInfoCapsuleHeight + Constants.main.doubleSpacing }
    
    init(configuration: Configuration, isReport: Bool, onSet: @escaping (Configuration) -> Void) {
        self.onSet = onSet
        self.configuration = configuration
        self.isReport = isReport
        let configurationItems: [Configuration.Item?] = configuration.leading + [nil] + configuration.trailing
        self.configurationType = configuration is PostBarConfiguration ? .post : .comment
        
        let newBarItems: [BarItem] = configurationItems.map { .init(item: $0, expanded: true, visible: true) }
        let newInfoStackIndex = newBarItems.firstIndex(where: { $0.item == nil })
        assert(newInfoStackIndex != nil, "could not find infoStack index")
        
        self._barItems = .init(wrappedValue: newBarItems)
        self._infoStackAlignment = .init(wrappedValue: computeInfoStackAlignment(
            infoStackIndex: newInfoStackIndex ?? 0,
            totalItems: newBarItems.count
        )
        )
    }
    
    init(setting: WritableKeyPath<InteractionBarTracker, Configuration>, isReport: Bool) {
        self.init(configuration: InteractionBarTracker.main[keyPath: setting], isReport: isReport) {
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
            trayItems = Configuration.Item.allCases
                .filter { configuration.availableWidgets.contains($0) }
                .map { TrayItem(item: $0, visible: true) }
        }
        .frame(maxWidth: .infinity)
        .padding(Constants.main.standardSpacing)
        .padding(.bottom, Constants.main.standardSpacing)
        .background(.themedGroupedBackground)
        .coordinateSpace(.named("editor"))
    }
}

#if DEBUG
    #Preview(traits: .sampleEnvironment) {
        NavigationStack {
            InteractionBarEditorView(configuration: PostBarConfiguration.default, isReport: false, onSet: { _ in })
        }
    }
#endif
