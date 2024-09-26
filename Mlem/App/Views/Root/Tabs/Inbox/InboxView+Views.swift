//
//  InboxView+Views.swift
//  Mlem
//
//  Created by Sjmarf on 22/09/2024.
//

import SwiftUI

extension InboxView {
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
                        return unreadCount.total
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
        .background(palette.groupedBackground.opacity(headerPinned ? 1 : 0))
        .background(.bar)
    }
    
    @ViewBuilder
    var refreshPopup: some View {
        HStack(spacing: 0) {
            Text("Inbox is outdated")
                .padding(.horizontal, 10)
            Button {
                showRefreshPopup = false
                HapticManager.main.play(haptic: .lightSuccess, priority: .high)
                Task { @MainActor in
                    removeAll()
                    await loadReplies()
                }
            } label: {
                Label("Refresh", systemImage: Icons.refresh)
                    .foregroundStyle(palette.selectedInteractionBarItem)
                    .fontWeight(.semibold)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 10)
                    .background(palette.accent, in: .capsule)
            }
            .buttonStyle(.plain)
        }
        .padding(4)
        .background(palette.secondaryBackground, in: .capsule)
        .shadow(color: .black.opacity(0.1), radius: 5)
        .shadow(color: .black.opacity(0.1), radius: 1)
        .padding()
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
            markAllAsReadButton
        }
    }
    
    @ViewBuilder
    var markAllAsReadButton: some View {
        let newMessagesExist = !waitingOnMarkAllAsRead && ((appState.firstSession as? UserSession)?.unreadCount?.total ?? 0) != 0
        PhaseAnimator([0, 1], trigger: markAllAsReadTrigger) { value in
            Button {
                HapticManager.main.play(haptic: .gentleInfo, priority: .low)
                waitingOnMarkAllAsRead = true
                markAllAsReadTrigger.toggle()
                Task {
                    do {
                        try await appState.firstApi.markAllAsRead()
                        if !showRead {
                            removeAll()
                        }
                        try await Task.sleep(for: .seconds(0.05))
                    } catch {
                        handleError(error)
                    }
                    waitingOnMarkAllAsRead = false
                }
            } label: {
                HStack {
                    Image(systemName: Icons.markRead)
                        .imageScale(.small)
                    Text("All")
                }
                .opacity((value == 0 && newMessagesExist) ? 1 : 0)
                .overlay {
                    if value != 0 {
                        Image(systemName: Icons.success)
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
    var signedOutInfoView: some View {
        VStack {
            Image(systemName: Icons.inbox)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 80)
                .foregroundColor(palette.accent)
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
}
