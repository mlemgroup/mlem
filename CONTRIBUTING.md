Hello!

If you're reading this, you probably want to contribute to Mlem. Welcome! We're happy to have you on board. You may wish to join our [Matrix room](https://matrix.to/#/#mlemappspace:matrix.org) if you haven't already.

## Prerequesites

This project makes use of [SwiftLint](https://github.com/realm/SwiftLint#swiftlint). This runs as part of the Xcode build phases.

In order to benefit please ensure you have [Homebrew](https://brew.sh) installed on your system and then run the following command to install Swiftlint:

`brew install swiftlint`

## Getting started

To avoid having multiple in-flight tasks working on the same part of the codebase, we have a set procedure for claiming and performing work. If you don't follow it, your PR will *probably* be rejected (unless it's really *that* good).

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

## Testing

We operate a Lemmy Instance at https://test-mlem.jo.wtf/ which you may use for testing purposes.
