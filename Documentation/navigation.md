# Navigation
This section focuses on how we should model our application's navigation. SwiftUI provides a lot of navigation tools out of the box, but they don't allow us to provide the functionality required to implement complex logic in a modular and testable manner.

## Table of Contents
{{TOC}}

## Previously: Managing Logic & Views
In the [[managing_logic_and_views|previous section]] we covered the importance of consistency, modularity, separation of UI and UX and testability. We outlined how to write features following these concepts by separating our models from our views using `@ObservedObject`.

## What is Important?
In order to build a scalable solution to a complex app with a multitude of screens and navigation, it's important to model our application's navigation using our app's state. Driving our application's navigation through sate allows us to easily support deep linking to every part of our application and furthermore, enables us to test our navigation and everything works as expected.

A lot of SwiftUI navigation tools pre-iOS 16 don't support driving navigation through state. The default initializers for things like `NavigationLink` are "fire-and-forget" style navigational techniques. This means that we have no way of interacting with them programmatically. Similar to the discussions we had around `@State` it locks away the functionality and logic of our features and prevents us from testing and integrating across features.

We really want to avoid "fire-and-forget" techniques are drive our navigation through our models, thus enabling deep linking and testing capabilities.

## 📦 `swiftui-navigation`
Enter [`swiftui-navigation`](https://github.com/pointfreeco/swiftui-navigation), a package created by `PointFree`. This package provides convenience tools that wrap around existing SwiftUI navigational concepts, allowing us to model our navigation in our `@ObservedObjects`.

## `Standups.app` Examples
Now that we've gone over the benefits of `ObservedObject` over other SwiftUI state management tools, let's walk through some real examples in the `Standups.app`.

### Basic Navigation
Let's start by looking at `StandupsListFeature`. The [[StandupsListView.swift]] supports the ability for the user to navigate to two places.

1. Tapping add standup button takes the user to the [[EditStandupView.swift]] to create a new [[Standup.swift]].
2. Tapping a [[CardView.swift]] in the [[StandupsListView.swift|StandupListView's]] `List` opens the [[StandupDetailView.swift]].

At initial glance, it might make sense to keep track of two properties in order to manage each of these navigational events. However, diving deeper, you might realize that only one of these navigational can possibly be active at a given time. As that is the case, we should aim to model our state in a similar way.

#### `StandupsListModel`
Jumping into [[StandupsListModel.swift]], you'll see an enum called `Destination`. This enum represents all the different places we can navigate to.

In the future, if we need to add another destination, it should be as simple as adding a case to the enum.

Inside our [[StandupsListModel.swift]], we need to hold onto an optional `Destination` so that we can represent where we are navigated to.

```swift
@Published public internal(set) var destination: Destination?
``` 

`nil` represents not having navigated anywhere, and `non-nil` represents we are navigating to one of the destinations.

You'll also note that our initializer takes in a destination as a parameter. This will allow whoever is creating the model to begin with a destination hydrated, which unlocks powerful deep linking capabilities.

Now, looking at the implementation of `addStandupButtonTapped()` or `standupTapped(standup:)`, All we have to do is hydrate the destination state.

This is all we need in our model layer to provide state driven navigation, but let's look further and see how this ties into the view layer of our feature.

#### `StandupsListView`
Inside our [[StandupsListView.swift]] on `Line:46`, you'll see 
```swift
.sheet(
	unwrapping: $model.destination,
	case: /StandupsListModel.Destination.add
) { $model //Binding<EditStandupModel>
	...
}
```

The modifier takes 3 arguments.
1. A `Binding<Enum?>` where `nil` represents no sheet being presented, and `non-nil` represents the sheet is presented. This binding is powered by our `@ObservedObject` model using the `destination` property.
2. The case of the enum by which you want to drive the sheet. The `Destination` has multiple cases, but only one single case actually powers this sheet.
	- This is accomplished via something called a "case path". A case path is analogous to a key path, except it is tuned specifically for abstracting over the shapes of enums, whereas key paths are more tuned for structs.
3. By specifying the binding and enum case that drives the sheet, you get a trailing closure for the sheet's content view and that closure is handed a binding to the case. The closure extracts out the associated value `EditStandupModel` from the `.add` case in our `Destination` enum and then we can simply pass that model into our [[EditStandupView.swift]].

We can power more than just sheets using this enum approach. Let's look at how the [[StandupDetailView.swift]] is presented.

On `Line:40`, you can see...

```swift 
.navigationDestination(
    unwrapping: $model.destination,
    case: /StandupsListModel.Destination.detail
) { $detailModel in
    StandupDetailView(model: detailModel)
}
```

This modifier works exactly the same as `.sheet`. However, rather that presenting a sheet, it pushes a `View` onto the navigation stack.

This is incredibly powerful! 💪 We have just defined all possible navigation for a given feature using a single enum based property. We can even test that our navigation works as expected.

Jump to [[StandupsListTests.swift]] and look for a function called `testTappingStandupInvokesCorrectDestination()`. In just a few lines, we are able to...

1. Create a [[StandupsListModel.swift]]
2. Assert our mock data exists.
3. Invoke a user action with `standupStapped(standup:)`
4. Assert our destination is updated and that our [[StandupDetailView.swift]] contains the same [[Standup.swift]] as the one we tapped.

### Communication Between Models.
We've covered basic navigation between different `Views`, but how do different `Views` interact with each other? Let's break down another example inside [[StandupsListView.swift]] and see how we can update our array of `Standups` when the user deletes a [[Standup.swift]] on the [[StandupDetailView.swift]].

First, let's look at the action. Jump inside [[StandupDetailView.swift]]. On `Line:80` we have a `Button` that triggers `deleteButtonTapped` on our model. Simple enough, let's checkout the model. 

Open [[StandupDetailModel.swift]] and look at the implementation of `func deleteButtonTapped()`. There isn't much going on here, we simply call a property of our model called `onConfirmDeletion`. The `StandupDetailModel` doesn't contain any explicit logic for handling the actual deletion of a [[Standup.swift]] as it is out of the scope of responsibilities of that feature. It's up to the caller to specify how they want to handle a request for deletion.

In our application, [[StandupDetailModel.swift]] is a destination of [[StandupsListModel.swift]], so let's jump to [[StandupsListModel.swift]]. Look for a function called `func bind()` on `Line:78`. This function is called via a `didSet` whenever our model's `destination` property changes. Inside this function, we can switch over each of the destinations and perform any custom binding logic. In our case, we want the [[StandupsListModel.swift]] to handle the `onConfirmDeletion` event from the [[StandupDetailModel.swift]]. 

In addition to handling the deletion logic, we want any changes to the [[Standup.swift]] [[StandupDetailModel.swift]] to be reflected in the `standups` array, so we subscribe to changes and update our array accordingly.

Sadly, `didSet` does not get called during the initialization of a property, so we also have to call `bind` at the bottom of our initializer in order to bind the behavior in cases where the model was initialized with a `Destination`.

This pattern might look familiar to you. It's called the "Delegate Pattern", and it's something we see all over `UIKit`.

There is one thing you might have noticed that we didn't cover, and that is the default implementation of `onConfirmDelete` inside [[StandupDetailModel.swift]].

```swift
public var onConfirmDeletion: () -> Void = unimplemented("StandupDetailModel.onConfirmDeletion")
```

This is a tool provided by `XCTestDynamicOverlay`. We don't want to force an implementation of `onConfirmDeletion` as we may not know what that implementation is at runtime, however we also don't want things to silently fail if we forget to correctly bind our models.

Enter `unimplemented`! This default value will cause a large purple error to show up in Xcode in the event that an implementation is missed. We will even get a stack trace to show us exactly where it happened.

> 🟣 Unimplemented: StandupDetailModel.onConfirmDeletion …

### Integration Tests

With the knowledge you've gained from this section, let's return to a unit test we looked at when covering [[managing_logic_and_views|Managing Logic & Views]] and see how our state driven navigation allowed us to write simple tests that validate integrations between multiple features.

Jump to `testEdit` and look over the test.

1. We create a [[StandupsListModel.swift]].
2. We mimic user interaction by calling `standupTapped()`
3. We assert that the `listModel's` `destination` has been updated to `.detail` using a `guard case let`
4. From there, we assert that the `detailModel's` [[Standup.swift]] matches the `listModel's` [[Standup]]
5. We mimic user interaction on the `detailModel` by calling `editButtonTapped()`
6. We assert that the `detailModel's` `destination` has been updated to `edit` using a `guard case let`.
7. We assert that the `detailModel's` [[Standup.swift]] matches the `editModel's` [[Standup.swift]].
8. We mimic user interaction by setting the standup's title to "Product"
9. We mimic user interaction by calling `doneEditingButtonTapped()`
10. We assert that both the `detailModel` and the `listModel` both had their [[Standup.swift]] updated.

We just validate the integration logic across three completely different features using ~20 lines of code. Without utilizing state driven navigation, all of this would be virtually impossible to do.

### Deep Linking
With the `Destination` approach we've taken, we've built in support for powerful deep linking capabilities. 

Right now, if you open [[StandupsApp.swift]], you'll see the following in our `App's` `body`.

```swift
StandupsListView(model: .init(
    destination: nil
))
```

However, we can simply modify the `destination` argument to launch our application directly to the [[StandupDetailView.swift]] screen for a particular [[Standup.swift]].

Try replacing changing the `body` to something like this...

```swift
StandupsListView(model: .init(
    destination: .detail(
        StandupDetailModel(standup: standup)
    )
))
```

Launch the application and you'll see that the app launches on the [[StandupDetailView.swift]] for our mock [[Standup.swift]]. Even more important, we built the entire navigation stack as well. You can tap back in the navigation bar, and you'll be taken right back to the [[StandupsListView.swift]].

We can take it a step further! 🪄 Change the `body` again to the following...

```swift
StandupsListView(model: .init(
    destination: .detail(
        StandupDetailModel(
            destination: .edit(
                EditStandupModel(
                    focus: .attendee(standup.attendees[0].id),
                    standup: standup
                )
            ),
            standup: standup
        )
    )
))
```

Launch the application and you'll see a full navigation stack generated...

[[StandupsListView.swift]] > [[StandupDetailView.swift]] > [[EditStandupView.swift]]

But even more impressive... The `TextField` for the `Attendee` named  "Bob" is already focused and ready for editing.

## Conclusion

By powering our navigation via state, we have unlocked capabilities to easily test integrations between features and empower our application via powerful deep linking capabilities. All of this is managed through an incredibly simple pattern utilizing a single enum for each of our features.

## Up Next: Side Effects







