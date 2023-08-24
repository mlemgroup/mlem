//
//  Logo View.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-08-21.
//

import Foundation
import SwiftUI

struct LogoView: View {
    var body: some View {
        Image("logo")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 120)
            .clipShape(Circle())
    }
}
