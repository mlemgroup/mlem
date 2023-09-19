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
    
    @State private var query: String = ""
    @State private var instances: [InstanceMetadata]?
    
    /// Instances currently accepting new users
    var filteredInstances: ArraySlice<InstanceMetadata>? {
        instances?
            .filter { query.isEmpty || $0.name.lowercased().hasPrefix(query.lowercased()) }
            .prefix(30) // limit to a maximum of 30
    }
    
    let onboarding: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: .zero) {
                if onboarding {
                    Text(pickInstance)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search", text: $query, prompt: Text("Looking for a specific instance?"))
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .textFieldStyle(.roundedBorder)
                }
                .padding(.horizontal)
                .padding(.bottom, 16)
                
                if let filteredInstances {
                    if filteredInstances.isEmpty {
                        VStack(spacing: 16) {
                            Spacer()
                            Text("There are no results for \(query)")
                            Button {
                                query = ""
                            } label: {
                                Text("Clear")
                            }
                            Spacer()
                        }
                    } else {
                        ForEach(filteredInstances) { instance in
                            VStack(spacing: .zero) {
                                Divider()
                                
                                InstanceSummary(
                                    instance: instance,
                                    onboarding: true,
                                    selectedInstance: $selectedInstance
                                )
                                .padding(.horizontal)
                            }
                        }
                    }
                } else {
                    LoadingView(whatIsLoading: .instances)
                }
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .navigationTitle("Instances")
        .task {
            instances = await loadInstances()
                // remote source is already sorted by user count but that may change...
                .sorted(by: { $0.users > $1.users })
                // restrict the list to instances who are currently ccepting new users
                // also filter on the presence of `nsfw` in the version string
                .filter { $0.newUsers && !$0.version.contains("nsfw") }
        }
    }
}
