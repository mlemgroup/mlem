//
//  InboxViewNew.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-09-26.
//
import Foundation
import SwiftUI

enum InboxTabNew: String, CaseIterable, Identifiable {
    case all, replies, mentions, messages

    var id: Self { self }

    var label: String {
        rawValue.capitalized
    }
}

struct InboxViewNew: View {
    // user preferences
    
    // environment
    @Environment(\.tabSelectionHashValue) private var selectedTagHashValue
    @Environment(\.tabNavigationSelectionHashValue) private var selectedNavigationTabHashValue

    // data model
    @StateObject var inboxTracker: InboxTrackerNew

    // utility
    @StateObject private var inboxRouter: NavigationRouter<NavigationRoute>
    @State var curTab: InboxTabNew = .all

    init() {
        @AppStorage("internetSpeed") var internetSpeed: InternetSpeed = .fast
        @AppStorage("shouldFilterRead") var unreadOnly = false

        self._inboxRouter = StateObject(wrappedValue: .init())

        self._inboxTracker = StateObject(wrappedValue: .init(
            internetSpeed: internetSpeed,
            repliesTracker: .init(),
            mentionsTracker: .init(),
            messagesTracker: .init(internetSpeed: internetSpeed, unreadOnly: unreadOnly)
        ))
    }

    var body: some View {
        // NOTE: there appears to be a SwiftUI issue with segmented pickers stacked on top of ScrollViews which causes the tab bar to appear fully transparent. The internet suggests that this may be a bug that only manifests in dev mode, so, unless this pops up in a build, don't worry about it. If it does manifest, we can either put the Picker *in* the ScrollView (bad because then you can't access it without scrolling to the top) or put a Divider() at the bottom of the VStack (bad because then the material tab bar doesn't show)
        NavigationStack(path: $inboxRouter.path) {
            contentView
                .navigationTitle("Inbox")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarColor()
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarTrailing) { ellipsisMenu }
                }
                .listStyle(PlainListStyle())
                .handleLemmyViews()
                .onChange(of: selectedTagHashValue) { newValue in
                    if newValue == TabSelection.inbox.hashValue {
                        print("switched to inbox tab")
                    }
                }
                .onChange(of: selectedNavigationTabHashValue) { newValue in
                    if newValue == TabSelection.inbox.hashValue {
                        print("re-selected \(TabSelection.inbox) tab")
                    }
                }
        }
    }

    @ViewBuilder
    var contentView: some View {
        VStack(spacing: AppConstants.postAndCommentSpacing) {
            Picker(selection: $curTab, label: Text("Inbox tab")) {
                ForEach(InboxTabNew.allCases) { tab in
                    Text(tab.label).tag(tab.rawValue)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            ScrollView(showsIndicators: false) {
                switch curTab {
                case .all:
                    AllInboxFeedView(inboxTracker: inboxTracker)
                case .replies:
                    Text("TODO: replies")
                case .mentions:
                    Text("TODO: mentions")
                case .messages:
                    Text("TODO: messages")
                }
            }
            .fancyTabScrollCompatible()
        }
    }

    @ViewBuilder
    private var ellipsisMenu: some View {
        Menu {
            ForEach(genMenuFunctions()) { menuFunction in
                MenuButton(menuFunction: menuFunction, confirmDestructive: nil) // no destructive functions
            }
        } label: {
            Label("More", systemImage: "ellipsis")
                .frame(height: AppConstants.barIconHitbox)
                .contentShape(Rectangle())
        }
    }
}
