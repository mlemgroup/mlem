//
//  NotificationDisplayer.swift
//  Mlem
//
//  Created by mormaer on 19/07/2023.
//
//

import Dependencies
import SwiftUI

/// A class responsible for displaying important notifications to the user
enum NotificationDisplayer {
    // MARK: - Public methods
    
    /// A method that displays a `Notifiable` object to the user
    /// - Important: Calling this method directly is discouraged you should instead add
    ///              notifications via the `.add(...)` method on an instance of the  `Notifier` class to ensure they are appropriately queued
    /// - Parameter notifiable: an object conforming to the `Notifiable` protocol
    static func display(_ notifiable: some Notifiable) async {
        switch notifiable {
        case let contextualError as ContextualError:
            await display(contextualError: contextualError)
//        case let reward as RewardType:
//            await display(reward: reward)
        case let message as NotificationMessage:
            await display(message: message)
        case let task as Task<Void, Never>:
            await (displayLoader(for: task))
        default:
            break
        }
    }
    
    // MARK: - Private methods
    
    private static func display(contextualError: ContextualError) async {
        switch contextualError.style {
        case .alert:
            await displayAlert(
                title: contextualError.title,
                message: contextualError.message
            )
        case .toast:
            if let message = contextualError.title ?? contextualError.message {
                await display(toast: .init(title: message, subtitle: nil, style: .error))
            }
        }
    }
    
//    private static func display(reward: RewardType) async {
//        switch reward {
//        case let .icon(iconName, iconId):
//            await display(toast: .init(
//                title: "New icon!",
//                subtitle: "Unlocked the \"\(iconName)\" icon",
//                style: .reward(iconId.rawValue)
//            )
//            )
//        }
//    }
    
    private static func display(message: NotificationMessage) async {
        let toast: Toast
        switch message {
        case let .success(title):
            toast = .init(title: title, subtitle: nil, style: .success)
        case let .detailedSuccess(title, subtitle):
            toast = .init(title: title, subtitle: subtitle, style: .success)
        case let .failure(title):
            toast = .init(title: title, subtitle: nil, style: .error)
        case let .detailedFailure(title, subtitle):
            toast = .init(title: title, subtitle: subtitle, style: .error)
        case .noInternet:
            toast = .init(title: "You're offline", subtitle: nil, style: .noInternet)
        }
        
        await display(toast: toast)
    }
    
    private static func displayLoader(for task: Task<Void, Never>) async {
        let toast = Toast(title: "Loading, please wait...", subtitle: nil, style: .loader)
        let toastView = await displayLoading(toast: toast)
        await task.value
        
        Task { @MainActor in
            removeToastFromHierarchy(toastView)
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
    
    private static func displayLoading(toast: Toast) async -> UIView? {
        await withCheckedContinuation { continuation in
            Task { @MainActor in
                guard let toastView = UIHostingController(rootView: toast).view,
                      let controller = UIApplication.shared.topMostViewController else {
                    continuation.resume(returning: nil)
                    return
                }
                
                configureLayout(of: toastView, in: controller)
                animateAppearance(of: toastView) {
                    continuation.resume(returning: toastView)
                }
            }
        }
    }
    
    private static func display(toast: Toast) async {
        await withCheckedContinuation { continuation in
            Task { @MainActor in
                guard let toastView = UIHostingController(rootView: toast).view,
                      let controller = UIApplication.shared.topMostViewController else {
                    continuation.resume()
                    return
                }
                
                configureLayout(of: toastView, in: controller)
                animateAppearance(of: toastView)
                
                let displayTime: TimeInterval = toast.subtitle == nil ? 2.5 : 5
                
                DispatchQueue.main.asyncAfter(deadline: .now() + displayTime) {
                    removeToastFromHierarchy(toastView) {
                        continuation.resume()
                    }
                }
            }
        }
    }
    
    private static func configureLayout(of toastView: UIView, in controller: UIViewController) {
        toastView.isUserInteractionEnabled = false
        toastView.translatesAutoresizingMaskIntoConstraints = false
        toastView.backgroundColor = .clear
        toastView.alpha = 0 // start with the toast invisible
        toastView.transform = .identity.translatedBy(x: .zero, y: -150) // start with the toast off the screen
        controller.view.addSubview(toastView)
        
        toastView.centerXAnchor.constraint(equalTo: controller.view.centerXAnchor).isActive = true
        toastView.topAnchor.constraint(equalTo: controller.view.topAnchor).isActive = true
        toastView.widthAnchor.constraint(equalTo: controller.view.widthAnchor).isActive = true
    }
    
    private static func animateAppearance(of toastView: UIView, completion: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.5,
            animations: {
                toastView.alpha = 1 // animate the toast to visible
                toastView.transform = .identity // animate the toast back to it's intended position
            },
            completion: { _ in
                completion?()
            }
        )
    }
    
    private static func removeToastFromHierarchy(_ toastView: UIView?, completion: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: 0.3,
            animations: {
                toastView?.alpha = 0
            },
            completion: { _ in
                toastView?.removeFromSuperview()
                completion?()
            }
        )
    }
    
    private static func present(_ viewController: UIViewController) {
        UIApplication.shared.topMostViewController?.present(viewController, animated: true)
    }
}

/// A simple toast view
/// - Note: This view is private as it should only be created via the notification process
private struct Toast: View {
    enum Style {
        case success
        case error
        case loader
        case noInternet
        case reward(String?)
    }
    
    let title: String
    let subtitle: String?
    let style: Style
    
    var body: some View {
        HStack(spacing: 8) {
            icon
            textViews
        }
        .multilineTextAlignment(subtitle == nil ? .center : .leading)
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(background)
        .padding(.horizontal, 8)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 6)
    }
    
    @ViewBuilder
    var textViews: some View {
        VStack(alignment: subtitle == nil ? .center : .leading, spacing: .zero) {
            Text(title)
                .font(.body.bold())
            if let subtitle {
                Text(subtitle)
                    .font(.footnote)
                    .opacity(0.7)
            }
        }
    }
    
    @ViewBuilder
    var background: some View {
        PaletteProvider.main.secondaryBackground
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.gray.opacity(0.2), lineWidth: 1))
    }
    
    @ViewBuilder
    var icon: some View {
        switch style {
        case .success:
            Image(systemName: Icons.success)
                .foregroundColor(.green)
        case .error:
            Image(systemName: Icons.failure)
                .foregroundColor(.red)
        case .noInternet:
            Image(systemName: Icons.noWifi)
                .foregroundColor(.red)
        case .loader:
            ProgressView()
        case let .reward(iconName):
            if let iconName, let iconImage = UIImage(named: iconName) {
                Image(uiImage: iconImage)
                    .resizable()
                    .frame(width: 30, height: 30) // limit the size of the asset since it's _huge_
            } else {
                Image(systemName: Icons.easterEgg)
                    .foregroundColor(.pink)
            }
        }
    }
}
