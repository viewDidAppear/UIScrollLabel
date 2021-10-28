//
// Copyright © 2021 Benjamin Deckys
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

import UIKit

public final class P2PMessageMarqueeLabel: UIScrollView {

    private var labels: [UILabel] = []

    // MARK: - Configurable Properties

    public var text: String = "" {
        didSet {
            configure()
        }
    }

    public var textColor: UIColor = .white {
        didSet {
            labels.forEach {
                $0.textColor = textColor
            }
        }
    }

    public var font: UIFont = UIFont.boldSystemFont(ofSize: 14) {
        didSet {
            labels.forEach {
                $0.font = font
            }
        }
    }

    public var animationCurve: UIViewAnimationOptions = .curveEaseInOut {
		didSet {
			configure()
		}
	}

    /// Configure the delay before animation
    ///
    /// Use this to set how long the animation waits before repeat. Defaults to 1 second.
    public var scrollDelay: TimeInterval = 1 // seconds

    /// Configure animation duration
    ///
    /// Use this to set the animation length. Defaults to 6 seconds.
    public var duration: TimeInterval = 6 // seconds

    /// Configure spacing between labels
    ///
    /// Use this to set the space between the first and second labels. Defaults to 50pt.
    public var spaceBetweenLabels: CGFloat = 50 { // points
        didSet {
            configure()
        }
    }

    // MARK: - Initialization

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
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

    // MARK: - Start/Stop Animation

    private func start() {
        guard let mainLabel = labels.first, mainLabel.bounds.width > bounds.width else { return }

        let labelWidth = mainLabel.bounds.width
        let delay = scrollDelay

        contentOffset = .zero

        UIView.animate(
            withDuration: duration,
            delay: scrollDelay + 0.5, // Initial delay should be a /bit/ longer to account for transitions to parent
            options: ([animationCurve]),
            animations: { [weak self] in
                guard let self = self else { return }
                self.contentOffset.x = labelWidth + self.spaceBetweenLabels
            },
            completion: { isCompleted in
                if isCompleted {
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                        self?.start() // recursive, must weakify self
                    }
                }
            }
        )
    }

    /// Scroll if needed
    ///
    /// This function will trigger the view to animate like a marquee, iff the size of the first label exceeds the width of the container. Otherwise it will only show the first label and do nothing.
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

    /// Stop all animations
    ///
    /// Stop all animation blocks and reset the state of the container view.
    public func stop() {
        contentOffset = .zero
        layer.removeAllAnimations()
    }

    private func configure() {
        // Stop all existing operation
        stop()

        // Relayout the labels
        layoutLabels()

        // Ensure the contentSize is accurate
        configureContentSize()
    }

    // MARK: - Configure Layout

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
            $0.font = font
            $0.sizeToFit()
            $0.frame = CGRect(x: offset, y: 0, width: $0.frame.width, height: bounds.height)
            $0.center = CGPoint(x: $0.center.x, y: round(center.y - frame.minY))

            offset += round($0.bounds.width) + spaceBetweenLabels
        }
    }

    private func configureContentSize() {
        guard let mainLabel = labels.first else { return }

        var size: CGSize = .zero
        size.width = mainLabel.bounds.width + bounds.width + spaceBetweenLabels
        size.height = bounds.height
        contentSize = size
    }

}