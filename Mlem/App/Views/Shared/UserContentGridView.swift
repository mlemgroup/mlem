//
//  UserContentGridView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-07-18.
//

import Foundation
import MlemMiddleware
import SwiftUI

struct UserContentGridView: View {
    var feedLoader: any FeedLoading<UserContent>
    
    var body: some View {
        Text("\(feedLoader.items.count)")
    }
}
