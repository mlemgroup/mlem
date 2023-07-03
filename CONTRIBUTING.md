==== CONTRIBUTION GUIDELINES ====

Hello!

If you're reading this, you probably want to contribute to Mlem. Welcome! We're happy to have you on board.

To avoid having multiple in-flight tasks working on the same part of the codebase, we have a set procedure for claiming and performing work. If you don't follow it, your PR will *probably* be rejected (unless it's really *that* good).

1. Go to our project board and find something in the "todo" section
2. Comment that you want to handle that task
3. Wait for the task to be assigned to you! This is very important for avoiding merge conflicts.
4. Fork the repository and develop the change on your fork
5. Open a PR for the task. The description should clearly reference the issue that you are addressing, and your PR should be able to merge with no conflicts--if the master branch changes before your PR is merged, you should either rebase or merge so that your fork can be merged cleanly.

In addition, please develop according to the following principles:
- One named View struct per file. The name of the file should describe the view (e.g., "Large Post View,"), and the name of the struct should be match the name of the file but with spaces removed (e.g., "LargePostView"). Every file containing a View struct must end in "View."
- All View-specific functions should live in an extension to that view, located in the same directory as the view. This file should be named "<View Name> Logic" (e.g., "Large Post View Logic")
- Within reason, any complex of views that renders a single component of a larger view should be placed in a descriptively named let, func, or @ViewBuilder var beneath the body of the View. This keeps pyramids from piling up and makes our accessibility expert's work easier.
- If you can reuse code, do. Prefer abstracting common components to a generic struct and common logic to a generic function.

==== MERGE PROTOCOL ====

We follow the principle that devs should merge their own code. This ensures that nothing enters the codebase without it being completely ready in both the eyes of the reviewers and the developer, thereby cutting down on bad code in master and tack-on PRs.

When your code is approved, if you have permission to do so, you are responsible for clicking that beautiful "squash and merge." If you need to tinker with it post-approval, please make a comment that you are doing so. PRs that sit approved for more than 12 hours with no input from the dev may be merged if they are blocking other work.
