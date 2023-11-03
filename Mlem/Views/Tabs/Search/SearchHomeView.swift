//
//  SearchHomeView.swift
//  Mlem
//
//  Created by Sjmarf on 24/09/2023.
//

import SwiftUI

struct SearchHomeView: View {
    @EnvironmentObject var searchModel: SearchModel
    @EnvironmentObject var contentTracker: ContentTracker<AnyContentModel>
    
    @State var shouldLoad: Bool = false
    
    var body: some View {
        List {
//        VStack(alignment: .leading, spacing: 0) {
//            Text("Browse")
//                .font(.title2)
//                .fontWeight(.semibold)
//                .padding(.horizontal, 18)
//                .padding(.top, 12)
//            ScrollView(.horizontal) {
//                SearchTabPicker(selected: $searchModel.searchTab, tabs: SearchTab.homePageCases)
//                    .padding(.horizontal)
//            }
//            .scrollIndicators(.hidden)
//            .padding(.top, 8)
//            .padding(.bottom, 12)
//            Divider()
            SearchResultListView(showTypeLabel: false)
        }
        .listStyle(.plain)
        .frame(maxWidth: .infinity)
        .environmentObject(contentTracker)
        .environmentObject(searchModel)
        .onChange(of: searchModel.searchTab) { _ in
            searchModel.tabSwitchRefresh(contentTracker: contentTracker)
        }
        .onAppear {
            if contentTracker.items.isEmpty {
                contentTracker.refresh(using: searchModel.performSearch)
            }
        }
    }
}

#Preview {
    SearchHomeViewPreview()
}

struct SearchHomeViewPreview: View {
    
    @StateObject var homeSearchModel: SearchModel = .init()
    @StateObject var homeContentTracker: ContentTracker<AnyContentModel> = .init()
    
    var body: some View {
        VStack {
            SearchHomeView(shouldLoad: true)
                .environmentObject(homeSearchModel)
                .environmentObject(homeContentTracker)
        }
    }
}
