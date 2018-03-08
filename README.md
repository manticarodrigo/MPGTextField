## SearchTextField
An autocomplete textfield which provides suggestions as you type. This repo is forked from https://github.com/gaurvw/MPGTextField, optimized for Swift.
 
<H2>Setup</H2>

* Copy `SearchTextField.swift` file into your project.

* Add `SearchTextFieldDelegate` to the class.

* Implement the following required function:

```swift

func dataForPopoverInTextField(_ textfield: SearchTextField) -> [NSDictionary] {
    return yourDictionary
}

```

* Optionally implement the following functions:

```swift

func textFieldShouldSelect(_ textField: SearchTextField) -> Bool {
    // Optional method that tells the textfield if a selection should be made even if user doesn't select anything from the search results.
    return true
}

func textFieldDidEndEditing(textField: SearchTextField, withSelection data: NSDictionary) {
    // Optional method returns the object selected by the user or selected by the textfield for you or a new object where the `CustomObject` key is set to `NEW`
    if let text = data["Text"] as? String {
        print(text)
    }
    if let detailText = data["detailText"] as? String {
        print(detailText)
    }
}

```
All done! Enjoy :)
