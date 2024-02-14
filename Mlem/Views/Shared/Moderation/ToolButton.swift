//
//  ToolButton.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-13.
//

import Foundation
import SwiftUI

struct ToolButton: View {
    let text: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack {
            Spacer()
            Image(systemName: icon)
                .resizable()
                .scaledToFill()
                .frame(width: 40, height: 40)
            Spacer()
            
            Text(text)
                .fontWeight(.semibold)
                .lineLimit(1)
        }
        .padding(.vertical, AppConstants.standardSpacing)
        .foregroundColor(Color(uiColor: .systemBackground))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .aspectRatio(1, contentMode: .fill)
        .background {
            RoundedRectangle(cornerRadius: AppConstants.largeItemCornerRadius)
                .fill(color.gradient)
        }
    }
}
