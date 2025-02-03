//
//  FilterViolationWarning.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-02-03.
//

import SwiftUI

struct FilterViolationWarning: View {
    @Environment(Palette.self) var palette
    
    let failingText: String
    let isPost: Bool
    
    var context: LocalizedStringResource {
        isPost ? "Posts containing " : "Comments containing "
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.main.standardSpacing) {
            (Text(Image(systemName: Icons.warning)) + Text(" Filter violation"))
                .foregroundStyle(palette.warning)
                .padding(Constants.main.standardSpacing)
                .padding(.horizontal, Constants.main.halfSpacing)
                .background {
                    Capsule()
                        .fill(palette.warning.opacity(0.2))
                        .stroke(palette.warning)
                }
            
            Text(context) +
            Text(failingText).fontWeight(.semibold) +
            Text(" are forbidden by this instance's filters.")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
