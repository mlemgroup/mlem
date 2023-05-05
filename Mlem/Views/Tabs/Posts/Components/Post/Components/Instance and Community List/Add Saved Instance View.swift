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
    
    @FocusState var isFocused

    var body: some View
    {
        VStack(alignment: .leading, spacing: 15)
        {
            Form
            {
                Section("Instance")
                {
                    HStack
                    {
                        Text("Instance")
                        Spacer()
                        TextField("Instance", text: $instanceLink, prompt: Text("hexbear.net"))
                            .autocorrectionDisabled()
                            .focused($isFocused)
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
            .onSubmit
            {
                isShowingSheet.toggle()
                communityTracker.savedCommunities.append(SavedCommunity(instanceLink: instanceLink, communityName: community))
            }
        }
        .padding()
        .onAppear
        {
            isFocused = true
        }
    }
}
