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
        LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
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
            } header: { sectionHeader }
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
            Button {
                showRead.toggle()
            } label: {
                Label("Hide Read", systemImage: Icons.filter)
                    .symbolVariant(showRead ? .none : .fill)
            }
        }
        ToolbarItem(placement: .topBarTrailing) {
            if selectedFeed == .inbox {
                markAllAsReadButton
            }
        }
    }
    
    @ViewBuilder
    var markAllAsReadButton: some View {
        let newMessagesExist = !waitingOnMarkAllAsRead && ((appState.firstSession as? UserSession)?.unreadCount?.personalTotal ?? 0) != 0
        PhaseAnimator([0, 1], trigger: markAllAsReadTrigger) { value in
            Button {
                HapticManager.main.play(haptic: .gentleInfo, priority: .low)
                waitingOnMarkAllAsRead = true
                markAllAsReadTrigger.toggle()
                Task {
                    do {
                        try await appState.firstApi.markAllAsRead()
                        try await Task.sleep(for: .seconds(0.05))
                    } catch {
                        handleError(error)
                    }
                    waitingOnMarkAllAsRead = false
                }
            } label: {
                HStack {
                    Image(icon: .lemmy.markRead)
                        .imageScale(.small)
                    Text("All")
                }
                .opacity((value == 0 && newMessagesExist) ? 1 : 0)
                .overlay {
                    if value != 0 {
                        Image(icon: .general.success)
                            .imageScale(.small)
                            .fontWeight(.semibold)
                    }
                }
                .fixedSize()
                .padding(.vertical, 2)
                .padding(.horizontal, 10)
                .background(.bar, in: .capsule)
            }
            .opacity((newMessagesExist || value != 0) ? 1 : 0)
        }
    }
    
    @ViewBuilder
    var headerView: some View {
        let availableFeeds = availableFeeds
        Menu {
            if availableFeeds.count > 1 {
                Picker("Feed", selection: $selectedFeed) {
                    ForEach(availableFeeds) { feedType in
                        Label(String(localized: feedType.label), systemImage: feedType.systemImage)
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
                    iconName: selectedFeed.systemImage,
                    iconNameFill: selectedFeed.systemImageFill,
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
