//
//  QuickSwitcherSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 21/01/2024.
//

import Dependencies
import SwiftUI

struct QuickSwitcherSettingsView: View {
    @Dependency(\.accountsTracker) var accountsTracker: SavedAccountTracker
    
    @AppStorage("allowQuickSwitcherLongPressGesture") var allowQuickSwitcherLongPressGesture: Bool = true
    @AppStorage("allowTabBarSwipeUpGesture") var allowTabBarSwipeUpGesture: Bool = false
    
    // TODO: iOS 16 deprecation
    // Theoretically, if we don't provide a trigger it should loop indefinitely. This isn't working for some reason, so I'm adding
    // a trigger and toggling it every n seconds instead. Maybe it's to do with the iOS 17 compiler `if` condition? Check once iOS 16 is deprecated.
    @State var animationTrigger: Bool = false
    
    let timer = Timer.publish(every: 3.7, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Form {
            Section {
                HStack(alignment: .center, spacing: 24) {
                    if accountsTracker.savedAccounts.count == 2 {
                        TwoAccountSwitchView(animationTrigger: animationTrigger)
                        Toggle(
                            "Tap and hold the profile icon to switch accounts",
                            isOn: $allowQuickSwitcherLongPressGesture
                        )
                        .toggleStyle(CheckboxToggleStyle())
                    } else {
                        LongPressAnimationView(animationTrigger: animationTrigger)
                        Toggle(
                            "Tapping and holding the profile icon",
                            isOn: $allowQuickSwitcherLongPressGesture
                        )
                        .toggleStyle(CheckboxToggleStyle())
                    }
                }
                
                HStack(alignment: .center, spacing: 24) {
                    SwipeUpAnimationView(animationTrigger: animationTrigger)
                    let text = (accountsTracker.savedAccounts.count == 2
                        ? "Swipe up from the tab bar to open the quick switcher"
                        : "Swiping up from the tab bar"
                    )
                    Toggle(
                        text,
                        isOn: $allowTabBarSwipeUpGesture
                    )
                    .toggleStyle(CheckboxToggleStyle())
                }
            } header: {
                if accountsTracker.savedAccounts.count > 2 {
                    Text("Open the Quick Switcher by...")
                        .textCase(nil)
                }
            }
            .listRowInsets(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12))
        }
        .fancyTabScrollCompatible()
        .navigationTitle("Quick Switcher")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            animationTrigger.toggle()
        }
        .onReceive(timer) { _ in
            animationTrigger.toggle()
        }
    }
}

#Preview {
    NavigationStack {
        QuickSwitcherSettingsView()
    }
}

struct IPhoneWithSheetView: View {
    @Environment(\.colorScheme) var colorScheme
    
    let showingSheet: Bool
    
    var body: some View {
        VStack {
            Spacer()
            Color(colorScheme == .light ? .systemGray5 : .systemGray4)
                .frame(height: 20)
        }
        .overlay(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(.secondarySystemGroupedBackground))
                .frame(height: showingSheet ? 35 : 0)
        }
        .frame(width: 43, height: 80)
        .background(Color(.tertiarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(.secondary.opacity(0.5), lineWidth: 1))
    }
}

private struct LongPressAnimationView: View {
    enum AnimationPhase: CaseIterable {
        case sheetClosed, fadeInTap, tap, slideInSheet, sheetTap, slideOutSheet
    }
    
    let animationTrigger: Bool

    var body: some View {
        if #available(iOS 17.0, *) {
            PhaseAnimator(AnimationPhase.allCases, trigger: animationTrigger) { phase in
                IPhoneWithSheetView(showingSheet: [.slideInSheet, .sheetTap, .slideOutSheet].contains(phase))
                    .overlay(alignment: .bottom) {
                        Circle()
                            .fill(.blue)
                            .frame(width: 12, height: 12)
                            .background {
                                if [.fadeInTap, .tap].contains(phase) {
                                    Circle()
                                        .fill(.blue)
                                        .opacity(phase == .tap ? 0 : 0.8)
                                        .scaleEffect(phase == .tap ? 2 : 1)
                                        .transition(.identity)
                                }
                            }
                            .padding(.bottom, 4)
                            .opacity([.fadeInTap, .tap].contains(phase) ? 1 : 0)
                        Circle()
                            .fill(.blue)
                            .frame(width: 12, height: 12)
                            .opacity(phase == .sheetTap ? 1 : 0)
                            .padding(.top, 8)
                            .offset(y: -17)
                    }
            } animation: { phase in
                switch phase {
                case .fadeInTap:
                    return .easeOut(duration: 0.2)
                case .tap:
                    return .easeOut(duration: 0.2).delay(0.3)
                case .slideInSheet:
                    return .easeOut(duration: 0.3)
                case .sheetTap:
                    return .easeOut(duration: 0.05).delay(1.4)
                default:
                    return .easeOut(duration: 0.3)
                }
            }
            
        } else {
            EmptyView()
        }
    }
}

private struct SwipeUpAnimationView: View {
    enum AnimationPhase: CaseIterable {
        case sheetClosed, fadeInTap, slideInSheet, sheetTap, slideOutSheet
    }
    
    let animationTrigger: Bool

    var body: some View {
        if #available(iOS 17.0, *) {
            PhaseAnimator(AnimationPhase.allCases, trigger: animationTrigger) { phase in
                IPhoneWithSheetView(showingSheet: [.slideInSheet, .sheetTap, .slideOutSheet].contains(phase))
                    .overlay(alignment: .bottom) {
                        Circle()
                            .fill(.blue)
                            .frame(width: 12, height: 12)
                            .padding(.bottom, 4)
                            .opacity([.fadeInTap].contains(phase) ? 1 : 0)
                            .offset(y: phase == .slideInSheet ? -30 : 0)
                        Circle()
                            .fill(.blue)
                            .frame(width: 12, height: 12)
                            .opacity(phase == .sheetTap ? 1 : 0)
                            .padding(.top, 8)
                            .offset(y: -17)
                    }
            } animation: { phase in
                switch phase {
                case .fadeInTap:
                    return .easeOut(duration: 0.1).delay(0.6)
                case .slideInSheet:
                    return .easeOut(duration: 0.3)
                case .sheetTap:
                    return .easeOut(duration: 0.05).delay(1.4)
                default:
                    return .easeOut(duration: 0.3)
                }
            }
        } else {
            EmptyView()
        }
    }
}

private struct TwoAccountSwitchView: View {
    enum AnimationPhase: CaseIterable {
        case none, fadeInTap, tap, none2, fadeInTap2, tap2
        
        static var order: [AnimationPhase] = [.none, .fadeInTap, .tap, .none2, .fadeInTap2, .tap2]
    }
    
    @Dependency(\.accountsTracker) var accountsTracker: SavedAccountTracker
    
    let animationTrigger: Bool

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
            
        } else {
            Image(systemName: "lightbulb.max.fill")
                .imageScale(.large)
        }
    }
}
