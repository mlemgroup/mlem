//
//  InteractionBarWidgetPickerView.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-02-12.
//

import ComponentViews
import SwiftUI

struct InteractionBarWidgetPickerView<Configuration: InteractionBarConfiguration>: View {
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
        
        Button {
            if selected {
                configuration.pinnedInteractionBarItems.remove(item)
            } else {
                configuration.pinnedInteractionBarItems.insert(item)
            }
        } label: {
            HStack {
                widgetLabel(item)
                    .labelStyle(WidgetButtonLabelStyle(selected: selected))
                
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

    func widgetLabel(_ item: InteractionBarItem) -> some View {
        switch item {
        case let .action(action):
            let label = action.appearance.label(describing: .stateTransition)
            return Label(label.title, icon: label.icon)
        case let .counter(counter):
            return Label(counter.appearance.label, systemImage: counter.appearance.singleIcon)
        }
    }
}

private struct WidgetButtonLabelStyle: LabelStyle {
    let selected: Bool

    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.icon
                .foregroundStyle(selected ? .themedAccent : .themedSecondary)
            configuration.title
        }
    }
}
