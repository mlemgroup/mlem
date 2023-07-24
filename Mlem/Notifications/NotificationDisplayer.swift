// 
//  NotificationDisplayer.swift
//  Mlem
//
//  Created by mormaer on 19/07/2023.
//  
//

import AlertToast
import SwiftUI
import UIKit

class NotificationDisplayer {
    
    private enum NotificationDisplayerError: Error {
        case unableToDisplayLoader
    }
    
    static func display(_ notifiable: some Notifiable) async {
        switch notifiable {
        case let contextualError as ContextualError:
            await display(contextualError: contextualError)
        case let reward as RewardType:
            await display(reward: reward)
        case let message as Notifier.Message:
            await display(message: message)
        case let task as Task<Void, Never>:
            await(displayLoader(for: task))
        default:
            break
        }
    }
    
    private static func display(contextualError: ContextualError) async {
        switch contextualError.style {
        case .alert:
            await displayAlert(
                title: contextualError.title,
                message: contextualError.message
            )
        case .toast:
            if let message = contextualError.title ?? contextualError.message {
                let toast = AlertToast(
                    displayMode: .hud,
                    type: .error(.red),
                    title: message
                )
                await display(toast: toast)
            }
        }
    }
    
    private static func display(reward: RewardType) async {
        switch reward {
        case let .icon(iconName, _):
            let toast = AlertToast(
                displayMode: .hud,
                type: .systemImage("gift.fill", .pink),
                title: "New icon!",
                subTitle: "Unlocked the \"\(iconName)\" icon"
            )
            
            await display(toast: toast)
        }
    }
    
    private static func display(message: Notifier.Message) async {
        let toast: AlertToast
        switch message {
        case let .success(message):
            toast = .init(displayMode: .hud, type: .complete(.green), title: message)
        case let .failure(message):
            toast = .init(displayMode: .hud, type: .error(.red), title: message)
        }
        
        await display(toast: toast)
    }
    
    private static func displayLoader(for task: Task<Void, Never>) async {
        let toast = AlertToast(displayMode: .hud, type: .loading, title: "Loading, please wait...")
        let toastView = try? await displayLoading(toast: toast)
        await task.value
        Task { @MainActor in
            UIView.animate(
                withDuration: 0.3,
                animations: {
                    toastView?.alpha = 0
                },
                completion: { _ in
                    toastView?.removeFromSuperview()
                }
            )
        }
    }
    
    private static func displayAlert(title: String?, message: String?) async {
        await withCheckedContinuation { continuation in
            guard title?.isEmpty == false || message?.isEmpty == false else {
                // if we have nothing to display... don't display it 🙃
                continuation.resume()
                return
            }
            
            Task { @MainActor in
                let alert = UIAlertController(
                    title: title,
                    message: message,
                    preferredStyle: .alert
                )
                
                let action = UIAlertAction(title: "OK", style: .cancel) { _ in
                    continuation.resume()
                }
                
                alert.addAction(action)
                present(alert)
            }
        }
    }
    
    private static func displayLoading(toast: AlertToast) async throws -> UIView {
        try await withCheckedThrowingContinuation { continuation in
            Task { @MainActor in
                guard let toastView = UIHostingController(rootView: toast).view,
                      let controller = UIApplication.shared.topMostViewController else {
                    continuation.resume(throwing: NotificationDisplayerError.unableToDisplayLoader)
                    return
                }
                
                toastView.translatesAutoresizingMaskIntoConstraints = false
                toastView.backgroundColor = .clear
                toastView.alpha = 0
                controller.view.addSubview(toastView)
                switch toast.displayMode {
                case .alert:
                    toastView.centerXAnchor.constraint(equalTo: controller.view.centerXAnchor).isActive = true
                    toastView.centerYAnchor.constraint(equalTo: controller.view.centerYAnchor).isActive = true
                case .banner:
                    toastView.centerXAnchor.constraint(equalTo: controller.view.centerXAnchor).isActive = true
                    toastView.bottomAnchor.constraint(equalTo: controller.view.bottomAnchor).isActive = true
                case .hud:
                    toastView.centerXAnchor.constraint(equalTo: controller.view.centerXAnchor).isActive = true
                    toastView.topAnchor.constraint(equalTo: controller.view.topAnchor).isActive = true
                }
                UIView.animate(
                    withDuration: 0.3,
                    animations: {
                        toastView.alpha = 1
                    },
                    completion: { _ in
                        continuation.resume(returning: toastView)
                    }
                )
            }
        }
    }
    
    private static func display(toast: AlertToast) async {
        await withCheckedContinuation { continuation in
            Task { @MainActor in
                guard let toastView = UIHostingController(rootView: toast).view,
                      let controller = UIApplication.shared.topMostViewController else {
                    continuation.resume()
                    return
                }
                
                toastView.translatesAutoresizingMaskIntoConstraints = false
                toastView.backgroundColor = .clear
                toastView.alpha = 0
                controller.view.addSubview(toastView)
                switch toast.displayMode {
                case .alert:
                    toastView.centerXAnchor.constraint(equalTo: controller.view.centerXAnchor).isActive = true
                    toastView.centerYAnchor.constraint(equalTo: controller.view.centerYAnchor).isActive = true
                case .banner:
                    toastView.centerXAnchor.constraint(equalTo: controller.view.centerXAnchor).isActive = true
                    toastView.bottomAnchor.constraint(equalTo: controller.view.bottomAnchor).isActive = true
                case .hud:
                    toastView.centerXAnchor.constraint(equalTo: controller.view.centerXAnchor).isActive = true
                    toastView.topAnchor.constraint(equalTo: controller.view.topAnchor).isActive = true
                }
                UIView.animate(withDuration: 0.3) {
                    toastView.alpha = 1
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    UIView.animate(
                        withDuration: 0.3,
                        animations: {
                            toastView.alpha = 0
                        },
                        completion: { _ in
                            toastView.removeFromSuperview()
                            continuation.resume()
                        }
                    )
                }
            }
        }
    }
    
    static func presentTokenRefreshFlow(
        for account: SavedAccount,
        refreshedAccount: @escaping (SavedAccount) -> Void
    ) {
        let tokenRefreshView = TokenRefreshView(account: account, refreshedAccount: refreshedAccount)
        let view = UIHostingController(rootView: tokenRefreshView)
        present(view)
    }
    
    private static func present(_ viewController: UIViewController) {
        UIApplication.shared.topMostViewController?.present(viewController, animated: true)
    }
}
