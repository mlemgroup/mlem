//
//  ToastOverlayView.swift
//  Mlem
//
//  Created by Sjmarf on 17/05/2024.
//

import SwiftUI

struct ToastOverlayView: View {
    @State var activeToast: Toast?
    @State var shouldFadeOut: Bool = false
    @State var activeId: UUID?
    
    var toastModel: ToastModel { .main }
    
    var body: some View {
        Group {
            if let activeToast {
                ToastView(toast: activeToast)
                    .id(activeId)
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .top),
                            removal: shouldFadeOut ? .identity : .move(edge: .top)
                        )
                        .combined(with: .opacity)
                    )
                    .padding(.top, -6)
            }
        }
        .animation(.easeOut(duration: 0.2), value: activeId)
        .onChange(of: toastModel.activeGroup?.activeId) { _, newValue in
            print("NEWVALUE", newValue)
            shouldFadeOut = newValue != nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                activeId = newValue
                activeToast = toastModel.activeToast
            }
        }
        .task(id: activeId) {
            do {
                try await Task.sleep(nanoseconds: 1_000_000_000)
                toastModel.removeFirst()
            } catch {
                print("Task cancelled early")
            }
        }
    }
}
