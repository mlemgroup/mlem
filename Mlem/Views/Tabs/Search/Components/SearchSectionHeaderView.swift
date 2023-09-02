//
//  SearchSectionHeaderView.swift
//  Mlem
//
//  Created by Sjmarf on 27/08/2023.
//

import SwiftUI

private struct ViewOffsetKey: PreferenceKey {
    public typealias Value = CGFloat
    public static var defaultValue = CGFloat.zero
    public static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

struct SearchSectionHeaderView: View {
    let title: String
    let filter: SearchFilter
    
    @EnvironmentObject var searchModel: SearchModel
    
//    @State var pinned: Bool = false

    var body: some View {
        Group {
            HStack {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                if searchModel.activeTypeFilter == nil {
                    Button("See All") {
                        searchModel.addFilter(filter)
                    }
                    .foregroundStyle(Color.accentColor)
                    .buttonStyle(.borderless)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 6)
//            .background(
//                ZStack {
//                    GeometryReader {
//                        Color.clear.preference(key: ViewOffsetKey.self, value: $0.frame(in: .named("searchArea")).origin.y)
//                    }
//                    if pinned {
//                        Rectangle()
//                            .fill(.bar)
//                            .overlay(alignment: .top) {
//                                Divider()
//                            }
//                    }
//                }
//            )
            .foregroundStyle(.primary)
//            .onPreferenceChange(ViewOffsetKey.self) {
//                // verify if position is zero (pinned) in container coordinates
//                self.pinned = Int($0) <= 0
//            }
        }
    }
}
