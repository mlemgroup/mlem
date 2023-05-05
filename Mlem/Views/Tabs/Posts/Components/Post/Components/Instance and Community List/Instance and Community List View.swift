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
            List
            {
                ForEach(communitiesTracker.savedCommunities)
                { savedCommunity in
                    NavigationLink {
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
                            Text(savedCommunity.instanceLink)
                                .foregroundColor(.secondary)
                        }
                    }

                }
            }
            .navigationTitle("Communities")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isShowingInstanceAdditionSheet.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }

                }
            }
            .sheet(isPresented: $isShowingInstanceAdditionSheet) {
                AddSavedInstanceView(isShowingSheet: $isShowingInstanceAdditionSheet)
            }
        }
    }
}
