//
//  Add Saved Instance View.swift
//  Mlem
//
//  Created by David Bureš on 05.05.2023.
//

import SwiftUI

struct AddSavedInstanceView: View
{
    @EnvironmentObject var communityTracker: SavedCommunityTracker

    @Binding var isShowingSheet: Bool

    @State private var instanceLink: String = ""
    @State private var community: String = ""
    @State private var wantsToAddSpecificCommunity: Bool = false
    
    @State private var isShowingEndpointDiscoverySpinner: Bool = false
    @State private var hasSuccessfulyConnectedToEndpoint: Bool = false
    @State private var errorOccuredWhileConnectingToEndpoint: Bool = false
    
    @FocusState var isFocused

    var body: some View
    {
        VStack(alignment: .leading, spacing: 15)
        {
            if isShowingEndpointDiscoverySpinner
            {
                if !errorOccuredWhileConnectingToEndpoint
                {
                    if !hasSuccessfulyConnectedToEndpoint
                    {
                        VStack(alignment: .center) {
                            HStack(alignment: .center, spacing: 10) {
                                ProgressView()
                                Text("Connecting to \(instanceLink)")
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.secondary)
                    }
                    else
                    {
                        VStack(alignment: .center) {
                            HStack(alignment: .center, spacing: 10) {
                                Text("Connected to \(instanceLink)")
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.cyan)
                        .foregroundColor(.black)
                    }
                }
                else
                {
                    VStack(alignment: .center) {
                        HStack(alignment: .center, spacing: 10) {
                            Text("Could not connect to \(instanceLink)")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.red)
                    .foregroundColor(.black)
                }
            }
            
            Form
            {
                Section("Homepage")
                {
                    HStack
                    {
                        Text("Homepage")
                        Spacer()
                        TextField("Homepage", text: $instanceLink, prompt: Text("hexbear.net"))
                            .autocorrectionDisabled()
                            .focused($isFocused)
                            .keyboardType(.URL)
                            .textInputAutocapitalization(.never)
                    }
                }

                Section("Community")
                {
                    Toggle(isOn: $wantsToAddSpecificCommunity.animation(.easeIn)) {
                        Text("Add Specific Community")
                    }
                    
                    if wantsToAddSpecificCommunity
                    {
                        HStack
                        {
                            Text("Community")
                            Spacer()
                            TextField("Community", text: $community, prompt: Text("news"))
                                .autocorrectionDisabled()
                        }
                    }
                }
            }
            .disabled(isShowingEndpointDiscoverySpinner)
            .onSubmit
            {
                Task
                {
                    withAnimation {
                        isShowingEndpointDiscoverySpinner = true
                    }
                    
                    do
                    {
                        let instanceURL = try await getCorrectURLtoEndpoint(baseInstanceAddress: instanceLink)
                        print("Found correct endpoint: \(instanceURL)")
                        
                        communityTracker.savedCommunities.append(SavedCommunity(instanceLink: instanceURL, communityName: community))
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1)
                        {
                            withAnimation {
                                hasSuccessfulyConnectedToEndpoint = true
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2)
                            {
                                isShowingSheet.toggle()
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1)
                                {
                                    isShowingEndpointDiscoverySpinner = false
                                    hasSuccessfulyConnectedToEndpoint = false
                                }
                            }
                        }
                    }
                    catch let endpointDiscoveryError
                    {
                        print("Failed while trying to get correct URL to endpoint: \(endpointDiscoveryError)")
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1)
                        {
                            errorOccuredWhileConnectingToEndpoint = true
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2)
                            {
                                withAnimation {
                                    isShowingEndpointDiscoverySpinner = false
                                    errorOccuredWhileConnectingToEndpoint = false
                                }
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .onAppear
        {
            isFocused = true
        }
    }
}
