//
//  InstancePickerView.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-08-16.
//

import Foundation
import SwiftUI
import Dependencies

struct InstancePickerView: View {
    
    @Dependency(\.persistenceRepository) var persistenceRepository
    @Dependency(\.errorHandler) var errorHandler
    
    @Binding var selectedInstance: InstanceMetadata?
    
    @State var instances: [InstanceMetadata]?
    @State var fetchFailed: Bool = false
    
    var filteredInstances: [InstanceMetadata]? {
        instances?
            .filter { instance in
                instance.newUsers
            }
    }
    
    let onboarding: Bool
    
    var body: some View {
        ScrollView {
            LazyVStack {
                Text("Instances")
                    .bold()
                    .padding()
                
                if onboarding {
                    // swiftlint:disable line_length
                    Text("Pick an instance to sign up with. Don't overthink it—the whole point of federation is that you'll see the same content on any federated instance, so just pick one you like and jump right in!")
                        .frame(maxWidth: .infinity)
                        .padding()
                    // swiftlint:enable line_length
                }
                
                if fetchFailed {
                    Text("Fetching failed")
                } else if let filteredInstances {
                    ForEach(filteredInstances) { instance in
                        VStack(spacing: 0) {
                            InstanceSummary(instance: instance,
                                            onboarding: true,
                                            selectedInstance: $selectedInstance)
                            
                            Divider()
                        }
                    }
                } else {
                    LoadingView(whatIsLoading: .instances)
                }
            }
        }
        .task {
            loadInstances()
        }
    }
}
