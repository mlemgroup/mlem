//
//  AccountSwitcherSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 22/12/2023.
//

import SwiftUI
import Dependencies

struct AccountSwitcherSettingsView: View {
    @Dependency(\.accountsTracker) var accountsTracker: SavedAccountTracker
    
    var body: some View {
        Form {
            Section {
                VStack {
                    AccountIconStack(
                        accounts: Array(accountsTracker.savedAccounts.prefix(7)),
                        avatarSize: 64,
                        spacing: 32,
                        outlineWidth: 2.6,
                        backgroundColor: Color(UIColor.systemGroupedBackground)
                    )
                    .padding(.top, -12)
                    Text("Accounts")
                        .font(.title)
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color(.systemGroupedBackground))
            }
            AccountListView()
            if accountsTracker.savedAccounts.count == 2 {
                Section {
                    HStack(alignment: .center, spacing: 24) {
                        TwoAccountSwitchView()
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Tip")
                                .fontWeight(.semibold)
                            Text("Tap and hold the profile icon in the tab bar to quickly switch accounts from anywhere.")
                                .font(.footnote)
                        }
                        .foregroundStyle(.secondary)
                    }
                }
                .listRowInsets(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12))
            } else {
                NavigationLink(.settings(.quickSwitcher)) {
                    Label {
                        VStack(alignment: .leading) {
                            Text("Quick Switcher")
                            Text("Switch accounts quickly from anywhere.")
                                .foregroundStyle(.secondary)
                                .font(.footnote)
                        }
                    } icon: {
                        Image(systemName: "platter.filled.bottom.iphone")
                    }
                    .labelStyle(SquircleLabelStyle(color: .teal))
                }
            }
        }
        .fancyTabScrollCompatible()
    }
    
}

private struct TwoAccountSwitchView: View {

    enum AnimationPhase: CaseIterable {
        case none, fadeInTap, tap, none2, fadeInTap2, tap2
        
        static var order: [AnimationPhase] = [.none, .fadeInTap, .tap, .none2, .fadeInTap2, .tap2]
    }
    
    @Dependency(\.accountsTracker) var accountsTracker: SavedAccountTracker
    
    @State var animationTrigger: Bool = false
    
    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()

    var body: some View {
        if #available(iOS 17.0, *) {
            PhaseAnimator(AnimationPhase.order, trigger: animationTrigger) { phase in
                IPhoneWithSheetView(showingSheet: false)
                    .overlay(alignment: .bottom) {
                        ZStack(alignment: .bottom) {
                            Circle()
                                .fill(.blue)
                                .frame(width: 12, height: 12)
                                .background {
                                    if [.fadeInTap, .tap, .fadeInTap2, .tap2].contains(phase) {
                                        Circle()
                                            .fill(.blue)
                                            .opacity([.tap, .tap2].contains(phase) ? 0 : 0.8)
                                            .scaleEffect([.tap, .tap2].contains(phase) ? 2 : 1)
                                            .transition(.identity)
                                    }
                                }
                                .padding(.bottom, 4)
                                .opacity([.fadeInTap, .tap, .fadeInTap2, .tap2].contains(phase) ? 1 : 0)
                            
                                if [.none, .fadeInTap, .tap2].contains(phase) {
                                    AvatarView(
                                        url: accountsTracker.savedAccounts[0].avatarUrl,
                                        type: .user,
                                        avatarSize: 28,
                                        iconResolution: .unrestricted
                                    )
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                } else {
                                    AvatarView(
                                        url: accountsTracker.savedAccounts[1].avatarUrl,
                                        type: .user,
                                        avatarSize: 28,
                                        iconResolution: .unrestricted
                                    )
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                }
                        }
                    }
            } animation: { phase in
                switch phase {
                case .fadeInTap, .fadeInTap2:
                    return .easeOut(duration: 0.2).delay(1.5)
                case .tap, .tap2:
                    return .easeOut(duration: 0.2).delay(0.3)
                case .none, .none2:
                    return .easeOut(duration: 0.3)
                }
            }
            .task {
                animationTrigger.toggle()
            }
            .onReceive(timer) { _ in
                animationTrigger.toggle()
            }
            
        } else {
            Image(systemName: "lightbulb.max.fill")
                .imageScale(.large)
        }
    }
}
