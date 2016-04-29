//
//  BaseModel.swift
//  Umbrella
//
//  Created by Stijn Willems on 29/11/15.
//  Copyright © 2015 dooz. All rights reserved.
//

import Foundation


/**
An `Air` should be able to build up a request when your model object complies to the protocols below.
*/

/**
React and/or solve errors that could arrise while the entity that conforms to `Mitigatable` is handeled.

You can inspect how error mitigation is expected to behave by looking at `AirSpec` in the tests of the Example project.
*/
public protocol Mitigatable : class {

	init ()
	/**
	By returning an error controller you can handle parsing errors.
	- returns: By default an implementation of `DefaultMitigator` is returned via a protocol extension
	*/
	func responseMitigator() -> ResponseMitigatable
	/**
	If an error happens while constructing an entity this error controller could handle the error if needed.
	 - returns: By default an implementation of `DefaultMitigator` is returned via a protocol extension
	*/
	static func requestMitigator()-> RequestMitigatable
}

public protocol Parsable {
	init ()
	
	/**
	Set all properties from the data
	*/
	func parseFromDict(dict: AnyObject) throws

	/**
	From a dictionary containing properties of the object
	*/
	func toDictionary()-> NSDictionary?

	/**
	Should provide key in JSON to node of dict that can be parsed.
	
	```
	{
		rootKey: {<dictToParse>}
	}
	```
	*/
	static func rootKey() -> String?
}


public protocol EnvironmentConfigurable {

	init ()
	
	func environment() ->  protocol<Environment, Mockable, Transformable>

	/**
	* An url is formed from <ServiceParameter.serverURL+BaseModel.contextPath>.
	*/
	func contextPath() -> String
}

/**
 Every object has to have an unique identifier
 */
public protocol UniqueAble {
	var objectId: String? {get set}
}

