Hello!

If you're reading this, you probably want to contribute to Mlem. Welcome! We're happy to have you on board. You may wish to join our [Matrix room](https://matrix.to/#/#mlemappspace:matrix.org) if you haven't already.

## Prerequesites

This project makes use of the following tools:

- Xcode 15
- [SwiftLint](https://github.com/realm/SwiftLint#swiftlint). This runs as part of the Xcode build phases.
- [Swiftformat](https://github.com/nicklockwood/SwiftFormat#what-is-this). This runs as a pre-commit hook.

In order to benefit please ensure you have [Homebrew](https://brew.sh) installed on your system and then run the following commands inside the project directory:

```
cd /path/to/this/repo
brew update
brew bundle
git config --local --add core.hooksPath .git-hooks
```

With these steps completed each time you build your code will be linted, and each time you commit your code will be formatted.

## Getting started

To avoid having multiple in-flight tasks working on the same part of the codebase, we have a set procedure for claiming and performing work. If you don't follow it, your PR will _probably_ be rejected (unless it's really _that_ good).

1. Go to our [project board](https://github.com/orgs/mlemgroup/projects/1/views/1).
2. Find an unassigned issue under the "Todo" section that you'd like to work on.
3. Comment that you would like the issue to be assigned to you.
4. Wait for the task to be assigned to you! This is very important for avoiding merge conflicts.
5. Fork the repository (if you haven't already) and develop the changes on your fork. It is important that you create your development branch using the upstream `dev` branch as the source, not the `master` branch.
6. Open a Pull Request for your changes. Your PR should be able to merge with no conflicts - if conflicting changes are made to the `dev` branch before your PR is merged, you will have to resolve the conflicts or rebase your changes.

## Merge Protocol

When your code is approved, it can be merged into the `dev` branch by a member of the development team. If you need to tinker with your changes post-approval, please make a comment that you are doing so. PRs that sit approved for more than 12 hours with no input from the dev may be merged if they are blocking other work.

## Conventions

Please develop according to the following principles:

- One View per file. A file containing a View struct must end in "View". We're yet to decide on an official naming scheme for files - feel free to offer your thoughts [here](https://github.com/mlemgroup/mlem/issues/55).
- Within reason, any complex of views that renders a single component of a larger view should be placed in a descriptively named function, computed property or `@ViewBuilder` variable beneath the body of the View. This keeps pyramids from piling up and makes our accessibility experts' work easier.
- If you can reuse code, do. Prefer abstracting common components to a generic struct and common logic to a generic function.

## View Structure

All `View` structs should be organized according to the following template:

```
struct SomeView: View {
  @AppStorage values
  @Environment entities
  @Binding variables
  @State variables
  Normal variables
  Computed properties

  // if necessary
  init() { ... }

  var body: some View { ... }

  // if necessary
  var content: some View { ... }

  Helper views
}
```

Further notes:

- If the view has modifiers that are attached to the entire body, place the view definition in `content` and attach these modifiers to it in `body` (see `ContentView.swift` for an example).
- Prefer `var helper: some View` to `func helper() -> some View` unless the helper view takes in parameters.
- Helper views should always appear lower in the file than the view they help.

## Global Objects

There are several objects (e.g., `AppState`) that need to be available anywhere in the app. Normally this is handled with `@Environment`, but this is not available outside of the context of a `View`. To address this, globals that need to be availalbe outside of a `View` define a `static var main: GlobalObject = .init()`, allowing them to be referenced as `GlobalObject.main`.

This pattern should be used only where necessary, and should not be blindly applied to any global object. Likewise, if possible, these objects should be referenced via `@Environment(GlobalObject.self) var globalObject`; the static singleton should be considered a last resort.

## Colors

Colors are managed using the globally available `Palette` object, which enables color themes. The following conventions apply:

- Avoid referencing `Color` directly; always use a `Palette` color.
- Prefer semantic over literal colors (e.g., `.upvote` over `.blue`).

## Testing

We operate a Lemmy Instance at https://test-mlem.jo.wtf/ which you may use for testing purposes. Please note that, as of 2024-05-10, it is running Lemmy v17, which is no longer used by any major Lemmy instance and thus we do not bother maintaining compatibility for. You may wish to use a local Lemmy instance instead.
