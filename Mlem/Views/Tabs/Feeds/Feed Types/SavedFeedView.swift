//
//  SavedFeedView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-01-21.
//

import Foundation
import SwiftUI

struct SavedFeedView: View {
    // TODO: ERIC this should be a multi-feed with saved comments as well
    
    var body: some View {
        AggregateFeedView(feedType: .saved)
    }
}
