//
//  Onboarding View.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-08-15.
//

import Foundation
import SwiftUI

struct OnboardingView: View {
    
    enum OnboardingTab {
        case welcome, about, instances, addAccount
    }
    
    @Binding var selectedAccount: SavedAccount?
    
    @State var selectedTab: OnboardingTab = .welcome
    @State var hideNav: Bool = true
    
    var body: some View {
        TabView(selection: $selectedTab) {
            onboardingTab
                .tag(OnboardingTab.welcome)
            
            aboutTab
                .tag(OnboardingTab.about)
            
            instancesTab
                .tag(OnboardingTab.instances)
            
            AddSavedInstanceView(onboarding: true,
                                 currentAccount: $selectedAccount)
            .tag(OnboardingTab.addAccount)
        }
        .tabViewStyle(PageTabViewStyle())
    }
    
    @ViewBuilder
    var onboardingTab: some View {
        VStack(spacing: 40) {
            Text("Welcome to Mlem!")
                .bold()
            
            Image("logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 120)
                .clipShape(Circle())
            
            VStack {
                Button {
                    withAnimation {
                        selectedTab = .about
                    }
                } label: {
                    Text("I'm new here")
                        .padding(.vertical, 5)
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal)
                .buttonStyle(.borderedProminent)
                
                Button {
                    withAnimation {
                        selectedTab = .addAccount
                    }
                } label: {
                    Text("I have a Lemmy account")
                        .padding(.vertical, 5)
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal)
                .buttonStyle(.bordered)
            }
        }
        .frame(maxHeight: .infinity)
    }
    
    @ViewBuilder
    var aboutTab: some View {
        ScrollView {
            VStack(spacing: 40) {
                Text("What is Lemmy?")
                    .bold()
                
                // swiftlint:disable line_length
                Text(
                """
                Lemmy is a social media platform where content is organized into topical forums (communities) and sorted by user votes. It's federated, which means that, instead of a single corporation hosting all the content on a single server, it's instead hosted by a network of independently operated servers called **instances**.
                
                You make an account on one instance, and it lets you view and interact with content from every other instance that your home instance federates with.
                """)
                
                VStack(spacing: 0) {
                    
                    Divider()
                    
                    CollapsibleTextItem(titleText: "About Lemmy",
                                        bodyText:
                                        """
                                        Lemmy, like Mlem, is a free and open source project. There's no corporate interest behind it; it's a donation-driven project built and run by and for the users to create a platform that can't be destroyed or manipulated on the whim of a small ownership group.
                                        
                                        Lemmy is a link aggregator: it is organized into user-moderated communities where people can post links, pictures, and plain text, and discuss them in a threaded comments section. You can subscribe to communities that fit your interests to create a custom feed of just the content that matters to you.
                                        """)
                    
                    Divider()
                    
                    CollapsibleTextItem(titleText: "About Instances and Federation",
                                        bodyText:
                                        """
                                        Instances are independently owned and operated servers running the Lemmy software. Anybody can run an instance, which means that if an instance admin starts abusing their power, you can just hop to a new one or even make your own.
                                        
                                        Instances can choose to federate with other instances, allowing the users of one instance to view and interact with content from any of the federated instances as if it were hosted on their home instance. If this seems strange, just think of it like email: even though alice@abc.com has an email address from one provider and bob@xyz.net has an email from another, they can still send emails to each other because their providers are using a common communication standard.
                                        """)
                    
                    Divider()
                }
                // swiftlint:enable line_length
                
                Spacer()
                
                Button {
                    withAnimation {
                        selectedTab = .instances
                    }
                } label: {
                    Text("Next")
                        .padding(5)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                
                // add a little space for the tab selector
                Spacer()
                    .frame(height: 20)
            }
            .padding()
        }
    }
    
    var instancesTab: some View {
        Text("Instances")
            .bold()
    }
}
