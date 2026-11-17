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

## AI 

### Policy

Mlem doesn't restrict how contributions are made. We do, however, enforce high standards of quality and intentionality. Regardless of how a pull request is written, it must adhere to the following requirements:

- Every line is deliberate; every line can be justified. Pull requests should be clean, carefully engineered, and free of the verbosity typical of unfiltered AI output. We expect any contributor to be able to explain, in their own words, why their contribution is structured as it is and what the intent behind each line is. New contributors, or contributors unfamiliar with the technologies we use, should not feel intimidated by this requirement! If you want to contribute but are unsure how to proceed, please reach out on the dev Matrix for guidance--we are always happy to help, and will not review beginner mistakes unkindly.
- All creative assets (app icons, design documents, themes, custom glyphs, etc.) must be fully human-made.
- All writing (in-app text, pull request documentation and comments, and public communication from the maintainers) must be human-generated. An exception is made for translations, which are nevertheless held to the same standard as code: do not submit generated translations in a language you do not speak or that you have not carefully reviewed.
- Contributors must not spam low-quality pull requests. Good code takes time to build, with or without AI, and all code takes time to review. This requirement is largely a judgment call on the maintainers’ part, but if we are concerned that a particular contributor is submitting too much volume with not enough quality, we will communicate as much. As a rule of thumb, if you write all your code by hand, you will never fall afoul of this requirement.


### Philosophy

We value thoughtfully designed code over feature velocity, and pride ourselves on deliberate human design. It is therefore tempting to issue a blanket rejection of all contributions built by or with AI. After careful deliberation, we have elected not to implement such a policy for a number of reasons. Chief among these is the priority we place on transparency and good faith communication with our community. A blanket AI ban could reasonably be interpreted as an affirmation that Mlem is fully free of AI-generated code, but we cannot guarantee that either now or in the future. AI code, especially in small changes, cannot always be identified; we receive many contributions from unknown developers, have no practical way to determine whether every line of them is typed by hand, and do not believe it is a worthwhile use of maintainer time to attempt to make that judgment call for every new pull request. Likewise, our app depends on a host of other libraries, many of which in turn have dependencies, and the herculean task of vetting and re-vetting these dependencies is simply impractical. We moreover do not want to burden contributors with ethical quandaries. Contributors should not need to worry about whether actions such as copy/pasting syntax from a search engine’s AI summary (or from an article that could have been AI generated), using AI tools to orient themselves within the codebase, or submitting their changes to AI for review before opening a pull request are violations of our policies.

Mlem is, and always will be, a project written by humans for humans to communicate with other humans. What that means for a software project in the context of modern AI is a complex question, the nuances of which we are only beginning to explore. This policy is not meant to answer it outright or to serve as a manifesto on AI. It is an attempt, based on the core principles that make us passionate about Mlem, to preserve the project’s spirit in a way that is reasonable, enforceable, and healthy long-term. If you feel strongly about this policy, we are always happy to chat on our community, Matrix, or Lemmy DMs.

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
