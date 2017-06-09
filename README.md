[![Build Status](https://travis-ci.org/TaniaGoswami/PasswordManager.svg?branch=master)](https://travis-ci.org/TaniaGoswami/PasswordManager)
[![codecov](https://codecov.io/gh/TaniaGoswami/PasswordManager/branch/master/graph/badge.svg)](https://codecov.io/gh/TaniaGoswami/PasswordManager)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
![SwiftPM Compatible](https://img.shields.io/badge/SwiftPM-Compatible-brightgreen.svg)

# Password Manager App Extension in Swift

Password Manager App Extension written in Swift

Users of your app will be able to:

1. Use their password manager to retrieve their credentials for your login screen.
2. Create new login information with a strong password generator and save to their password manager.
3. Change their password without leaving your app.

## Installation

### Carthage

You can install [Carthage](https://github.com/Carthage/Carthage) with [Homebrew](http://brew.sh/) using the following command:

```bash
brew update
brew install carthage
```
To integrate JSONFeed into your Xcode project using Carthage, specify it in your `Cartfile` where `"x.x.x"` is the current release:

```ogdl
github "TaniaGoswami/PasswordManager" "x.x.x"
```

### Swift Package Manager

To install using [Swift Package Manager](https://swift.org/package-manager/) have your Swift package set up, and add PasswordManager as a dependency to your `Package.swift`.

```swift
dependencies: [
    .Package(url: "https://github.com/TaniaGoswami/PasswordManager.git", majorVersion: 0)
]
```

### Manually

Add all the files from `PasswordManager/PasswordManager` to your project

## Usage

### Allow user to log in to your native app

Check if a password management application is available with the `isPasswordManagerAvailable` variable. If it is, show login icon so that the user is aware that they can use their password manager to log in.

Add `org-appextension-feature-password-management` to your target's `info.plist`:

![Custom URL scheme](/assets/plist-screenshot.png?raw=true "Custom URL Scheme")

Call the `findLogin` method from your `UIViewController` when the button is clicked. This is what the call and result handling could look like:

```swift
PasswordManager.shared.findLogin(urlString: "https://www.yourapp.com", viewController: self, sender: self.passwordButton) { dictionary, error in
    if let error = error {
        result(nil, nil, error)
        return
    }
    guard let username = dictionary?["username"] as? String else {
        result(nil, nil, PasswordManagerError.usernameNotFound)
        return
    }
    guard let password = dictionary?["password"] as? String else {
        result(nil, nil, PasswordManagerError.passwordNotFound)
        return
    }
    result(username, password, nil)
}
```

The share sheet will be presented on the UIViewController that is passed in. The completion block will be called on the main thread when the user finishes their selection. Finally, you can retrieve the credentials from the login dictionary and validate them.

### Allow user to create new login information

Call the `storeLogin` method from your `UIViewController` when the create account button is clicked. This is what the call and result handling could look like:

```swift
func createLogin(username: String, password: String, viewController: UIViewController, sender: UIView, result: @escaping (String?, String?, Error?) -> Void) {
    let newLoginDetails: [String : Any] = [
        "login_title": "Your App",
        "username": username,
        "password": password,
        "notes": "Saved with your app"
    ]
    let passwordGenerationOptions: [String: Any] = ["password_min_length": 8 ]
    PasswordManager.shared.storeLogin(urlString: "https://www.yourapp.com", loginDetails: newLoginDetails, passwordGenerationOptions: passwordGenerationOptions, viewController: viewController, sender: sender) { dictionary, error in
        if let error = error {
            result(nil, nil, error)
            return
        }
        guard let username = dictionary?["username"] as? String else {
            result(nil, nil, PasswordManagerError.usernameNotFound)
            return
        }
        guard let password = dictionary?["password"] as? String else {
            result(nil, nil, PasswordManagerError.passwordNotFound)
            return
        }
        result(username, password, nil)
    }
}
```

Remember that your value for `urlString` here should be the same as it was in your `findLogin` command so that users can later use the login information that they generated.

### Allow user to change their password

Call the `changePassword` method from your `UIViewController` for your change password screen. This is what the call and result handling could look like:

```swift
func changePassword(username: String, oldPassword: String, password: String, viewController: UIViewController, sender: UIView, result: @escaping (String?, String?, String?, Error?) -> Void) {
    let updateCredentialsDetails: [String : Any] = [
        "login_title": "Your App",
        "username": username,
        "old_password": oldPassword,
        "password": password,
        "notes": "Saved with your app"
    ]
    let passwordGenerationOptions: [String: Any] = ["password_min_length": 8 ]
    PasswordManager.shared.changePasswordForLogin(urlString: "https://www.yourapp.com", loginDetails: updateCredentialsDetails, passwordGenerationOptions: passwordGenerationOptions, viewController: viewController, sender: sender) { dictionary, error in
        if let error = error {
            result(nil, nil, nil, error)
            return
        }
        guard let username = dictionary?["username"] as? String else {
            result(nil, nil, nil, PasswordManagerError.usernameNotFound)
            return
        }
        guard let password = dictionary?["password"] as? String else {
            result(nil, nil, nil, PasswordManagerError.passwordNotFound)
            return
        }
        guard let oldPassword = dictionary?["old_password"] as? String else {
            result(nil, nil, nil, PasswordManagerError.passwordNotFound)
            return
        }
        result(username, password, oldPassword, nil)
    }
}
```

Remember that your value for `urlString` here should be the same as it was in your `findLogin` command so that users can later use the login information that they generated.

## Notes

1. `URLString` should refer to your service so that your user can find their login information within their password manager app. If you don't have a website for your app, you should use your bundle identifier for the `URLString`: `app://yourapp`.



