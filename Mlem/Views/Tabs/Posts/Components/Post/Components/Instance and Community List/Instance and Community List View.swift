//
//  Instance and Community List View.swift
//  Mlem
//
//  Created by David Bureš on 27.03.2022.
//

import SwiftUI

struct Instance_and_Community_List_View: View
{
    var body: some View
    {
        NavigationView
        {
            List
            {
                Section(header: Text("hexbear"))
                {
                    NavigationLink("All Communities", destination: {
                        Community_View(instanceAddress: "hexbear.net", communityName: "All", communityID: nil)
                    })

                    NavigationLink("ChapoTrapHouse", destination: {
                        Community_View(instanceAddress: "hexbear.net", communityName: "chapotraphouse", communityID: nil)
                    })
                    NavigationLink("Piracy", destination: {})
                    NavigationLink("News", destination: {})
                }

                Section(header: Text("lemmy.ml"))
                {
                    NavigationLink("All Communities", destination: {})
                    NavigationLink("Linux", destination: {})
                    NavigationLink("Worldnews", destination: {})
                    NavigationLink("LatAm", destination: {})
                }
            }
            .navigationTitle("Communities")
            .onAppear()
        }
    }
}
