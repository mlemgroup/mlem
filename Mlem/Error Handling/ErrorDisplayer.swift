// 
//  ErrorDisplayer.swift
//  Mlem
//
//  Created by mormaer on 19/07/2023.
//  
//

import AlertToast
import SwiftUI
import UIKit

class ErrorDisplayer {
    
    static func displayAlert(title: String?, message: String?) {
        guard title?.isEmpty == false || message?.isEmpty == false else {
            // if we have nothing to display... don't display it 🙃
            return
        }
        
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(.init(title: "OK", style: .cancel))
        present(alert)
    }
    
    static func displayToast(title: String) {
        let toast = AlertToast(
            displayMode: .alert,
            type: .error(.red),
            title: title
        )
        
        if let toastView = UIHostingController(rootView: toast).view,
           let controller = UIApplication.shared.topMostViewController {
            toastView.translatesAutoresizingMaskIntoConstraints = false
            toastView.alpha = 0
            controller.view.addSubview(toastView)
            toastView.centerXAnchor.constraint(equalTo: controller.view.centerXAnchor).isActive = true
            toastView.centerYAnchor.constraint(equalTo: controller.view.centerYAnchor).isActive = true
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
                    }
                )
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
