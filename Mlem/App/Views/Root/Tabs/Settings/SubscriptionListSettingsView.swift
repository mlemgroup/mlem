//
//  SubscriptionListSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 23/06/2024.
//

import SwiftUI

struct SubscriptionListSettingsView: View {
    @Setting(\.subscriptionInstanceLocation) var instanceLocation
    
    var body: some View {
        PaletteForm {
            Picker("Label Style", selection: $instanceLocation) {
                ForEach(InstanceLocation.allCases, id: \.self) { item in
                    Text(item.label)
                }
            }
        }
        .navigationTitle("Subscription List")
    }
}
