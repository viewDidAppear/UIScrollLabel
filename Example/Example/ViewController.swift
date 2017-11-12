import UIKit
import UIScrollLabel

class ViewController: UIViewController {
	
	@IBOutlet private var pid: UIScrollLabel!

	override func viewDidLoad() {
		super.viewDidLoad()
		pid.font = UIFont.boldSystemFont(ofSize: 30)
		pid.animationCurve = .curveEaseInOut
		pid.backgroundColor = .black
	}

}

