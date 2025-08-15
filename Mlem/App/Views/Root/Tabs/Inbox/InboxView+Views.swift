//
//  InboxView+Views.swift
//  Mlem
//
//  Created by Sjmarf on 22/09/2024.
//

import MlemMiddleware
import SwiftUI

extension InboxView {
    var shouldPinHeader: Bool {
        if #available(iOS 26, *) { false } else { true }
    }
    
    @ViewBuilder
    var inboxFeedView: some View {
        LazyVStack(spacing: 0, pinnedViews: shouldPinHeader ? [.sectionHeaders] : []) {
            Section {
                ForEach(feedLoader.items, id: \.inboxId) { item in
                    Group {
                        switch item {
                        case let .message(message):
                            MessageView(message: message, isInInbox: true)
                        case let .reply(reply):
                            ReplyView(reply: reply)
                        }
                    }
                    .padding([.horizontal, .bottom], Constants.main.standardSpacing)
                    .onAppear {
                        do {
                            try inboxFeedLoader.loadIfThreshold(item)
                        } catch {
                            handleError(error)
                        }
                    }
                }
                
                EndOfFeedView(feedLoader: feedLoader, viewType: .cartoon)
            } header: {
                if appState.firstApi.supportsOrNil(.viewMentionsAndPrivateMessages) ?? false {
                    sectionHeader
                }
            }
        }
        .animation(.easeOut(duration: 0.1), value: feedLoader.items.isEmpty)
        .padding(.top, (appState.firstApi.supportsOrNil(.viewMentionsAndPrivateMessages) ?? false) ? 0 : Constants.main.standardSpacing)
    }
    
    @ViewBuilder
    var modMailFeedView: some View {
        LazyVStack(spacing: 0) {
            if appState.firstApi.isAdmin {
                BubblePicker(
                    ModTab.allCases,
                    selected: $selectedModTab,
                    label: \.label,
                    value: { tab in
                        if let unreadCount = (appState.firstSession as? UserSession)?.unreadCount {
                            switch tab {
                            case .reports:
                                return unreadCount.reportTotal
                            case .applications:
                                return unreadCount.registrationApplications
                            }
                        }
                        return 0
                    }
                )
            }
            ForEach(currentModFeedLoader.items, id: \.inboxId) { item in
                Group {
                    switch item {
                    case let .application(application):
                        RegistrationApplicationView(application: application)
                    case let .report(report):
                        ReportView(report: report)
                    }
                }
                .padding([.horizontal, .bottom], Constants.main.standardSpacing)
                .onAppear {
                    do {
                        try currentModFeedLoader.loadIfThreshold(item)
                    } catch {
                        handleError(error)
                    }
                }
            }
            EndOfFeedView(feedLoader: currentModFeedLoader, viewType: .cartoon)
        }
        .padding(.top, Constants.main.standardSpacing)
        .animation(.easeOut(duration: 0.1), value: currentModFeedLoader.items.isEmpty)
    }
    
    @ViewBuilder
    var sectionHeader: some View {
        BubblePicker(
            Tab.allCases,
            selected: $selectedTab,
            label: \.label,
            value: { tab in
                if let unreadCount = (appState.firstSession as? UserSession)?.unreadCount {
                    switch tab {
                    case .all:
                        return unreadCount.personalTotal
                    case .replies:
                        return unreadCount.replies
                    case .mentions:
                        return unreadCount.mentions
                    case .messages:
                        return unreadCount.messages
                    }
                }
                return 0
            }
        )
        .background(.themedGroupedBackground.opacity(headerPinned ? 1 : 0))
        .background(.bar)
    }
    
    @ToolbarContentBuilder
    var toolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            if #available(iOS 26, *) {
                // This is a bit of a hack... the WWDC mentioned a `.glassProminent` button style
                // that we should be using here, but it seems to be missing from the API
                if showRead {
                    hideReadButton
                } else {
                    hideReadButton
                        .buttonStyle(.borderedProminent)
                }
            } else {
                hideReadButton
            }
        }
        if selectedFeed == .inbox {
            MarkAllAsReadButton()
        }
    }
    
    @ViewBuilder
    var hideReadButton: some View {
        Button {
            showRead.toggle()
        } label: {
            Label("Hide Read", icon: .general.filterMenu)
                .symbolVariant(showRead ? .none : .fill)
        }
    }
    
    @ViewBuilder
    var headerView: some View {
        let availableFeeds = availableFeeds
        Menu {
            if availableFeeds.count > 1 {
                Picker("Feed", selection: $selectedFeed) {
                    ForEach(availableFeeds) { feedType in
                        Label(feedType.label.key, icon: feedType.icon)
                            .tag(feedType)
                    }
                }
            }
        } label: {
            FeedHeaderView(
                feedDescription: .init(
                    label: selectedFeed.label,
                    subtitle: selectedFeed.subtitle(isAdmin: appState.firstApi.isAdmin),
                    color: selectedFeed.color,
                    icon: selectedFeed.icon,
                    iconScaleFactor: 0.5
                ),
                dropdownStyle: availableFeeds.count > 1 ? .enabled(showBadge: showBadge) : .disabled
            )
        }
    }
    
    @ViewBuilder
    var signedOutInfoView: some View {
        VStack {
            Image(icon: .lemmy.inbox)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 80)
                .foregroundStyle(.themedAccent)
            Text(AccountsTracker.main.isEmpty ? "Log in or sign up to view your inbox." : "Switch account to view your inbox.")
                .font(.title2)
                .padding(.horizontal)
                .fontWeight(.semibold)
                .padding(.bottom, Constants.main.halfSpacing)
            if AccountsTracker.main.isEmpty {
                HStack {
                    infoViewButton("Log In") {
                        navigation.openSheet(.logIn(.pickInstance))
                    }
                    infoViewButton("Sign Up") {
                        navigation.openSheet(.signUp())
                    }
                }
            } else {
                infoViewButton("Switch Account") {
                    navigation.openSheet(.quickSwitcher)
                }
            }
        }
        .buttonStyle(.borderedProminent)
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private func infoViewButton(_ title: LocalizedStringResource, callback: @escaping () -> Void) -> some View {
        Button(action: callback) {
            Text(title)
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .frame(minWidth: 100)
        }
    }
    
    var showBadge: Bool {
        guard let unreadCount = (appState.firstSession as? UserSession)?.unreadCount else { return false }
        switch selectedFeed {
        case .inbox: return unreadCount.moderationTotal > 0
        case .modMail: return unreadCount.personalTotal > 0
        }
    }
}
