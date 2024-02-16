//
//  FeedRowView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-01-08.
//

import Dependencies
import Foundation
import SwiftUI

struct FeedRowView: View {
    let feedType: FeedType
    
    var body: some View {
        HStack {
            Image(systemName: feedType.iconNameCircle)
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundColor(feedType.color)
            
            Text(feedType.label)
        }
    }
}
