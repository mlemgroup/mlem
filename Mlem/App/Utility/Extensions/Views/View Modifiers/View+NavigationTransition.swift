//
//  View+NavigationTransition.swift
//  Mlem
//
//  Created by Sjmarf on 29/08/2024.
//

import SwiftUI

extension View {
    func navigationTransition_(sourceID: any Hashable, in namespace: Namespace.ID?) -> some View {
        // The code below requires Xcode 16, and is intentionally left commented for now
        // until we upgrade to Xcode 16.
        self
//        Group {
//            if #available(iOS 18.0, *), let namespace {
//                self.navigationTransition(.zoom(sourceID: sourceID, in: namespace))
//            } else {
//                self
//            }
//        }
    }
    
    func matchedTransitionSource_(id: some Hashable, in namespace: Namespace.ID) -> some View {
        // The code below requires Xcode 16, and is intentionally left commented for now
        // until we upgrade to Xcode 16.
        self
//        Group {
//            if #available(iOS 18.0, *) {
//                self.matchedTransitionSource(id: id, in: namespace, configuration: { config in
//                    config.clipShape(.rect(cornerRadius: Constants.main.standardSpacing))
//                })
//            } else {
//                self
//            }
//        }
    }
}
