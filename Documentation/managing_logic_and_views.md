# Managing Logic & Views
This section focuses on how we should model our application's views and business logic. SwiftUI provides some powerful tools out of the box, but they don't necessarily provide the functionality required to implement complex logic in a modular and testable manner.

## Table of Contents
- [Previously: Standups.app Overview](#previously-standupsapp-overview)
- [What is Important?](#what-is-important)
   	- [Why is Consistency Important?](#why-is-consistency-important)
    	- [Why is Modularity Important?](#why-is-modularity-important)
    	- [Why is Separating UI from UX Important?](#why-is-separating-ui-from-ux-important)
  	- [Why is Testability Important?](#why-is-testability-important)
- [@State vs @StateObject vs @ObservedObject](#state-vs-stateobject-vs-observedobject)
	- [@State](#state)
	- [@StateObject](#stateobject)
	- [@ObservedObject](#observedobject)
- [Does Every View Need a Model?](#does-every-view-need-a-model)
- [Standups.app Examples](#standupsapp-examples)

	- [StandupsListFeature](#standupslistfeature)
		- [StandupsListView](#standupslistview)
		- [StandupsListModel](#standupslistmodel)
	- [StandupDetailFeature](#standupdetailfeature)
		- [StandupDetailView](#standupdetailview)
		- [StandupDetailModel](#standupdetailmodel)
	- [Views Without Models](#views-without-models)
- [Conclusion](#conclusion)
- [Up next: Navigation](#up-next-navigation)

## Previously: `Standups.app` Overview
In the [[standups_overview|previous section]] we covered what the `Standups.app` application does, outlining the apps screens and functionality.

## What is Important?
In order to frame the solution, it's important to discuss what we are aiming to achieve. 

When working with a team of developers on a large, scalable, application, it's important to be create an architecture that is maintainable. Four key concepts in a maintainable application are consistency, modularity, separation of UI and UX, and testability

### Why is Consistency Important?
Having an application that is consistent in its structure means that developers will feel a sense of familiarity when moving between different features and contexts. When a developer knows that each feature of an application is structured in a similar way, it takes less time for them to context switch and ramp up on different features. It also makes onboarding easier for new contributors.

### Why is Modularity Important?
Modules are self-contained units of code that can be imported and used in your application. Modules are isolated from the code that depends on them, and they only contain the necessary information they need to accomplish their task/feature.

It's important to break down an application into modules. By doing so, you create easier-to-understand units that can be built, tested, and distributed in isolation from one another. This makes it easier for multiple developers to work in an application at the same time, as each feature is isolated.

When working on a large application, it's unlikely that a developer has the full context of every feature. By breaking down features into isolated modules, it is easier for developers to digest how a feature functions. This is especially useful for new contributors.

### Why is Separating UI from UX Important
Separating our UI from our UX makes it easier for us to digest what is happening in our application and makes it clear where each responsibility should exist.

If we were to scatter our business logic in the SwiftUI `View` layer, it makes it difficult for developers to walk into a feature. They have no obvious place to begin looking for how state is mutated in an application. It could be hidden in a multitude of different locations, making it hard for developers to digest and contribute.

Separating our UI from our UX makes it easier to support multiple platforms and can dramatically cut down the work necessary to migrate to new UI frameworks. If all of our business logic was isolated from the view layer, we could have implemented SwiftUI `Views` and replaced existing `UIViewController` implementations with significantly less work. What happens when Apple releases the next big UI framework? Will re start a new re-write initiative, or will we be able to re-use our models for complex business logic?

Another major reason for separating UI and UX is that, in its current state, SwiftUI is not easily testable. Tangling our logic up inside our `Views` means there is no simple way to test that the logic we implemented actually performs as expected. We have to resort to complex and slow UI tests.

### Why is Testability Important
Testing is critical for a software developer. Testing is what allows us to verify that what we expect to happen in our program, actually happens. It provides us with the ability to refactor code with confidence or relearn what code is meant to do just by looking at the tests.

## `@State` vs `@StateObject` vs `@ObservedObject`
Now that we've outlined what's important to developing a scalable application, let's talk through some of the tools Apple provides us in SwiftUI to tackle state management.

### `@State`
This is often the state management tool you see most in SwiftUI, it allows us to keep track of some of data within our application's `View`, updating it as the user interacts with our app. While it is easy to use, it comes with quite a few caveats as we aim to create achieve all the things we deemed are important.

```swift
struct MyView: View {
	
	@State var username = ""
	@State var password = ""
	@State var isLoading = false
	
	var body: some View {
		VStack {
			TextField("Username", text: $username)
			TextField("Password", text: $password)
			Button("Login") { login() }
		}
	}
	
	func login() {
		...
	}
}
```

By using `@State` we are committing to having our business logic live inside the `View`. When we do this, we make testing our business logic very difficult. We would be unable to unit test our logic and would have to fall back to writing slow, cumbersome UI tests. 😨

In addition to testing, by modeling our state locally within the `View` using `@State` we would have no way to deep link into the given `View` as the state is completely hidden from the rest of the application.

`@State` acts as a local source of truth, and cannot be influenced from the outside. As a result, using `@State` is less than ideal when it comes to creating features that interact with each other. 😞

### `@StateObject`
Next up is `@StateObject`, which works very similarly to `@State`. To make use of `@StateObject` we must create a `class` that conforms to `ObservableObject`. From there, we can define all the state properties we want to manage in our `View`, prefixing them with `@Published`

```swift
class MyViewModel: ObservableObject {
	@Published var isLoading = false
	@Published var username: String = ""
	@Published var password: String = ""
	
	func login() {
		...
	}
}

struct MyView: View {
	@StateObject var model = MyViewModel()
	
	var body: some View {
		VStack {
			TextField("Username", text: $model.username)
			TextField("Password", text: $model.password)
			Button("Login") { model.login() }
		}
	}
}
```

From here, any changes to the `@Published` properties will cause the `View` containing the. `@StateObject` to re-render, and the `View` can call various functions on the model to perform business logic.

On the surface, this seems like a great way to model our business logic. We can easily unit test logic in our model like `login()` without having to concern ourselves with the UI layer of the feature. 🤩

However, just like `@State` isolates our logic inside the `View`, so does `@StateObject`. We are creating a local source of truth that cannot be influenced outside of the `View`. We may be able to test that `MyViewModel's` logic works correctly, but we are unable to test how this feature integrates between different features, like `MyView's` parent. 😭

You might be thinking, well can't we just pass in our model in the initializer of our `View`? 🤔

```swift
struct MyView: View {
	@StateObject var model: MyViewModel
	
	init(model: MyViewModel) {
		self._model = .init(wrappedValue: model)
	}
	
	var body: some View { ... }
}
```

At first glance, this might seem like a reasonable way to support injecting logic/state into our `View` however a closer look under the hood of `@StateObject` reveals that calling `init` doesn't work how one would think. 😵‍💫

Apple explicitly tells us...
> You don’t call this initializer directly. Instead, declare a property with the `@StateObject` attribute in a `View`, `App`, or `Scene`, and provide an initial value:
> 
```swift
struct MyView: View {
    @StateObject var model = DataModel()
}
```
> SwiftUI creates a new instance of the object only once for each instance of the structure that declares the object. When published properties of the observable object change, SwiftUI updates the parts of any view that depend on those properties: 
 
[Source - @StateObject](https://developer.apple.com/documentation/swiftui/stateobject)

This means that changing the value of `@StateObject` from outside will not affect the `View`. 

Take the following example...

```swift
struct MyChildModel: ObservableObject {
	@Published var text: String
	
	init(text: String) {
		self.text = text
	}
}

struct MyChild: View {
	@StateObject var model: MyChildModel
	
	init(model: MyChildModel) {
		_model = .init(wrappedValue: model)
	}
	
	var body: some View {
		TextField("My TextField", text: $model.text)
	}
}

struct MyParent: View {
	@State var prefillText = false
	
	var body: some View {
		Toggle("Prefill Text", isOn: $prefillText)
		MyChild(
		    model: MyChildModel(text: prefillText ? "Prefill" : "")
	    )
	}
}
```

Contrary to what you might think, in the above example flipping the `Toggle` on/off will not update the text displayed in `MyChild's` `TextField`. 🤯 This is due to the way that `SwiftUI` manages state under the hood.

There are ways to cause the changes to actually update the child, like making use of the `.id` modifier in the `body` of `MyParent`. However, as it works now, from a utilizer of `MyChild`, a developer would have no idea that is something they have to do. It isn't discoverable and comes with other caveats such as how SwiftUI manages re-renders, which could result in a lack of ability to animate changes in state and cause excessive re-rendering. When creating a scalable application with many features and developers, hidden caveats should be avoided at all costs.

`@StateObject` is so close to what we want in a scalable, testable, and modular SwiftUI application. 🥲 We can test the logic of a feature, and remove logic from the view layer, but we are still isolated from the rest of the application, preventing us from injecting dependencies and testing integrations between `Views`.

### `@ObservedObject`
`@ObservedObject` works virtually the same as `@StateObject`, with one major benefit! We can modify it externally to the owning `View`! 🥳 

Take the above example shown in `@StateObject` with the `Toggle` inside `MyParent` failing to re-render the text inside `MyChild`. Simply by switching from `@StateObject` to `@ObservedObject`, the functionality works as intended. 😁

With `@ObservedObject`, we've managed to greatly improve our code quality. Our business logic now lives inside our model, completely separated from our `View`. We could theoretically power both a `UIViewController` or a SwiftUI `View` from the same model class. With the UI separated, it is much easier for us to test our business logic. In addition to all this, we can integrate `Views` together, as modifications to our models propagate throughout the view hierarchy.

## Does Every View Need a Model?
The short answer is no. Models are useful for separating business logic from the view layer, but not every `View` contains business logic. Some `Views` simply take data and place it on screen for the user to see. For those types of `Views`, we can write snapshot tests to verify they look how we expect them too, but they don't necessarily need a model, as they don't contain business logic. Whenever you start adding things like user-interaction or functions that perform tasks beyond rendering declaritive UI into your `View`, you should be reaching to create a model.

## `Standups.app` Examples
Now that we've gone over the benefits of `ObservedObject` over other SwiftUI state management tools, let's walk through some real examples in the `Standups.app`.

### `StandupsListFeature`
Let's start by looking at `StandupsListFeature` and breakdown its structure so that we can better understand the benefits of separating our UI from our UX.

The feature is broken down into two core objects. One SwiftUI `View` called `StandupsListView` and one `ObservableObject` called `StandupsListModel`.

This feature has quite a few capabilities we need to support...
1. Users are able to view all of their standups in a list.
2. Users are able to navigate to the `StandupsDetailView`, in the `StandupDetailFeature`, by tapping on a list item.
3. Users are able to tap the add button, navigating them to the `EditStandupView`, in the `StandupDetailFeature`, where they can enter the information for their new standup.
4. The list of standups needs to stay updated as information changes inside child features.
5. The list of standups should be persisted to disk so that the user can save their application state across sessions.

That's a decent amount of logic for a single view to keep track of, so let's walk through our two core objects and understand where all of this functionality exists.

#### `StandupsListView`
Taking a glance at this `View` you can see it contains one single property...

```swift
@ObservedObject private var model: StandupsListModel
```
 
This is the source of truth for this `View`. Any data to be rendered or logic to be performed lives inside that `model`, and the `View` will reference various properties or methods to perform the logic necessary to accomplish our list of capabilities.

Scrolling through the `body` of the `StandupsListView`, you'll see that there is no logic inside the declarative UI, The `View` simply references to properties and functions inside the `model`. This makes it really easy to see how this `View` is structured and what's going on.

#### `StandupsListModel`
Opening our model object, you'll quickly see that this is where our business logic lives.

We have two core properties power this model...

```swift
@Published public internal(set) var standups: IdentifiedArrayOf<Standup>

@Published public internal(set) var destination: Destination?
```

- `standups` is what powers our `View's` `List`, placing our standups on screen for the user.
- `destination` powers our `View's` navigation to various areas of our app. We won't dive into this too much here, as we will cover this more inside [Navigation](navigation.md).

Scrolling down, you'll see a section `// MARK: Actions`. This is where all of our user interactions with the `View` live.

Looking at `confirmAddStandupButtonTapped()` you can see some business logic that happens after the user has confirmed they want to add a new `Standup`. The logic involves removing any of the `Attendees` from the `Standup` that have no name before appending it to the `standups` array. If this logic existed inside the `View` layer. We would have no way of testing this without writing a UI test. However, our logic lives in a model, and we can test that!

Jumping to `StandupsListTests`, we see a test named `testNamelessAttendees`. We haven't covered [Dependencies & Testing](dependencies_and_testing.md) or [Navigation](navigation.md) yet, so let's not dive too deep into how those portions of the test work.

1. On `Line:21`, we call `listModel.addStandupButtonTapped()`, which should open the `EditStandupView`.
2. On `Line:27` we modify the `EditStandupModel's` attendees directly in the test.
3. Then, on `Line:32`, we call `listModel.confirmAddStandupButtonTapped()`

From there, we perform a few assertions on the `StandupsListModel` to confirm our logic executed as expected.
- Assert that a `Standup` added to the `standups` property in `StandupsListModel`.
- Assert that the added `Standup` has only one `Attendee`
- Assert that the one `Attendee's` name is `John`.

And just like that, we've been able to unit test that our filtering of nameless `Attendees` worked as expected. We were also able to test that our navigation and integration between different features worked successfully, but that will be covered more in [Dependencies & Testing](dependencies_and_testing.md) and [Navigation](navigation.md).

### `StandupDetailFeature`
Similarly to the `StandupsListFeature` we covered above, the `StandupsDetailFeature` is broken down into a model called `StandupDetailModel` and a view called `StandupDetailView`.

Let's break down how we model the views and logic necessary to support swipe-to-delete actions in our `StandupDetailView's` Past Meetings section.

#### `StandupDetailView`
Just like the `StandupsListView`, this `View` contains a single `@ObservedObject` called `model` that powers all the functionality and data the user will see and interact with.

The `body` is declarative and void of business logic.

Scrolling down to `Line:54` we can see a `Section` dedicated to displaying our meetings. The `Section` contains a `ForEach` that renders each meeting on the screen, and adds a `onDelete` modifier, where our functionality triggers.

Again, just as before. The execution of the logic is delegated to the `model` by calling `model.deleteMeetings(atOffsets: indicies)`

Let's go look at the `StandupDetailModel` to see how this business logic is implemented.

#### `StandupDetailModel`
Inside the model, let's look at `Line:45`

`func deleteMeetings(atOffsets indicies: IndexSet) { ... }`

There isn't much logic to it, we simply remove the meetings at the provided indices, but because it exists in the model, we can test it! 

Jump over to `StandupDetailTests` and you'll see one example test called `testMeetingDeletion`. Let's break it down.

1. We initialize a `StandupDetailModel` with our mock `Standup`
2. We assert that the model actually uses the `Standup` we initialized it with.
3. We assert that the provided `Standup` already has a meeting.
4. We call `model.deleteMeetings(atOffsets:)`, mimicking the user interaction.
5. We assert that the meeting was actually deleted.

Again, it's a small example, but we were able to fully test what we expected to happen, and write a very short and quick unit test to confirm he logic works as expected. If we had left this logic in the `View`, we wouldn't be able to accomplish testing this logic in a unit test.

### `Views` Without Models
We've covered `Views` that perform business logic and shown how we can extract that business logic into a model, but what about an example where we don't need a model?

Let's look at `CardView` inside the `StandupListFeature`. This is the `View` we render inside the `StandupsListView's` `List` and shows us  each `Standup` we are tracking.

Because the `Button` lives outside of the `CardView` in the `StandupListView's` `body`, there isn't actually and logic or interaction being performed in the `CardView`. As a result, this means we can simply pass our `Standup` to the `CardView` and let it layout the information on the screen. 

There is no logic to test here, and for that reason, we don't need a model.

It may be beneficial to write a snapshot test to verify that UI looks as the designers expect, but that isn't a topic we aim to cover here.

## Conclusion
By following the examples outlined above, we've shown how we can write modular, isolated features in a consistent and testable manner.

## Up next: Navigation
In the next section, we will talk about [Navigation](navigation.md) and how it is important to derive our application's navigational structure through state.





