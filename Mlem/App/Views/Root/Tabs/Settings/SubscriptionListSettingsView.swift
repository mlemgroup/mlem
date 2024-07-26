//
//  SubscriptionListSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 23/06/2024.
//

import SwiftUI

struct SubscriptionListSettingsView: View {
    @AppStorage("subscriptions.instanceLocation")
    private var instanceLocation: InstanceLocation = UIDevice.isPad ? .bottom : .trailing
    
    var body: some View {
        Form {
            Picker("Label Style", selection: $instanceLocation) {
                ForEach(InstanceLocation.allCases, id: \.self) { item in
                    Text(item.label)
                }
            }
        }
    }
}
