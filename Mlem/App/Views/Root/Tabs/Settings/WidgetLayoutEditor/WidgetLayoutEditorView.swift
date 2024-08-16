//
//  WidgetLayoutEditorView.swift
//  Mlem
//
//  Created by Sjmarf on 15/08/2024.
//

import SwiftUI

struct WidgetLayoutEditorView<Configuration: InteractionBarConfiguration>: View {
    @State var actions: [Configuration.Item?]
    
    init(configuration: Configuration) {
        // Where `nil` represents the info stack
        self._actions = .init(initialValue: configuration.leading + [nil] + configuration.trailing)
    }
    
    var body: some View {
        ScrollView {}
            .navigationBarTitleDisplayMode(.inline)
            .background(Palette.main.groupedBackground)
    }
}
