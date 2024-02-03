//
//  TabBarVisibility.swift
//  Mlem
//
//  Created by Bosco Ho on 2024-02-02.
//

import Foundation
import SwiftUI

final class TabBarVisibility: ObservableObject {
    @Published var visibility: Visibility = .automatic
}
