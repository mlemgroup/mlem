//
//  End Of Feed View.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-22.
//

import Foundation
import SwiftUI

struct EndOfFeedView: View {
    let isLoading: Bool
    
    var body: some View {
        Group {
            if isLoading {
                LoadingView(whatIsLoading: .posts)
            } else {
                HStack {
                    Image(systemName: Icons.endOfFeed)
                    
                    Text("I think I've found the bottom!")
                }
                .foregroundColor(.secondary)
            }
        }
        .frame(minHeight: 100)
    }
}
