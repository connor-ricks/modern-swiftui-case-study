# Dependencies & Testing
This section focuses on how we manage dependencies. Separating our dependency logic out into smaller more testable chunks allows us to better isolate functionality and build reusable components of our application. In addition, supporting dependency injection enables more powerful mocking behavior not just in our tests, but also our SwiftUI previews.

## Table of Contents
- [Previously: Navigation](#previously-navigation)
- [What is Important?](#what-is-important)
- [Standups.app Examples](#standupsapp-examples)
  - [Data Persistence](#data-persistence)
  - [Speech Client](#speech-client)
- [Conclusion](#conclusion)

## Previously: Navigation
In the [previous section](navigation.md) we covered the importance of state driven navigation. We unlocked powerful capabilities by modeling our navigation as `Destination` enums. Now it's time to cover dependencies

## What is Important?
Dependencies are a complex part of any application. From authentication to networking and data persistence, dependencies are everywhere. However, we don't want to throw all of that logic into our `View's` model, so we need to breakdown these dependencies into reusable chunks.

Our `Standups.app` has a two obvious dependencies.
- Data Persistence
- Speech Recognition through our `SpeechService`

But other dependencies could be added...
- Right now, we generate `UUIDs`  for our models all across the application. This is less than ideal, and we could improve the application to utilize a `UUID` generator dependency.
- Inside the function `recordStandup(transcript:)` in our `StandupDetailModel` we create a `Date()` to represent the meeting took place. We could have a dependency that provides a `.now` `Date` that we can provide so that we can effectively unit test.

We've already outlined the importance of separation of concerns, so this section will help define how we actually do that in a modern and scalable SwiftUI application.

## `Standups.app` Examples
### Data Persistence
Saving `Standups` to disk and loading them on launch should not be the responsibility of our `StandupsListModel`, but it is a side-effect that we must trigger whenever our `standups` array changes.

Let's jump into `StandupsListModel` and see how data persistence works.

Below `// MARK: Persistence` you'll see two functions.
- `saveStandups`
- `loadStandups`

They both reference a property called `standupsProvider`. Scroll up in the file to `Line:31`. There you will see

```swift
@Dependency(\.standupsProvider) var standupsProvider
```

`@Dependency` is a property wrapper provided by [swift-dependencies](https://github.com/pointfreeco/swift-dependencies). It works in a very similar way to `@Environment` in SwiftUI, but allows us to utilize the dependencies outside of our SwiftUI `Views`.

If you look at `StandupsProvider`, starting on `Line:16` you'll see a how closely `@Dependency` mimics `@Environment`.

1. We first extend `DependencyValues` providing a property accessor for our injected dependency.
2. We extend our dependency to `DependencyKey` and provide a `liveValue` which works like `defaultValue` in `@Environment`. There, we can provide the value for our dependency in production applications.

With just a couple lines of code, we have provided the ability to inject production level dependencies into our application. However, there's another powerful tool inside `@Dependency` that we can utilize.

### Speech Client

Jump to `SpeechClient`. This is the dependency that powers the speech transcript while we record a meeting. On `Line:23`, you'll see us provide a `liveValue` just like we did for our `StandupsProvider`, but below that on `Line:40`, you'll see us define a `previewValue` as well. This allows us to swap in a different dependency for our SwiftUI previews. In the case of the `SpeechClient`, this is really important! SpeechKit doesn't work in SwiftUI previews, so if we did not provide a `previewValue` we would be unable to view any previews of our `RecordStandupView`.

There's a lot of good material on advanced techniques and rather than copy pasting a large portion of it here, checkout the [documentation](https://pointfreeco.github.io/swift-dependencies/main/documentation/dependencies/)

However, one last thing I would like to address here is how we can inject mocks for testing.

So, with the knowledge we've gathered in this section, let's jump back to `StandupsListTests` and look at `testEdit()`.

In order to inject our mock dependencies, we wrap our test in a call to `withDependencies`, which takes two arguments.

1. First, a closure that allows us to inject the test dependencies we wish to use.
2. A closure called `operation` which is where we should perform our test.

Any models created with `@Dependency` properties inside the `operation` block will have their live dependencies replaced with the ones provided in the initial closure.

## Conclusion
`@Dependency` provides us with powerful tools that help us write isolated dependencies and inject them into our business logic. We are then able to effectively swap out our dependencies to assist us in writing effective tests of our business logic.



