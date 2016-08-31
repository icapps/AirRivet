import Foundation

/**
The environment where we should fetch the data from.

Example environments:

* Production
* Development
* Filesystem
* ...

*/
@available(*, deprecated=1.0.0, message="use the Bar class")

public protocol Environment {
	var serverUrl: String { get }
	var request: NSMutableURLRequest { get}
}

/**
If you implement `Mockable` your entity can provide a default response. This can be handy for tests.
When a type conforms to Mockable the environment you provide by conforming to `EnvironmentConfigurable` will be ignored and files are loaded from local disk by `Air`.
*/

@available(*, deprecated=1.0.0, message="use the Bar class")

public protocol Mockable {
	func shouldMock() -> Bool
}