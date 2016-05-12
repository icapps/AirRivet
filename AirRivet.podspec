# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "AirRivet"
  s.version          = "0.2.0"
  s.summary          = "AirRivet is a service layer to transfer data over the `Air`."

  s.description      = <<-DESC
__AirRivet__ is a service layer build in Swift by using generics. The idea is that you have `Air` which is a class that performs the request for an `Environment`. To do this it needs a Type called `Rivet` that can be handeled over the `Air` 🤔. So how do we make this `Rivet` Type?

`AnyThing` can be a `Rivet` if they are `Rivetable`. `Rivetable` is a combination of protocols that the Rivet (Type) has to conform to. The `Rivet` is `Rivetable` if:

- `Mitigatable` -> Receive requests to make anything that can go wrong less severe.
- `Parsable` -> You get Dictionaries that you use to set the variables
- `EnvironmentConfigurable` -> We could get the data over the `Air` from a _production_ or a _development_ environment
- There is also a special case where the environment is `Mockable` then your request are loaded from local files _(dummy files)_
- `UniqueAble` -> If your `AnyThing` is in a _collection_ you can find your entitiy by complying to `UniqueAble`

If you do the above (there are default implementation provided in the example).
                       DESC
 s.license          = 'MIT'
  s.homepage         = "https://github.com/icapps/ios-air-rivet"
  s.author           = { "Leroy" => "development@icapps.com" }
  s.source           = { :git => "https://github.com/icapps/ios-air-rivet.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/icapps'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'AirRivet' => ['Pod/Assets/*.png']
  }
end
