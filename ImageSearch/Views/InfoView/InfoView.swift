import UIKit

class InfoView: UIView {
    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    
    static var currentViewCount: [Int] = []
    
    static func loadFromNib() -> InfoView {
        let nibName = "\(self)".split { $0 == "." }.map(String.init).last!
        let nib = UINib(nibName: nibName, bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as! InfoView
    }
    
    static var timer: TimerType = .two
    
    static func showIn(viewController: UIViewController, message: String) {
        unowned var displayVC = viewController
        
        if let tabController = viewController as? UITabBarController {
            displayVC = tabController.selectedViewController ?? viewController
        }
        
        unowned let currentView = loadFromNib()
        
        currentView.layer.masksToBounds = false
        currentView.layer.shadowColor = UIColor.darkGray.cgColor
        currentView.layer.shadowOpacity = 1
        currentView.layer.shadowOffset = CGSize(width: 0, height: 3)
        currentView.textLabel.text = "\(message)"
        
        let (random_color, inversed_color) = getRamdomColor()
        
        currentView.textLabel.textColor = random_color
        currentView.backgroundColor = inversed_color
        currentView.closeButton.tintColor = random_color
        
        //let y = displayVC.view.frame.height - currentView.frame.size.height - CGFloat(80 * (currentViewCount + 1))
        var current_view_idx = 0
        while currentViewCount.contains(current_view_idx) { current_view_idx += 1 }
        let y = currentView.frame.size.height + CGFloat(80 * (current_view_idx + 1))
        
        currentView.frame = CGRect(
            x: 12,
            y: y,
            width: displayVC.view.frame.size.width - 24,
            height: currentView.frame.size.height
        )
        
        currentView.alpha = 0.0
        
        displayVC.view.addSubview(currentView)
        currentViewCount.append(current_view_idx)
        currentView.fadeIn()
        
        switch timer {
        case .one:
            var count = 0
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { timer in
                count += 1
                if count == 3 {
                    timer.invalidate()
                    currentView.fadeOut()
                    if let idx = currentViewCount.firstIndex(of: current_view_idx) {
                        currentViewCount.remove(at: idx)
                    }
                }
            })
        case .two:
            Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false, block: { _ in
                currentView.fadeOut()
                if let idx = currentViewCount.firstIndex(of: current_view_idx) {
                    currentViewCount.remove(at: idx)
                }
            })
        case .three:
            DispatchQueue.global().asyncAfter(deadline: .now() + 3, execute: {
                DispatchQueue.main.async {
                    currentView.fadeOut()
                    if let idx = currentViewCount.firstIndex(of: current_view_idx) {
                        currentViewCount.remove(at: idx)
                    }
                }
            })
        case .four:
            currentView.perform(#selector(fadeOut), with: nil, afterDelay: 3.0)
        }
    }
    
    @IBAction func closePressed(_ sender: UIButton) {
        fadeOut()
    }
    
    func fadeIn() {
        UIView.animate(withDuration: 0.33, animations: { [weak self] in
            self?.alpha = 1.0
        })
    }
    
//    deinit {
//        print("deinit!!!")
//    }
    
    @objc func fadeOut() {
//
//        // [1] Counter balance previous perform:with:afterDelay
//        NSObject.cancelPreviousPerformRequests(withTarget: self)
        
        UIView.animate(withDuration: 0.33, animations: { [weak self] in
            self?.alpha = 0.0
        }, completion: { [weak self] _ in
            self?.removeFromSuperview()
        }
        )
    }
    
    enum TimerType: Int, CaseIterable {
        case one = 0
        case two
        case three
        case four
    }
}
