import XCTest
@testable import UIScrollLabel

class UIScrollLabelTests: XCTestCase {
	
	var scrollingLabel: UIScrollLabel?
	
	override func setUp() {
		super.setUp()
		scrollingLabel = UIScrollLabel(frame: CGRect(x: 0, y: 0, width: 320, height: 60), automaticallyScrollOnLoad: false)
		scrollingLabel?.text = "Hello"
	}
	
	override func tearDown() {
		scrollingLabel = nil
		super.tearDown()
	}
	
	func testAnimationDoesNotStartAutomatically() {
		XCTAssert(scrollingLabel?.isScrolling == false)
	}
	
	func testTextValue() {
		XCTAssert(scrollingLabel?.text == "Hello")
	}
	
	func testFontValue() {
		scrollingLabel?.font = UIFont.systemFont(ofSize: 40)
		XCTAssert(scrollingLabel?.font.pointSize == 40)
	}
	
	func testTextColorValue() {
		scrollingLabel?.textColor = UIColor.green
		XCTAssert(scrollingLabel?.textColor == UIColor.green)
	}
	
	func testScrollSpeedValue() {
		scrollingLabel?.scrollSpeed = 100 // seconds
		XCTAssert(scrollingLabel?.scrollSpeed == 100)
	}
	
	func testSpaceBetweenLabels() {
		scrollingLabel?.spaceBetweenLabels = 100 // points
		XCTAssert(scrollingLabel?.spaceBetweenLabels == 100)
	}
	
	func testScrollDirection() {
		scrollingLabel?.scrollDirection = .right
		XCTAssert(scrollingLabel?.scrollDirection == .right)
		
		scrollingLabel?.scrollDirection = .left
		XCTAssert(scrollingLabel?.scrollDirection == .left)
	}
	
	func testAnimationShouldNotStart() {
		scrollingLabel?.scrollIfNeeded()
		
		eventually(timeout: 1) { [weak self] in
			XCTAssert(self?.scrollingLabel?.isScrolling == false)
		}
	}
	
	func testAnimationShouldStart() {
		scrollingLabel?.text = "Welcome to Metro. This is a Belgrave Limited Express Service, stopping all stations except East Richmond."
		scrollingLabel?.scrollIfNeeded()
		
		eventually(timeout: 2) { [weak self] in
			XCTAssert(self?.scrollingLabel?.isScrolling == true)
		}
	}
	
	func testAnimationCurve() {
		scrollingLabel?.animationCurve = .curveLinear
		
		eventually { [weak self] in
			XCTAssert(self?.scrollingLabel?.animationCurve == .curveLinear)
		}
	}
	
	func testAnimationShouldStop() {
		scrollingLabel?.stop()
		
		eventually { [weak self] in
			XCTAssert(self?.scrollingLabel?.isScrolling == false)
		}
	}
	
	func testDeallocatesProperly() {
		scrollingLabel = nil
		
		eventually { [weak self] in
			XCTAssertNil(self?.scrollingLabel)
		}
	}
	
}

extension XCTestCase {
	
	/// Simple helper for asynchronous testing.
	/// Usage in XCTestCase method:
	///   func testSomething() {
	///       doAsyncThings()
	///       eventually {
	///           /* XCTAssert goes here... */
	///       }
	///   }
	/// Cloure won't execute until timeout is met. You need to pass in an
	/// timeout long enough for your asynchronous process to finish, if it's
	/// expected to take more than the default 0.01 second.
	///
	/// - Parameters:
	///   - timeout: amout of time in seconds to wait before executing the
	///              closure.
	///   - closure: a closure to execute when `timeout` seconds has passed
	func eventually(timeout: TimeInterval = 0.01, closure: @escaping () -> Void) {
		let expectation = self.expectation(description: "")
		expectation.fulfillAfter(timeout)
		self.waitForExpectations(timeout: 60) { _ in
			closure()
		}
	}
}

extension XCTestExpectation {
	
	/// Call `fulfill()` after some time.
	///
	/// - Parameter time: amout of time after which `fulfill()` will be called.
	func fulfillAfter(_ time: TimeInterval) {
		DispatchQueue.main.asyncAfter(deadline: .now() + time) {
			self.fulfill()
		}
	}
}
