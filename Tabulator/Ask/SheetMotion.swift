import UIKit

/// Sheet entry: scale 0.96 to 1 plus fade. Reduce Motion keeps the fade.
class SheetMotionController: UIViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let reduced = UIAccessibility.isReduceMotionEnabled
        view.alpha = 0
        if !reduced {
            view.transform = CGAffineTransform(scaleX: Motion.sheetScale, y: Motion.sheetScale)
        }
        UIView.animate(withDuration: Motion.sheetDuration, delay: 0, options: [.curveEaseOut]) {
            self.view.alpha = 1
            self.view.transform = .identity
        }
    }
}
