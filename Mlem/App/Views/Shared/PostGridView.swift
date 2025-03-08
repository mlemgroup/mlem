//
//  PostFeedView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-06-29.
//

import Foundation
import MlemMiddleware
import SwiftUI

/// Renders the content of a given StandardPostFeedLoader and adds a toolbar menu with the standard post feed controls. Additional toolbar actions
/// should be handled by using ToolbarItemGroup(placement: .secondaryAction) on the parent view.
/// This view handles:
/// - Post layout
/// - Loading
/// - Default toolbar menu actions (show/hide read, post size)
/// Scrolling, handling feed type changes, header, footer, etc. should be handled by the parent view
struct PostGridView: View {
    @Setting(\.postSize) var postSize
    @Setting(\.showReadInFeed) var showRead
    @Setting(\.infiniteScroll) var infiniteScroll
    @Setting(\.allowMultiplePostColumns) var allowMultipleColumns
    
    @Environment(FiltersTracker.self) var filtersTracker
    
    @Environment(\.communityContext) var communityContext
    
    @State var frameWidth: CGFloat = .zero
    @State var bottomAppearedPostIndex: Int = -1
    
    @State var isWideEnoughForTwoColumns: Bool = false
    
    @Namespace var navigationNamespace
    
    let postFeedLoader: CorePostFeedLoader

    init(postFeedLoader: CorePostFeedLoader) {
        self.postFeedLoader = postFeedLoader
    }
    
    var body: some View {
        content
            .widthReader(width: $frameWidth)
            .environment(\.parentFrameWidth, frameWidth)
            .loadFeed(postFeedLoader)
            .task(id: showRead) {
                do {
                    if showRead {
                        try await postFeedLoader.deactivateFilter(.read)
                    } else {
                        try await postFeedLoader.activateFilter(.read)
                    }
                } catch {
                    handleError(error)
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .secondaryAction) {
                    SwiftUI.Section {
                        standardMenu
                    }
                }
            }
    }
    
    var content: some View {
        VStack(spacing: 0) {
            GeometryReader { geometry in
                Spacer()
                    .onChange(of: geometry.size.width, initial: true) {
                        let newVal = geometry.size.width > 700
                        if isWideEnoughForTwoColumns != newVal { // Avoid unnecessary view update
                            isWideEnoughForTwoColumns = newVal
                        }
                    }
            }
            .frame(height: 0)
            let columns = columns
            LazyVGrid(columns: columns, spacing: postSize.sectionSpacing) {
                ForEach(Array(postFeedLoader.items.enumerated()), id: \.element.hashValue) { index, post in
                    if !post.shouldHideInFeed {
                        NavigationLink(.post(post, communityContext: communityContext, navigationNamespace: navigationNamespace)) {
                            FeedPostView(post: post, requireConsistentHeight: columns.count != 1)
                                .matchedTransitionSource_(id: "post\(post.actorId)", in: navigationNamespace)
                        }
                        .buttonStyle(.empty)
                        .padding(.horizontal, postInnerPadding)
                        .markReadOnScroll(
                            index: index,
                            post: post,
                            postFeedLoader: postFeedLoader, bottomAppearedItemIndex: $bottomAppearedPostIndex
                        )
                        .onAppear {
                            if infiniteScroll {
                                do {
                                    try postFeedLoader.loadIfThreshold(post)
                                } catch {
                                    // TODO: if postFeedLoader.loadIfThreshold throws 400, this line is not executed
                                    handleError(error)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, postSize.tiled || columns.count == 1 ? 0 : Constants.main.halfSpacing)
            .animation(.easeOut(duration: 0.1), value: postFeedLoader.items.isEmpty)
            EndOfFeedView(feedLoader: postFeedLoader, viewType: .hobbit)
        }
    }
    
    var postInnerPadding: CGFloat {
        if columns.count == 1 {
            Constants.main.standardSpacing
        } else {
            Constants.main.standardSpacing / (postSize == .compact ? 4 : 2)
        }
    }
    
    var columns: [GridItem] {
        if postSize.tiled || (postSize != .large && isWideEnoughForTwoColumns), allowMultipleColumns {
            // leading/trailing alignment makes them want to stick to each other, allowing the Constants.main.halfSpacing padding applied below
            // to push them apart by a sum of Constants.main.standardSpacing
            
            // Avoid causing unnecessary view update
            return [
                GridItem(.flexible(), spacing: 0, alignment: .trailing),
                GridItem(.flexible(), spacing: 0, alignment: .leading)
            ]
        } else {
            // Only trigger if not already 1 column to avoid causing unnecessary view update
            return [GridItem(.flexible())]
        }
    }
    
    @ViewBuilder
    var standardMenu: some View {
        Button(showRead ? "Hide Read" : "Show Read", systemImage: Icons.read) {
            showRead.toggle()
        }
        
        Menu {
            Picker("Post Size", selection: $postSize) {
                ForEach(PostSize.allCases, id: \.self) { item in
                    Label(String(localized: item.label), systemImage: item.icon(filled: postSize == item))
                }
            }
        } label: {
            Label("Post Size", systemImage: Icons.postSizeSetting)
        }
    }
}
