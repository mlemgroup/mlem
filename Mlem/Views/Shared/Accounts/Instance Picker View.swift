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
    
    var body: some View {
        ScrollView {
            LazyVStack {
                Text("Instances")
                    .bold()
                    .padding(.bottom)
                
                if fetchFailed {
                    Text("Fetching failed")
                } else if let instances {
                    ForEach(instances) { instance in
                        VStack(spacing: 0) {
                            InstanceSummary(instance: instance)
                            
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
