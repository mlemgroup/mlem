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
    
    /**
     Instances currently accepting new users
     */
    var filteredInstances: [InstanceMetadata]? {
        instances?
            .filter { instance in
                instance.newUsers
            }
    }
    
    let onboarding: Bool
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                Text("Instances")
                    .bold()
                    .padding()
                
                if onboarding {
                    Text(pickInstance)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                
                if fetchFailed {
                    Text("Fetching failed")
                } else if let filteredInstances {
                    ForEach(filteredInstances) { instance in
                        VStack(spacing: 0) {
                            Divider()
                            
                            InstanceSummary(instance: instance,
                                            onboarding: true,
                                            selectedInstance: $selectedInstance)
                            .padding(.horizontal)
                        }
                    }
                } else {
                    LoadingView(whatIsLoading: .instances)
                }
            }
        }
        .task { await loadInstances() }
    }
}
