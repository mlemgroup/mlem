This is my initial idea of how we could create a long-term solution to the modelling problem. It uses iOS 17's `@Observable`. I've only implemented the definitions so far as a proof-of-concept - the app doesn't actually *use* the proposed system on this branch yet. Let me know what you think.

# How it works

## Tiers

Instead of there being a single `CommunityModel`, there are three separate "tiers" of the model. Each tier is an `@Observable` class.

- `CommunityTier1` can be created from an `APICommunity`, and has all of the same properties as `APICommunity`.
- `CommunityTier2` can be created from an `APICommunityView`. It stores an instance of `CommunityTier1` as a property, and also stores `APICommunityView`-exclusive data such as `subscribed` and `blocked`.
- `CommunityTier3` can be created from a `GetCommunityResponse`. It stores an instance of `CommunityTier2` as a property, and also stores `GetCommunityResponse`-exclusive data such as an array of moderators.

## Tier Protocols

`CommunityTier1` and `CommunityTier2` have a corresponding protocol that describes their properties. These protocols are called `CommunityTier1Providing` and `CommunityTier2Providing` respectively. 

Each tier of community model conforms to the protocols of all of the tiers below it. They do this by using computed properties to forward the properties of an instance of the preceding tier.

```swift
@Observable
final class CommunityTier2: CommunityTier2Providing {
    private let community1: CommunityTier1
    
    var name: String { community1.name }
    var diplayName: String? { community1.displayName }
    
    // etc ...
}
```

If a view needs access to a specific tier of community model or higher, you can use `any ...`. An example would be `CommunityLabelView`, which needs to know the name of a community. The name of a community is stored within `CommunityTier1`, so we need to provide `CommunityLabelView` with a community of tier 1 or higher.

```swift
struct CommunityLabelView: View {
    let community: any CommunityTier1Providing

    var body: some View {
        Text(community.name)
    }
}
```

If we want to show additional information for higher tiers, we can use `as?` to test for conformance to a higher protocol.

```swift
struct CommunityLabelView: View {
    let community: any CommunityTier1Providing

    var body: some View {
        HStack {
            Text(community.name)
            if let community = community as? any CommunityTier2Providing, community.subscribed {
                Image(systemName: Icons.subscribed)
            }
        }
    }
}
```

## Caching System

Each tier of community model has a separate `ContentCache` instance stored as a static property of the model. The `ContentCache` stores weak references to all of the community model instances. When we need to turn an API type into a community model, we can use the `createModel(from: )` method of the relevant `ContentCache`. If an instance of the community model exists elsewhere already, `createModel` will return that existing instance. Otherwise, it will create a new instance from the API type we provide, and cache it for next time.

```swift
let response = try await apiClient.loadCommunityDetails(id: communityId)
communityModel = CommunityTier3.createModel(from: response)
```

Using a protocol, I've implemented some syntax to make this less verbose. API types that can be converted to a community model have a `toModel` function, which calls `createModel` and returns the result:

```swift
let response = try await apiClient.loadCommunityDetails(id: communityId)
communityModel = response.toModel()
```

Each tier of community model wraps an instance of the tier below it. When an instance of a community model is created, it calls `createModel` for the next tier down.


### Why is this needed?

This caching system eliminates the need to pass trackers between views to keep community models up-to-date. If we modify a property of a community model from the frontend, the change will be reflected everywhere in the app without doing any extra work on the frontend.

An example of this:

- You enter a feed.
- You navigate to a community via the community link on the post.
- You subscribe to that community.
- You tap "back" to return to the feed.

Previously, the subscribed indicator on the post's community link would not appear when you do this. This is because `CommunityModel` was previously a value type, so would need to be updated induvidually everywhere to implement the correct behaviour. Using a caching class-based system, we don't have to do this to get the behaviour we want.

## Upgrading tiers

If you want to upgrade a tier to a higher level, you can use the `upgrade()` method. This method sends a `GetCommunityRequest` and returns an instance of `CommunityTier3` that it creates from the response. This is useful in places like `CommunityFeedView`, where we need to expand whatever community model we are provided with to contain all of the needed information. 

```swift
struct CommunityFeedView: View {
    @State var community: any CommunityTier1Providing

    var body: some View {
        content
            .task {
                self.community = try await community.upgrade()
            }
    }
}
```

# Why have tiers? Why not just have a single class with optional properties, like we do now?

A potential option would be to have a single-class system closer to what we have now. Instead of creating a higher tier of model when more data becomes available, we could simply populate the properties of the existing `CommunityModel`. This would lead to much less middleware code. However, it has a couple of drawbacks:

### It could lead to extra data being stored unecessarily

Consider the following scenario:

- The user enters a feed. A new `CommunityModel` would be created to represent each community.
- The user navigates to a community. A `GetCommunityRequest` is sent, and the `nil` properties of the corresponding `CommunityModel` are populated with the incoming data. A new `UserModel` is created for each moderator of the community, and stored inside of the `CommunityModel`.
- The user clicks on the "moderators" tab, and navigates to the profile of one of the moderators.
- A `GetPersonDetailsRequest` is sent, and the `nil` properties of the corresponding `UserModel` are populated with the incoming data. a new `CommunityModel` is created for each community that the user moderates.
- The user taps "back" twice to return to the feeds page. 

After doing this, we are now storing way too much unnecessary data. The intial `CommunityModel` now stores a list of all of it's moderators. One of those `UserModel` instances also stores a list of `CommunityModel` instances (the communities that the user moderates). This datac will continue to be kept in memory until the user leaves the feed. This is unideal.

One way of resolving this would be to set the `moderators` array to `nil` again when the user leaves the `CommunityFeedView` via a `.onDisppear` modifier. However, this solution isn't perfect - if the user has the community open in two different tabs (unlikely, but possible) they would delete the data still needed by the second tab when they navigate away from the community on the first tab.

This could of course be fixed using a reference-counting system... but that requires extra frontend logic, which I'd rather avoid.

### It means we have to unwrap optionals everywhere

With a single `CommunityModel`, showing its info would look like this:

```swift
struct CommunityFeedView: View {
    let community: CommunityModel
    
    var body: some View {
        Text(community.name)
        if let subscribed = community.subscribed {
            Text(subscribed)
        }
        if let subscriberCount = community.subscriberCount {
            Text(subscriberCount)
        }
        if let postCount = community.postCount {
            Text(postCount)
        }
        if let commentCount = community.commentCount {
            Text(commentCount)
        }
    }
}
```

With the tiered system, it looks like this:

```swift
struct CommunityFeedView: View {
    let community: any CommunityTier1Providing
    
    var body: some View {
        Text(community.name)
        if let community = community as? any CommunityTier2Providing {
            Text(community.subscribed)
            Text(community.subscriberCount)
            Text(community.postCount)
            Text(community.commentCount)
        }
    }
}

```

This is much less verbose.
