UIScrollLabel - Marquee UILabel
===============================

A marquee `UILabel` implementation, which utilises `UIScrollView` and `CADisplayLink` to scroll long text within a single-line label. 

## Installation with CocoaPods

```ruby
pod 'UIScrollLabel'
```

## Usage

Simply set `UIScrollLabel` as the subclass of your `UIScrollView` object, set the text in code, and you're good to go!

```swift
import UIScrollLabel

// ...

let pid = UIScrollLabel(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 60))
pid.font = UIFont.boldSystemFont(ofSize: 40)
pid.textColor = UIColor.red
pid.text = "The next station is KOKKAIGIDJIDOMAE. The doors on the left-hand side will open."
```

You can set the `textColor` and `text` right from Interface Builder, too! :tada:

## GIFs

_Ease In Ease Out_
<img src="https://github.com/topLayoutGuide/UIScrollLabel/blob/master/GIFs/pid_eio.gif"/>

_Ease In_
<img src="https://github.com/topLayoutGuide/UIScrollLabel/blob/master/GIFs/pid_ei.gif"/>

_Ease Out_
<img src="https://github.com/topLayoutGuide/UIScrollLabel/blob/master/GIFs/pid_eo.gif"/>

_Linear_
<img src="https://github.com/topLayoutGuide/UIScrollLabel/blob/master/GIFs/pid_l.gif"/>

## License

`UIScrollLabel` is released under the [MIT license](https://github.com/topLayoutGuide/UIScrollLabel/blob/master/LICENSE).

---

Presented to you with love, by [@topLayoutGuide](https://twitter.com/topLayoutGuide).
