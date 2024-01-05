#  Generic Trackers

This group contains a set of generic classes intended to back feed views. This document is intended as a high-level overview of the design principles and a quickstart guide for using the trackers; for detailed information, refer to the inline documentation.

## Tracker Operation

The heart of a tracker is very simple: an array of items and a method for loading more.

## Tracker Types

There are three types of trackers: `StandardTracker`, `ChildTracker`, and `ParentTracker`. `CoreTracker` holds shared logic between these trackers, and should **not** be used!

`StandardTracker` should be used for feeds with a single item type (e.g., the main posts feed).

`ChildTracker` and `ParentTracker` should always be used in conjunction! They handle feeds with mixed item types (e.g., the inbox feed). `ChildTracker` is a modified version of `StandardTracker`, and can safely be used to drive its own feed in addition to the mixed feed (as is done in the inbox). `ParentTracker` offers a similar interface, but functions radically differently: it relies on its `ChildTracker`s to load items!
