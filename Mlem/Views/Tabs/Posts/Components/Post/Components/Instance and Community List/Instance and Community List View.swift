//
//  Instance and Community List View.swift
//  Mlem
//
//  Created by David Bureš on 27.03.2022.
//

import SwiftUI

struct InstanceCommunityListView: View
{
    @EnvironmentObject var communitiesTracker: SavedCommunityTracker

    @State private var isShowingInstanceAdditionSheet: Bool = false

    var body: some View
    {
        NavigationView
        {
            VStack
            {
                if !communitiesTracker.savedCommunities.isEmpty
                {
                    List
                    {
                        ForEach(communitiesTracker.savedCommunities)
                        { savedCommunity in
                            NavigationLink
                            {
                                if !savedCommunity.communityName.isEmpty
                                {
                                    CommunityView(instanceAddress: savedCommunity.instanceLink, communityName: savedCommunity.communityName, communityID: nil)
                                }
                                else
                                {
                                    CommunityView(instanceAddress: savedCommunity.instanceLink, communityName: nil, communityID: nil)
                                }
                            } label: {
                                HStack(alignment: .center)
                                {
                                    if savedCommunity.communityName.isEmpty
                                    {
                                        Text("All Communities")
                                    }
                                    else
                                    {
                                        Text(savedCommunity.communityName)
                                    }
                                    Spacer()
                                    Text(savedCommunity.instanceLink.host!)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
                else
                {
                    VStack(alignment: .center, spacing: 15) {
                        Text("You have no saved communities")
                    }
                    .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Communities")
            .toolbar
            {
                ToolbarItem(placement: .navigationBarTrailing)
                {
                    Button
                    {
                        isShowingInstanceAdditionSheet.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isShowingInstanceAdditionSheet)
            {
                AddSavedInstanceView(isShowingSheet: $isShowingInstanceAdditionSheet)
            }
        }
    }
}
