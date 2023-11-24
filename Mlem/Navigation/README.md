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
3. On the NavigationStack itself, pass in the following environment values:
```
.environment(\.navigationPathWithRoutes, $tabNavigationPath.path)
.environmentObject(navigation)
```
4. Pass in the navigation path to `handleLemmyLinkResolution(...)`:
```
.handleLemmyLinkResolution(navigationPath: .constant(tabNavigationPath))
```
5. On the outer-most view *inside* your NavigationStack, do the following:
- 5a. Pass in the following environment values:
```
.environmentObject(tabNavigationPath)
```
- 5b. On that same outer-most view, apply the following view modifiers:
```
.tabBarNavigationEnabled(.settings, navigation)
AND either of the following (read the function's documentation for explanation):
.hoistNavigation(
    _ primaryAction: .dismiss,
    auxiliaryAction: nil
)
OR:
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
6. And now you're done configuring the tab's root view! See `Tap to Dismiss` section to enable/customize tab navigation behaviour.

**Tap to Dismiss: Enabling Behaviour**
On each view, including the tab's 'root view:
1. Add the `@Environment(\.dismiss)` action to view.
2. On the outer-most view in that view's 'body, apply the `.hoistNavigation(...)` view modifier, optionally passing in an `auxiliaryAction`. For example:
```
.hoistNavigation(
    _ primaryAction: .dismiss,
    auxiliaryAction: nil
)
OR:
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

**Tab Navigation: Scroll to Top**
For ease of use, you may wish to declare a `ScrollViewReader` near or at the top of your tab's root view, and then propagate that proxy via the `@Environment(\.scrollViewProxy)` environment value. If you do so, that reader must be wrapped outside of NavigationStack, otherwise environment values won't propagate to views pushed onto the stack. 

## FAQ
Q: Why can't I rapidly tap the tab bar to trigger multiple navigation actions at once?
A: Technically, this is possible by programmatically manipulating a navigation path, but doing so will cause SwiftUI's navigation state to become corrupt (on iOS 16/17) such that the navigation data state and UI state become desynced. Our workaround uses the system environment's dismiss action to perform dismissal, which correctly coordinates the data/UI states, but that dismiss action requires a view to become fully dismissed before the previous view's dismiss action can be triggered.
