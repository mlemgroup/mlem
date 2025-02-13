//
//  InteractionBarWidgetPickerView.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-02-12.
//

import SwiftUI

struct InteractionBarWidgetPickerView<Configuration: InteractionBarConfiguration>: View {
    @Environment(Palette.self) var palette
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor: Bool
    
    @State var configuration: Configuration {
        didSet {
            onSet(configuration)
        }
    }
    
    let onSet: (Configuration) -> Void
    
    init(configuration: Configuration, onSet: @escaping (Configuration) -> Void) {
        self.configuration = configuration
        self.onSet = onSet
    }
    
    var body: some View {
        Form {
            Section {
                Text("Select which widgets to display in your palette")
            }
            
            Section("Actions") {
                ForEach(Array(Configuration.ActionType.allCases), id: \.self) { item in
                    let selected: Bool = configuration.availableWidgets.contains(.action(item))
                    Button {
                        if selected {
                            configuration.availableWidgets.remove(.action(item))
                        } else {
                            configuration.availableWidgets.insert(.action(item))
                        }
                    } label: {
                        HStack {
                            Label {
                                Text(item.appearance.label)
                            } icon: {
                                Image(systemName: item.appearance.barIcon)
                                    .foregroundStyle(selected ? palette.accent : palette.secondary)
                            }
                            
                            Spacer()
                            
                            if differentiateWithoutColor, selected {
                                Image(systemName: Icons.success)
                                    .foregroundStyle(palette.accent)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            
            Section("Counters") {
                ForEach(Array(Configuration.CounterType.allCases), id: \.self) { item in
                    Label(String(localized: item.appearance.label), systemImage: item.appearance.leading?.barIcon ?? "globe")
                }
            }
        }
    }
    
    init(setting: WritableKeyPath<InteractionBarTracker, Configuration>) {
        self.init(configuration: InteractionBarTracker.main[keyPath: setting]) {
            var main = InteractionBarTracker.main
            main[keyPath: setting] = $0
        }
    }
}
