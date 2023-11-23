# Navigation

Date Created: Nov. 23, 2023

### Tab Bar Navigation

**Initial Setup: Tab Root View**
1. Add the following properties to your tab's root view:
```
@StateObject private var tabNavigationPath: AnyNavigationPath<AppRoute> = .init()
@StateObject private var navigation: Navigation = .init()
```
2. In your tab's root view (this should also be where a NavigationStack is declared), pass in an `AnyNavigationPath<Path>` binding as that stack's path.
3. On the NavigationStack, pass in the following environment values:
```
.environment(\.navigationPathWithRoutes, $tabNavigationPath.path)
.environmentObject(navigation)
```
4. Pass in the navigation path to `handleLemmyLinkResolution(...)`:
```
.handleLemmyLinkResolution(navigationPath: .constant(tabNavigationPath))
```
5. On the outer-most view inside your NavigationStack, do the following:
- 5a. Pass in the following environment values:
```
.environmentObject(tabNavigationPath)
```
- 5b. Apply the following view modifiers:
```
.tabBarNavigationEnabled(.settings, navigation)
.hoistNavigation(
    dismiss: dismiss,
    auxiliaryAction: {
        withAnimation {
            proxy.scrollTo(scrollToTop, anchor: .bottom)
        }
        return true
    }
)
```

And now you're done configuring the tab's root view! See `Tap to Dismiss` section to enable/customize tab navigation behaviour.

**Tap to Dismiss: Enabling Behaviour**
On each view, including the tab's 'root view:
1. Add the `@Environment(\.dismiss)` action to view.
2. On the outer-most view in that view's 'body, apply the `.hoistNavigation(dismiss:)` view modifier, optionally passing in an `auxiliaryAction`. For example:
```
.hoistNavigation(
    dismiss: dismiss,
    auxiliaryAction: {
    /// Example auxiliary action: Scroll to top before performing the dismiss action.
        withAnimation {
            proxy.scrollTo(scrollToTop, anchor: .bottom)
        }
        return true
    }
)
```
3. That's it =)

**Tab Navigation: Auxiliary Action**
Tab navigation is configured such that the auxiliary action is always performed until no more actions can be found. After which, the navigator will perform the dismiss action.
- In the auxiliary action closure, return `true` to indicate that all auxiliary actions have been performed.
- You may wish to perform multiple auxiliary actions in a view. For example, you may wish to have the `ExpandedPost` view travel up each parent comment when user taps on tab. In this scenario, continue returning `false` until that view reaches the top. 

### Implementation Notes
Q: Why not have a view modifier that declares the dismiss action, instead of passing it in to the hoisting function?
A: Declaring the dismiss env var inside a view modifier causes SwiftUI to enter an infinite loop. [2023.11]
