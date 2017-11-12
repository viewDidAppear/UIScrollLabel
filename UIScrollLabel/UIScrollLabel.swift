//
// Copyright © 2017 Benjamin Yan Jurgis Dietzkis
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
// the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Foundation
import UIKit

public enum ScrollDirection {
	case left
	case right
}

@IBDesignable public class UIScrollLabel: UIScrollView {
	
	private var displayLink: CADisplayLink?
	private var labels: [UILabel] = []
	private var startingValue: CGFloat = 0
	private var progress: TimeInterval = 0
	private var lastUpdate: TimeInterval = 0
	private var totalTime: TimeInterval = 0
	private var destinationValue: CGFloat = 0
	private var automaticallyScrollOnLoad: Bool = true
	private var currentValue: CGFloat {
		if progress >= totalTime { return destinationValue }
		return startingValue + (update(t: CGFloat(progress / totalTime)) * (destinationValue - startingValue))
	}
	
	// MARK: - Configurable Properties
	
	@IBInspectable public var text: String = "" {
		willSet(newValue) {
			if newValue == text {	return }
		}
		
		didSet {
			configure()
		}
	}
	
	@IBInspectable public var textColor: UIColor = .black {
		willSet(newValue) {
			if newValue == textColor { return }
		}
	}
	
	public var font: UIFont = UIFont.systemFont(ofSize: 16) {
		willSet(newValue) {
			if newValue == font {	return }
		}
	}
	
	public var scrollDirection: ScrollDirection = .left {
		didSet {
			configure()
		}
	}
	
	public var animationCurve: UIViewAnimationOptions = .curveEaseInOut
	public var scrollSpeed: TimeInterval = 6 // seconds
	public var spaceBetweenLabels: CGFloat = 40 // points
	public private(set) var isScrolling: Bool = false
	
	// MARK: - Initialization
	
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}
	
	override public init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	
	public init(frame: CGRect, automaticallyScrollOnLoad: Bool = false) {
		super.init(frame: frame)
		self.automaticallyScrollOnLoad = automaticallyScrollOnLoad
		commonInit()
	}
	
	private func commonInit() {
		showsVerticalScrollIndicator = false
		showsHorizontalScrollIndicator = false
		isScrollEnabled = false
		isUserInteractionEnabled = false
		backgroundColor = .clear
		clipsToBounds = true
		
		addLabels()
		configure()
	}
	
	// MARK: - Deinitialization
	
	deinit {
		displayLink?.invalidate()
		displayLink = nil
		labels = []
	}
	
	// MARK: - Start/Stop Animation
	
	private func start() {
		guard let mainLabel = labels.first, mainLabel.bounds.width > bounds.width else { return }
		
		let labelWidth = mainLabel.bounds.width
		
		contentOffset = scrollDirection == .left ? .zero : CGPoint(x: labelWidth + spaceBetweenLabels, y: 0)
		
		totalTime = scrollSpeed
		destinationValue = labelWidth + spaceBetweenLabels
		lastUpdate = Date.timeIntervalSinceReferenceDate
		
		removeDisplayLink()
		addDisplayLink()
		
		isScrolling = true
	}
	
	public func stop() {
		removeDisplayLink()
		progress = 0
		startingValue = 0
		lastUpdate = 0
		totalTime = 0
		destinationValue = 0
		resetContentOffset()
		
		isScrolling = false
	}
	
	private func configure() {
		// Stop all existing operation
		stop()
		
		// Relayout the labels
		layoutLabels()
		
		// Ensure the contentSize is accurate
		configureContentSize()
		
		// Determine whether or not we need to scroll
		if automaticallyScrollOnLoad {
			scrollIfNeeded()
		}
	}
	
	@objc private func updateValue(timer: Timer) {
		let now: TimeInterval = Date.timeIntervalSinceReferenceDate
		progress += now - lastUpdate
		lastUpdate = now
		
		if progress >= totalTime {
			progress = totalTime
			
			removeDisplayLink()
			restart()
		}
		
		if scrollDirection == .left {
			contentOffset.x = currentValue
		} else {
			contentOffset.x = -currentValue
		}
	}
	
	// MARK: - Scroll If Needed
	
	public func scrollIfNeeded() {
		guard let mainLabel = labels.first else { return }
		
		if mainLabel.bounds.width > bounds.width {
			labels.forEach { $0.isHidden = false }
			start()
		} else {
			labels.forEach { $0.isHidden = $0 != mainLabel }
			contentSize = bounds.size
			mainLabel.frame = bounds
			mainLabel.textAlignment = .left
		}
	}
	
	// MARK: - Reconfigure Layout
	
	private func addLabels() {
		for _ in 0..<2 {
			let label: UILabel = UILabel()
			label.textColor = textColor
			label.numberOfLines = 1
			addSubview(label)
			labels.append(label)
		}
	}
	
	private func layoutLabels() {
		var offset: CGFloat = 0
		
		labels.forEach {
			$0.text = text
			$0.sizeToFit()
			$0.frame = CGRect(x: offset, y: 0, width: $0.frame.width, height: bounds.height)
			$0.center = CGPoint(x: $0.center.x, y: round(center.y - frame.minY))
			
			if scrollDirection == .left {
				offset += round($0.bounds.width) + spaceBetweenLabels
			} else {
				offset -= round($0.bounds.width) + spaceBetweenLabels
			}
		}
	}
	
	private func configureContentSize() {
		guard let mainLabel = labels.first else { return }
		
		var size: CGSize = .zero
		size.width = mainLabel.bounds.width + bounds.width + spaceBetweenLabels
		size.height = bounds.height
		contentSize = size
	}
	
	private func resetContentOffset() {
		guard let mainLabel = labels.first else { return }
		let labelWidth = mainLabel.bounds.width
		
		contentOffset = scrollDirection == .left ? .zero : CGPoint(x: labelWidth + spaceBetweenLabels, y: 0)
	}
	
	// MARK: - Restart Scroll
	
	/// Restart the scrolling "animation" after a small delay, so as to replicate an actual "Marquee".
	private func restart() {
		let pauseInterval: TimeInterval = 1
		
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + pauseInterval, execute: { [weak self] in
			self?.configure()
			self?.start()
		})
	}
	
	// MARK: - Add/Remove Display Link
	
	private func addDisplayLink() {
		displayLink = CADisplayLink(target: self, selector: #selector(self.updateValue(timer:)))
		displayLink?.add(to: .main, forMode: .defaultRunLoopMode)
		displayLink?.add(to: .main, forMode: .UITrackingRunLoopMode)
	}
	
	private func removeDisplayLink() {
		displayLink?.invalidate()
		displayLink = nil
	}
	
	// MARK: - Easing Function
	
	fileprivate func update(t: CGFloat) -> CGFloat {
		var t = t
		var sign: CGFloat = 1 // Sign value
		let easingRate: CGFloat = 3 // Ideal, accurate curving.
		
		switch animationCurve {
		case .curveLinear:
			return t
		case .curveEaseIn:
			return pow(t, easingRate)
		case .curveEaseInOut:
			if Int(easingRate) % 2 == 0 {
				sign = -1
			}
			t *= 2
			return t < 1 ? 0.5 * pow(t, easingRate) : (sign*0.5) * (pow(t-2, easingRate) + sign*2)
		case .curveEaseOut:
			return 1.0-pow((1.0-t), easingRate)
		default:
			return t
		}
	}
	
}


