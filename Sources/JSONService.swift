
/// Default implementation of a JSON service.
/// Serves your `Order` to a server and parses the respons.
/// Response is delivered to you as a `JSONResult`.
public class JSONService: JSONServeable {

    /// Always results in .Success(["key" : "value"])
    /// This will change to a real request in the future
    public func serve(order: Order, result: (JSONResult) -> ()) {
        //TODO: make this perform a real request
        result(.Success(["key": "value"]))
    }
}