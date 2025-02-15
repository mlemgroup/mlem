//
//  InteractionBarWidgetPickerView.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-02-12.
//

import SwiftUI

struct InteractionBarWidgetPickerView<Configuration: InteractionBarConfiguration>: View {
    @Environment(Palette.self) var palette
    @Environment(\.dismiss) var dismiss
    
    @Binding var configuration: Configuration
    
    var body: some View {
        Form {
            Section {
                Text("Choose which widgets to display in your palette.")
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            
            Section("Actions") {
                ForEach(Array(Configuration.ActionType.allCases), id: \.self) { item in
                    widgetButton(.action(item))
                }
            }
            
            Section("Counters") {
                ForEach(Array(Configuration.CounterType.allCases), id: \.self) { item in
                    widgetButton(.counter(item))
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                CloseButtonView {
                    dismiss()
                }
            }
        }
    }
    
    @ViewBuilder
    func widgetButton(_ item: Configuration.Item) -> some View {
        let selected = configuration.availableWidgets.contains(item)
        let (label, icon): (String, String) = switch item {
        case let .action(action):
             (action.appearance.label, action.appearance.barIcon)
        case let .counter(counter):
             (.init(localized: counter.appearance.label), counter.appearance.singleIcon)
        }
        
        Button {
            if selected {
                configuration.availableWidgets.remove(item)
            } else {
                configuration.availableWidgets.insert(item)
            }
        } label: {
            HStack {
                Label {
                    Text(label)
                } icon: {
                    Image(systemName: icon)
                        .foregroundStyle(selected ? palette.accent : palette.secondary)
                }
                
                Spacer()
                
                if selected {
                    Image(systemName: Icons.success)
                        .foregroundStyle(palette.accent)
                        .contentTransition(.symbolEffect(.replace, options: .speed(2)))
                }
            }
            .frame(maxWidth: .infinity)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }
}
