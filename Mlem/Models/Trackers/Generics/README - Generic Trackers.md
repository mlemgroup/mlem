#  Generic Trackers

This group contains a set of generic classes intended to back feed views. This document is intended as a high-level overview of the design principles and a quickstart guide for using the trackers; for detailed information, refer to the inline documentation.

## Tracker Operation

The heart of a tracker is very simple: an array of items and a method for loading more.

Note that tracker models must be classes, not structs, as much of the logic is built on the assumption that items will be passed by reference.

## Tracker Types

There are three types of trackers: `StandardTracker`, `ChildTracker`, and `ParentTracker`. `CoreTracker` holds shared logic between these trackers, and should **not** be used!

`StandardTracker` should be used for feeds with a single item type (e.g., the main posts feed). To use it, simply create an inheriting class 

`ChildTracker` and `ParentTracker` should always be used in conjunction! They handle feeds with mixed item types (e.g., the inbox feed). `ChildTracker` is a modified version of `StandardTracker`, and can safely be used to drive its own feed in addition to the mixed feed (as is done in the inbox). `ParentTracker` offers a similar interface, but functions radically differently: it relies on its `ChildTracker`s to load items!

To create a multi-tracker, first create a protocol `MyTrackerItem` conforming to `TrackerItem` and an enum `AnyMyTrackerItem` conforming to `MyTrackerItem`. For each child type, create an extension conforming it to `MyTrackerItem` and add a case to `AnyMyTrackerItem` for that type with the associated value of the content type. With that done, create one child tracker for each child type (`class FooTracker: ChildTracker<FooModel, AnyMyTrackerItem>`) and a single parent tracker inheriting from `ParentTracker` (`class MyTracker: ParentTracker<AnyMyTrackerItem`).

To instantiate a multi-tracker, first instantiate each child tracker, then pass them in to the parent tracker at its initialization.

See `InboxTracker` and its related types for an example, as that tracker contains very little custom logic.
