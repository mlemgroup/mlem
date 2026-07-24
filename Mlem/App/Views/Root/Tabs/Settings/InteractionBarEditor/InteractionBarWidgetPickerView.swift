//
//  InteractionBarWidgetPickerView.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-02-12.
//

import ComponentViews
import SwiftUI

struct InteractionBarWidgetPickerView<Configuration: NewInteractionBarConfiguration>: View {
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
                ForEach(Array(Configuration.availableActions.all), id: \.self) { item in
                    widgetButton(.action(item))
                }
            }
            
            Section("Counters") {
                ForEach(Array(CounterType.allCases), id: \.self) { item in
                    widgetButton(.counter(item))
                }
            }
        }
        .toolbar {
            CloseButtonToolbarItem()
        }
        .contentMargins(.top, 0)
    }
    
    @ViewBuilder
    func widgetButton(_ item: InteractionBarItem) -> some View {
        let selected = configuration.pinnedInteractionBarItems.contains(item)
        let (label, icon): (String, String) = switch item {
        case let .action(action):
            (action.label.title, action.label.icon.computeImageName())
        case let .counter(counter):
            (.init(localized: counter.appearance.label), counter.appearance.singleIcon)
        }
        
        Button {
            if selected {
                configuration.pinnedInteractionBarItems.remove(item)
            } else {
                configuration.pinnedInteractionBarItems.insert(item)
            }
        } label: {
            HStack {
                Label {
                    Text(label)
                } icon: {
                    Image(systemName: icon)
                        .foregroundStyle(selected ? .themedAccent : .themedSecondary)
                }
                
                Spacer()
                
                if selected {
                    Image(icon: .general.success)
                        .foregroundStyle(.themedAccent)
                        .contentTransition(.symbolEffect(.replace, options: .speed(2)))
                }
            }
            .frame(maxWidth: .infinity)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }
}
