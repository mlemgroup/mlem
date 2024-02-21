//
//  ReadCheck.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-08-02.
//

import Foundation
import SwiftUI

struct ReadCheck: View {
    var body: some View {
        Image(systemName: Icons.success)
            .resizable()
            .scaledToFit()
            .frame(width: 10, height: 10)
            .foregroundColor(.secondary)
    }
}
