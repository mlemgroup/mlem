//
//  QuickSwitcherSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 21/01/2024.
//

import SwiftUI
import Dependencies

struct QuickSwitcherSettingsView: View {
    
    @AppStorage("allowTabBarSwipeUpGesture") var allowTabBarSwipeUpGesture: Bool = true
    @AppStorage("allowQuickSwitcherLongPressGesture") var allowQuickSwitcherLongPressGesture: Bool = true
    
    // TODO: iOS 16 deprecation
    // Theoretically, if we don't provide a trigger it should loop indefinitely. This isn't working for some reason, so I'm adding
    // a trigger and toggling it every n seconds instead. Maybe it's to do with the iOS 17 compiler `if` condition? Check once iOS 16 is deprecated.
    @State var animationTrigger: Bool = false
    
    let timer = Timer.publish(every: 3.7, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Form {
            Section {
                HStack(alignment: .center, spacing: 24) {
                    LongPressAnimationView(animationTrigger: animationTrigger)
                    Toggle(
                        "Tapping and holding the profile icon",
                        isOn: $allowQuickSwitcherLongPressGesture
                    )
                    .toggleStyle(CheckboxToggleStyle())
                }
                
                HStack(alignment: .center, spacing: 24) {
                    SwipeUpAnimationView(animationTrigger: animationTrigger)
                    Toggle(
                        "Swiping up from the tab bar",
                        isOn: $allowTabBarSwipeUpGesture
                    )
                    .toggleStyle(CheckboxToggleStyle())
                }
            } header: {
                Text("Open the Quick Switcher by...")
                    .textCase(nil)
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
