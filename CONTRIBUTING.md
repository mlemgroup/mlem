Hello!

If you're reading this, you probably want to contribute to Mlem. Welcome! We're happy to have you on board. You may wish to join our [Matrix room](https://matrix.to/#/#mlemappspace:matrix.org) if you haven't already.

## Getting Started

### Cloning and Building

Mlem is built using the latest stable version of Xcode. Install it from the App Store or the Apple Developer downloads page, along with the command line tools.

Mlem employs submodules to integrate generated code into the main project. To clone the project, execute the following:

`git clone git@github.com:mlemgroup/mlem.git --recurse-submodules`

If you encounter missing `Api...` types when building, this can usually be resolved by updating the submodules:

`git submodule update --recursive`

### Additional Tools

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

### Claiming Issues

1. Go to our [project board](https://github.com/orgs/mlemgroup/projects/1/views/1).
2. Find an unassigned issue under the "Todo" section that you'd like to work on.
3. Comment that you would like to work on the issue. If the issue doesn't conflict with any in-flight work, a maintainer will assign it to you.
4. Fork the repository (see Cloning and Building) and develop the changes on your fork. It is important that you create your development branch using the upstream `dev` branch as the source, not the `master` branch.
5. Open a Pull Request for your changes.

## Merge Protocol

When your code is approved, it can be merged into the `dev` branch by a member of the development team. If you need to tinker with your changes post-approval, please make a comment that you are doing so. PRs that sit approved for more than 12 hours with no input from the dev may be merged if they are blocking other work.

## Coding Conventions

### General Principles

- Files should be named according to the following patterns:
  - All files: `TitleCase`. If the file contains extensions, it should be named `BaseEntity+Extensions`.
  - `View` files: file name must end in `View` (e.g., `FeedsView`)
- If you can reuse code, do. Prefer abstracting common components to a generic struct and common logic to a generic function.

### Views

- Only one `View` struct should be defined per file
- Within reason, any complex of views that renders a single component of a larger view should be placed in a descriptively named function, computed property or `@ViewBuilder` variable beneath the body of the View. This keeps pyramids from piling up and makes our accessibility experts' work easier.
- All `View` structs should be organized according to the following template:

```
struct SomeView: View {
  @AppStorage values
  @Setting values
  @Environment entities
  @Binding variables
  @State variables
  @Namespace variables
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

- If the view has modifiers that are attached to the entire body, place the view definition in `content` and attach these modifiers to it in `body` (see `ContentView.swift` for an example).
- Prefer `var helper: some View` to `func helper() -> some View` unless the helper view takes in parameters.
- Helper views should always appear lower in the file than the view they help.

### Global Objects

There are several objects (e.g., `AppState`) that need to be available anywhere in the app. Normally this is handled with `@Environment`, but this is not available outside of the context of a `View`. To address this, globals that need to be available outside of a `View` define a `static var main: GlobalObject = .init()`, allowing them to be referenced as `GlobalObject.main`. This definition should be placed immediately above the initializer.

This pattern should be used only where necessary, and should not be blindly applied to any global object. Likewise, if possible, these objects should be referenced via `@Environment(GlobalObject.self) var globalObject`; the static singleton should be considered a last resort.

### Colors

Colors are managed using our custom `Theming` package, which enables color themes. The following conventions apply:

- Avoid referencing `Color` directly; always use a `Themed` color. These can be referenced the same way normal colors are referenced (e.g., `.fill(.themedSecondary)`)
- Prefer semantic over literal colors (e.g., `.themedUpvote` over `.blue`).

The `Theming` package requires the environmental `Palette` object. In certain rare cases, this is not implicitly accessible; if absolutely necessary, a themed color can be generated by explicitly passing in a palette: 

`ThemedColor.<color>.resolve(with: palette)`

Avoid using this invocation unless absolutely necessary.

### Main Actor

To run code on the main actor, use either:

- `@MainActor` annotated method
- `Task { @MainActor in ... }`

If you need to execute code after a delay, use `DispatchQueue.main.asyncAfter`.

### Hashable

Explicit `hash` functions for `enum`s should, in the absence of associated values, use a descriptive string to identify each case rather than an integer.
