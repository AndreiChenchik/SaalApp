# SaalApp
Take home assignment for Saal Digital


## Task description
Please imagine that you are working for an international team and you are asked to develop an object management app whose requirements are explained below. When implementing the requirements below, please bear in mind that even though it is a simple app, this can be reviewed or further developed by other colleagues. 

The goal is to create a system for managing objects. For example, an object can be a desk, computer, keyboard, server or human being.
Objects have the following attributes: name, description and type.

The following functions should be available
- Create/edit/delete objects
- Create/edit/delete relations between objects (for example a desk can contain a calculator and Max uses the desk as a workplace)
- Search for objects
- All data must be serializable/storable. For this use a persistent storage.

### GUI
The GUI does not have to look exactly like this. Native components and styles are preferred.

### Further information
The implementation should be done in Swift 5, UIKit framework and Clean Swift architecture. Any pods or design patterns are allowed. Describe all the choices you made for the implementation. Delivery date within maximum 48 hours after receiving this test.


## How to run
1. Clone the repo
2. Open `SaalApp.xcodeproj` in Xcode
3. Change in `Target > Signing & Capabilities` tab
   - Select your development account in `Team` field
   - Replace user/team part of `Bundle identifier`
4. Select Simulator or Real device
5. Hit Run
6. Having [swiftlint](https://github.com/realm/SwiftLint) installed is advisable 

### Requirements to deploy & run this app
- iPhone 
- iOS 13.0+
- Xcode 13.0


## How to Contribute
1. Make sure to do development in separate branch
2. Your PR must pass all CI checks
3. Squash and delete development branch on merge
4. No force push allowed to main branch


## Decisions and limitations

- Supported Xcode version is limited to 13+ because it's the latest stable version.
- Supported iOS limited to 13+ since it's have all necessary SDK changes for collection-like views (e.g. diffable data source) and [widely adopted by ~97% of market](https://mixpanel.com/trends/#report/ios_13/from_date:-3,report_unit:hour,to_date:0). 
- Form factor support limited to portrait iPhone because it would be better to create a different UI approach for wide screens like iPad or landscape iPhone orientation.
