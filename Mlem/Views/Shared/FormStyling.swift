//
//  FormStyling.swift
//  Mlem
//
//  Created by Sjmarf on 17/09/2023.
//

import SwiftUI

struct FormToggle: View {
   let title: String
   let iconName: String
   @Binding var isOn: Bool
   
   var body: some View {
       Toggle(isOn: $isOn) {
           FormLabel(title: title, iconName: iconName)
       }
       .padding(.horizontal, 16)
       .padding(.vertical, 10)
   }
}

struct FormLabel: View {
    let title: String
    let iconName: String
    var imageScale: Image.Scale = .large

    var body: some View {
       Label {
           Text(title)
       } icon: {
           Image(systemName: iconName)
               .imageScale(imageScale)
               .foregroundStyle(.blue)
               .frame(width: 30, height: 30)
               .padding(.trailing, 5)
       }
    }
}

struct FormNavigationLink<Destination: View, Label: View>: View {
   
   let destination: Destination
   let label: Label
   
   init(@ViewBuilder _ destination: () -> Destination, @ViewBuilder label: () -> Label) {
       self.destination = destination()
       self.label = label()
   }
   
   var body: some View {
       NavigationLink(destination: destination) {
           HStack {
               label
               Spacer()
               Image(systemName: "chevron.right")
                   .foregroundStyle(.secondary)
                   .fontWeight(.semibold)
                   .imageScale(.small)
           }
           .contentShape(Rectangle())
       }
       .buttonStyle(.plain)
       .padding(.horizontal, 16)
       .padding(.vertical, 10)
   }
}
