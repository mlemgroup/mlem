//
//  Instance Picker View.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-08-16.
//

import Dependencies
import Foundation
import SwiftUI

struct InstancePickerView: View {
    @Dependency(\.persistenceRepository) var persistenceRepository
    @Dependency(\.errorHandler) var errorHandler
    
    @Binding var selectedInstance: InstanceMetadata?
    
    @State var instances: [InstanceMetadata]?
    
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
                
                if let filteredInstances {
                    ForEach(filteredInstances) { instance in
                        VStack(spacing: 0) {
                            Divider()
                            
                            InstanceSummary(
                                instance: instance,
                                onboarding: true,
                                selectedInstance: $selectedInstance
                            )
                            .padding(.horizontal)
                        }
                    }
                } else {
                    LoadingView(whatIsLoading: .instances)
                }
            }
        }
        .task {
            instances = await loadInstances()
        }
    }
}
