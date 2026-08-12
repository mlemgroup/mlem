//
//  MarkAllAsReadButton.swift
//  Mlem
//
//  Created by Sjmarf on 2025-08-15.
//

import Haptics
import SwiftUI

struct MarkAllAsReadButton: ToolbarContent {
    @Environment(AppState.self) var appState
    @Environment(HapticManager.self) var hapticManager

    @State var animationPlaying: Bool = false
    @State var phaseAnimatorTrigger: Bool = false
    
    var body: some ToolbarContent {
        Group {
            if newMessagesExist || animationPlaying {
                ToolbarItem(placement: .topBarTrailing) {
                    PhaseAnimator([0, 1], trigger: phaseAnimatorTrigger) { value in
                        Button {
                            hapticManager.play(haptic: .gentleInfo, tier: .low)
                            animationPlaying = true
                            phaseAnimatorTrigger.toggle()
                            Task {
                                do {
                                    try await appState.firstApi.markAllAsRead()
                                    try await Task.sleep(for: .seconds(0.25))
                                } catch {
                                    handleError(error)
                                }
                                animationPlaying = false
                            }
                        } label: {
                            label(value: value)
                        }
                        .opacity((newMessagesExist || value != 0) ? 1 : 0)
                    }
                }
            }
        }
    }
    
    var newMessagesExist: Bool {
        !animationPlaying && ((appState.firstSession as? UserSession)?.unreadCount?.personal ?? 0) != 0
    }
    
    @ViewBuilder
    func label(value: Int) -> some View {
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
    }
}
