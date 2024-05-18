//
//  ToastOverlayView.swift
//  Mlem
//
//  Created by Sjmarf on 17/05/2024.
//

import SwiftUI

struct ToastOverlayView: View {
    let shouldDisplayNewToasts: Bool
    
    @State var activeToast: Toast?
    @State var activeId: UUID?
    @State var shouldTimeout: Bool = true
    
    var toastModel: ToastModel { .main }
    
    var body: some View {
        Group {
            if let activeToast {
                ToastView(toast: activeToast, shouldTimeout: $shouldTimeout)
                    .id(activeId)
                    .transition(
                        .move(edge: .top)
                            .combined(with: .opacity)
                    )
            }
        }
        .animation(.snappy(duration: 0.3, extraBounce: 0.2), value: activeId)
        .onChange(of: toastModel.activeGroup?.activeId) { _, newValue in
            activeId = newValue
            activeToast = shouldDisplayNewToasts ? toastModel.activeToast : nil
            shouldTimeout = true
        }
        .task(id: taskHash) {
            do {
                try await Task.sleep(
                    nanoseconds: UInt64(1_000_000_000 * (activeToast?.duration ?? 1.0))
                )
                if shouldTimeout {
                    toastModel.removeFirst()
                }
            } catch {
                print("Task cancelled early")
            }
        }
    }
    
    var taskHash: Int {
        var hasher = Hasher()
        hasher.combine(activeId)
        hasher.combine(shouldTimeout)
        return hasher.finalize()
    }
}

#Preview {
    VStack {
        Button("Test") {
            ToastModel.main.add(.success())
        }
        Button("Test Long") {
            ToastModel.main.add(
                .basic(
                    title: "Unfavorited Community",
                    systemImage: "star.slash.fill",
                    color: .blue,
                    duration: 5
                )
            )
        }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .overlay(alignment: .top) {
        ToastOverlayView(shouldDisplayNewToasts: true)
    }
}
