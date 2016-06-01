AirRivet [![CI Status](http://img.shields.io/travis/icapps/ios-air-rivet.svg?style=flat)](https://travis-ci.org/icapps/ios-air-rivet) [![Version](https://img.shields.io/cocoapods/v/AirRivet.svg?style=flat)](http://cocoapods.org/pods/AirRivet) [![License](https://img.shields.io/cocoapods/l/AirRivet.svg?style=flat)](http://cocoapods.org/pods/AirRivet) [![Platform](https://img.shields.io/cocoapods/p/AirRivet.svg?style=flat)](http://cocoapods.org/pods/AirRivet)
======

For a quick start follow the instructions below. For more in depth information on why and how we build AirRivet, you are more then welcome on the [wiki](https://github.com/icapps/ios-air-rivet/wiki) page.

## Concept

__AirRivet__ is a service layer build in Swift using generics.

The idea is that you have `Air` which is a class that performs the request for an `Environment`. To do this it needs a Type called `Rivet` that can be handled over the `Air` 🤔. So how do we make this `Rivet` Type?

`AnyThing` can be a `Rivet` if they are `Rivetable`. `Rivetable` is a combination of protocols that the Rivet (Type) has to conform to. The `Rivet` is `Rivetable` if:

- `Mitigatable`: Receive requests to make anything that can go wrong less severe. `AirRivet` includes 2 `Mitigator`:

	1. `MitigatorDefault` prints any error that is thrown
	2. `MitigatorNoPrinting` does not print anyting. Handy for testing!

- `Parsable`: You get Dictionaries that you use to set the variables.
- `EnvironmentConfigurable`: We could get the data over the `Air` from a _production_ or a _development_ environment.
- `Mockable`: There is also a special case where the environment can be mocked. Than your request are loaded from local files _(dummy files)_
- `UniqueAble`: If your `AnyThing` is in a _collection_ you can find your entity by complying to `UniqueAble`
- `Transformable`: We need to be able to _transform_ data to a `Rivetable` type. A default transformer is `TransformJSON` but you can provide your own. AirRivet include 3 transformers you could use:

	1. `TransformJSON` the default
	2. `TransfromCoreData` -> used to transform to core data object.
	3. `TransformAndStore` -> use to store a JSON file when fetching
	4. `TransformAndStoreCoreData` -> equal to 3 but for CoreData


If you do the above (there are default implementation provided in the example). Then you could use the code like below.

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

1. Create a generic class that complies to `Environment, Mockable`.
2. Create a Model object that complies to protocol `Rivetable`.

### Swift
#### 1. Environment
```swift
class Environment <Rivet: EnvironmentConfigurable>: Environment, Mockable  {
	//You should use the contextPath as your API works. For this Environment we have "<base>/contextPath"
	var serverUrl = "http:// ...\(Rivet().contextPath())"
	var request: NSMutableURLRequest

	init() {
		request = NSMutableURLRequest(URL: NSURL(string: serverUrl)!)
	}

	func shouldMock() -> Bool {
		return false
	}
}
```
#### 2. Rivetable
```swift
class Foo: Rivetable {
	// Implement protocols.
	// See GameScore class in Example project.
}

import AirRivet

do {
	try Air.retrieve({ (response : Foo) in
	  print(response)
  })
} catch {
	print("💣Error with request construction: \(error)💣")
}
```

#### 3. Mitigatable
Use this to change the default error handling. Default handling is:
1. `Print` the error
2. `throw` the error back up

```swift
class Foo: Foo {
	// Implement protocols.
	// See GameScore class in Example project.

	class override func responseMitigator() -> protocol<ResponseMitigatable, Mitigator> {
		return MitigatorDefault()
	}

	class override func requestMitigator() -> protocol<RequestMitigatable, Mitigator> {
		return MitigatorDefault()
	}
}
```
If you want different error handling you can provide a different Mititagor instance.
As an example we provide the `MitigatorNoPrinting`. Handy to use in Unit tests

```swift
class MockFoo: Foo {
	// Implement protocols.
	// See GameScore class in Example project.

	// Override to disable printing

	class override func responseMitigator() -> protocol<ResponseMitigatable, Mitigator> {
		return MitigatorNoPrinting()
	}

	class override func requestMitigator() -> protocol<RequestMitigatable, Mitigator> {
		return MitigatorNoPrinting()
	}
}
```
### Objective-C

We use generics so you cannot directly use AirRivet in Objective-C. You can bypass this by writing a wrapper.

In our Example `GameScoreController` is the wrapper class.

```objective-C
// In build settings look at the Module Identifier.
// This is the one you should use to import swift files from the same target.

#import "AirRivet_Example-Swift.h"

GameScoreController * controller = [[GameScoreController alloc] init];
[controller retrieve:^(NSArray<Foo *> * _Nonnull response) {
	NSLog(@"%@", response);
} failure:^(NSError * _Nonnull error) {
	NSLog(@"%@", error);
}];
```
> *See "(project root)/Example" *

## Requirements

- iOS 8 or higher
- Because we use generics you can only use this pod in Swift only files. You can mix and Match with Objective-C but not with generic classes.  Types [More info](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/BuildingCocoaApps/InteractingWithObjective-CAPIs.html#//apple_ref/doc/uid/TP40014216-CH4-ID53)

## Installation

AirRivet is available through [CocoaPods](http://cocoapods.org) and the [Swift Package Manager](https://swift.org/package-manager/).

To install it with CocoaPods, add the following line to your Podfile:

```ruby
pod "AirRivet"
```

## Contribution

> Don't think to hard, try hard!

More info on the [contribution guidelines](https://github.com/icapps/ios-air-rivet/wiki/Contribution) wiki page.

## License

AirRivet is available under the MIT license. See the LICENSE file for more info.
