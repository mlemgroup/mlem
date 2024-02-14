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
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .resizable()
                .scaledToFill()
                .frame(width: 25, height: 25)
                .foregroundStyle(color)
            
            Text(text)
                .fontWeight(.semibold)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(15)
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: AppConstants.largeItemCornerRadius)
                .fill(.white)
        }
    }
}
