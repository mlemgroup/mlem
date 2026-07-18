//
//  InboxView+Views.swift
//  Mlem
//
//  Created by Sjmarf on 22/09/2024.
//

import MlemMiddleware
import SwiftUI

extension InboxView {
    @ViewBuilder
    var inboxFeedView: some View {
        LazyVStack(spacing: 0, pinnedViews: []) {
            Section {
                ForEach(feedLoader.items, id: \.inboxId) { notification in
                    Group {
                        switch notification.content {
                        case let .message(message):
                            MessageView(message: message, notification: notification)
                        case let .reply(comment), let .mention(comment):
                            ReplyView(notification: notification, comment: comment)
                        }
                    }
                    .padding([.horizontal, .bottom], Constants.main.standardSpacing)
                    .onAppear {
                        do {
                            try inboxFeedLoader.loadIfThreshold(notification)
                        } catch {
                            handleError(error)
                        }
                    }
                }
                
                EndOfFeedView(feedLoader: feedLoader, viewType: .cartoon)
            } header: {
                sectionHeader
            }
        }
        .animation(.easeOut(duration: 0.1), value: feedLoader.items.isEmpty)
    }
    
    @ViewBuilder
    var modMailFeedView: some View {
        LazyVStack(spacing: 0) {
            if appState.firstApi.isAdmin {
                BubblePicker(
                    ModTab.allCases,
                    selected: $selectedModTab,
                    label: \.label
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
            label: \.label
        )
    }
    
    @ToolbarContentBuilder
    var toolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            if showRead {
                hideReadButton
            } else {
                hideReadButton
                    .buttonStyle(.glassProminent)
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
            let message: LocalizedStringResource = showRead ? "Showing Read" : "Hiding Read"
            toastModel.add(.success(message))
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
                        Label(String(localized: feedType.label), icon: feedType.icon)
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
        case .inbox: return unreadCount.moderation > 0
        case .modMail: return unreadCount.personal > 0
        }
    }
}
