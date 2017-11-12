UIScrollLabel - Marquee UILabel
===============================

A marquee `UILabel` implementation, which utilises `UIScrollView` and `CADisplayLink` to scroll long text within a single-line label. 

## Installation with CocoaPods

```ruby
pod 'UICollectionViewLeftAlignedLayout'
```

## Usage

Simply set `UIScrollLabel` as the subclass of your `UIScrollView` object, set the text in code, and you're good to go!

```swift
let pid = UIScrollLabel(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 60))
pid.font = UIFont.boldSystemFont(ofSize: 40)
pid.textColor = UIColor.red
pid.text = "The next station is KOKKAIGIDJIDOMAE. The doors on the left-hand side will open."
```

You can set the `textColor` and `text` right from Interface Builder, too! :tada:

## License

`UIScrollLabel` is released under the [MIT license](https://github.com/topLayoutGuide/UIScrollLabel/blob/master/LICENSE).

---

Presented to you with love, by [@topLayoutGuide](https://twitter.com/topLayoutGuide).
