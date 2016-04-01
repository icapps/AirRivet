import Foundation


/** 
RequestController to handle interactions with a model of a specific Type.
# Tasks

## Save
`Type` is converted to JSON and send as the body of a request
## Retrieve

You can retreive a single instance or an array of objects

## Handle response via `ResponseController`
The response controllers does the actual parsing. In theory you can parse any kind of reponse, for now we only support JSON.

## Pass errors to the errorController of `Type`
Any type can decide to handle error in a specific way that is suited for that `Type` via its `ErrorController`.

* TODO: remove duplication
*/
public class RequestController <Type: BaseModel> {
	private let responseController: ResponseController
	private let sessionConfig: NSURLSessionConfiguration
	private let session: NSURLSession

	/**
	Initialization
	
	- parameter serviceParameters: a class that defines how to reach your server
	- parameter responseController: a default repsonse controller is provided that can handle JSON responses and normal errors related to that. You can always provide your own for more complex cases.
	- returns: A genericly typed Request controller that can handle task for the `Type` you provide.
	*/
	public init(serviceParameters: ServiceParameters, responseController: ResponseController = ResponseController()) {
		self.responseController = responseController
		sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
		session = NSURLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
	}

	//MARK: - Save
/**
 Save a single item or `Type`
	
	- parameter body: the Type object is converted to JSON and send to the server.
	- parameter completion: closure is called when service request successfully returns
	- parameter failure: optional parameter that we need to implement because the function `dataTaskWithRequest` on a `WebServiceSession` does not throw.
	- throws : TODO
*/
	public func save(body: Type, completion:(response: Type)->(), failure:((RequestError) ->())? = nil) throws {
		let request = Type.serviceParameters().request
		request.HTTPMethod = "POST"

		guard let bodyObject = body.body() else {
			try body.errorController.requestBodyError()
			return
		}

		do {
			request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(bodyObject, options: .PrettyPrinted)
		}catch {
			try body.errorController.requestBodyError()
		}

		let task = session.dataTaskWithRequest(request, completionHandler: { [unowned self] (data, response, error) -> Void in
			guard error == nil else {
				let taskError = error!
				print("---Error request failed with error: \(taskError)----")
				do {
					try body.errorController.requestResponseError(taskError)
				}catch {
					failure?(RequestError.ResponseError(error: taskError))
				}
				failure?(RequestError.ResponseError(error: taskError))
				return
			}

			do {
				try self.responseController.handleResponse((data: data,urlResponse: response, error: error), body: body, completion: completion)
			}catch RequestError.InvalidAuthentication {
				print("---Error we could not Authenticate----")
				do {
					try body.errorController.requestAuthenticationError()
				}catch {
					failure?(RequestError.InvalidAuthentication)
				}
			}catch {
				print("---Error we could not process the response----")
				do {
					try body.errorController.requestGeneralError()
				}catch {
					failure?(RequestError.General)
				}
			}
		})

		task.resume()
	}

	//MARK: - Retrieve
	/**
 Retreive a all items of `Type`
	
	- parameter response: closure is called when service request successfully returns
	- parameter failure: optional parameter that we need to implement because the function `dataTaskWithRequest` on a `WebServiceSession` does not throw.
	- throws : TODO
	*/
	public func retrieve(completion:(response: [Type])->(), failure:((RequestError)->())? = nil) throws{
		let request = Type.serviceParameters().request
		request.HTTPMethod = "GET"
		
		let task = session.dataTaskWithRequest(request, completionHandler: { [unowned self] (data, response, error) -> Void in
			if let error = error {
				print("---Error request failed with error: \(error)----")
				failure?(RequestError.ResponseError(error: error))
			}else {
				do {
					try self.responseController.handleResponse((data: data,urlResponse: response, error: error), completion: completion)
				}catch RequestError.InvalidAuthentication {
					print("---Error we could not Authenticate----")
					failure?(RequestError.InvalidAuthentication)
				}catch {
					print("---Error we could not process the response----")
					failure?(RequestError.General)
				}
			}
		})
		
		task.resume()
		
	}
	
	/**
 Retreive a single item or `Type`
	
	- parameter objectID: Something that uniquely defines the object you are asking for of `Type`
	- parameter completion: closure is called when service request successfully returns
	- parameter failure: optional parameter that we need to implement because the function `dataTaskWithRequest` on a `WebServiceSession` does not throw.
	- throws : TODO
	*/
	public func retrieve(objectId:String, completion:(response: Type)->(),failure:((RequestError)->())? = nil) throws{
		let request = Type.serviceParameters().request
		request.URL = request.URL!.URLByAppendingPathComponent(objectId)
		request.HTTPMethod = "GET"
		
		let task = session.dataTaskWithRequest(request, completionHandler: { [unowned self] (data, response, error) -> Void in
			if error != nil {
				print("---Error request failed with error: \(error)----")
			}else {
				do {
					try self.responseController.handleResponse((data: data,urlResponse: response, error: error), completion: completion)
					
				}catch RequestError.InvalidAuthentication {
					print("---Error we could not Authenticate----")
					failure?(RequestError.InvalidAuthentication)
				}catch {
					print("---Error we could not process the response----")
					failure?(RequestError.General)
				}
			}
		})
		
		task.resume()
		
	}
}
