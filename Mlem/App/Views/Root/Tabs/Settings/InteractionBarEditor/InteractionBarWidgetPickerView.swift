//
//  InteractionBarWidgetPickerView.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-02-12.
//

import SwiftUI

struct InteractionBarWidgetPickerView<Configuration: InteractionBarConfiguration>: View {
    
    @State var configuration: Configuration
    
    init(configuration: Configuration) {
        self.configuration = configuration
    }
    
    var body: some View {
        Form {
            Section("Actions") {
                ForEach(Array(Configuration.ActionType.allCases), id: \.self) { item in
                    Label(item.appearance.label, systemImage: item.appearance.barIcon)
                }
            }
            
            Section("Counters") {
                ForEach(Array(Configuration.CounterType.allCases), id: \.self) { item in
                    Label(String(localized: item.appearance.label), systemImage: item.appearance.leading?.barIcon ?? "globe")
                }
            }
            
//            ForEach(Configuration.Item.allCases, id: \.self) { item in
//                Button {
//                    switch item {
//                    case let .action(action):
//                        print(action.appearance.label)
//                    case let .counter(counter):
//                        print(counter.appearance.label)
//                    }
//                    // print(item.description)
//                } label: {
//                    HStack(spacing: Constants.main.standardSpacing) {
//                        switch item {
//                        case let .action(action):
//                            HStack {
//                                Image(systemName: action.appearance.barIcon)
//                            }
//                        case .counter:
//                            Text("counter")
//                        }
//                    }
//                }
//            }
        }
    }
    
    init(setting: WritableKeyPath<InteractionBarTracker, Configuration>) {
        self.init(configuration: InteractionBarTracker.main[keyPath: setting])
    }
}
