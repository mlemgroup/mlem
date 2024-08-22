//
//  AppState+Transition.swift
//  Mlem
//
//  Created by Sjmarf on 05/06/2024.
//

import SwiftUI

extension AppState {
    func transition(_ account: any Account) {
        Task { @MainActor in
            // Close all sheets
            NavigationModel.main.layers = []
            
            let transition = TransitionView(account: account)
            guard let transitionView = UIHostingController(rootView: transition).view,
                  let window = UIApplication.shared.firstKeyWindow else {
                return
            }
            
            transitionView.alpha = 0
            window.addSubview(transitionView)
            UIView.animate(withDuration: 0.15) {
                transitionView.alpha = 1
            }
            
            transitionView.translatesAutoresizingMaskIntoConstraints = false
            transitionView.heightAnchor.constraint(equalTo: window.heightAnchor).isActive = true
            transitionView.widthAnchor.constraint(equalTo: window.widthAnchor).isActive = true
                    
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                UIView.animate(withDuration: 0.3) {
                    transitionView.alpha = 0
                } completion: { _ in
                    transitionView.removeFromSuperview()
                }
            }
        }
    }
}
