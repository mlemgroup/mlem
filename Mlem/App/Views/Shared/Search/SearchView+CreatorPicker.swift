//
//  SearchView+CreatorPicker.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-19.
//

import MlemMiddleware
import SwiftUI

extension SearchView {
    struct CreatorPicker: View {
        @Environment(NavigationLayer.self) var navigation
        
        let api: ApiClient
        @Binding var creator: Person?
        
        var body: some View {
            Button(creator?.name ?? .init(localized: "Anyone"), icon: .lemmy.person) {
                if creator == nil {
                    navigation.openSheet(.personPicker(
                        api: api,
                        callback: { person in
                            creator = person
                        }
                    ))
                } else {
                    creator = nil
                }
            }
            .buttonStyle(FeedFilterButtonStyle(
                isOn: creator != nil,
                icon: creator == nil ? .general.dropDown : .general.close
            ))
        }
    }
}
