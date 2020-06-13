import UIKit

class InfoView: UIView {
    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    
    static var view_idx: [Int] = []
    var current_view_idx = 0
    
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
        
        let currentView = loadFromNib()
        
        currentView.layer.masksToBounds = false
        currentView.layer.shadowColor = UIColor.darkGray.cgColor
        currentView.layer.shadowOpacity = 1
        currentView.layer.shadowOffset = CGSize(width: 0, height: 3)
        currentView.textLabel.text = "\(message)"
        
        let (random_color, inversed_color) = UIColor.getRamdomColor()
        
        currentView.textLabel.textColor = random_color
        currentView.backgroundColor = inversed_color
        currentView.closeButton.tintColor = random_color
        
        while view_idx.contains(currentView.current_view_idx) { currentView.current_view_idx += 1 }
        let y = currentView.frame.size.height + 70 + CGFloat(80 * (currentView.current_view_idx + 1))
        
        currentView.frame = CGRect(
            x: 12,
            y: y,
            width: displayVC.view.frame.size.width - 24,
            height: currentView.frame.size.height
        )
        
        currentView.alpha = 0.0
        
        displayVC.view.addSubview(currentView)
        view_idx.append(currentView.current_view_idx)
        currentView.fadeIn()
        
        switch timer {
        case .one:
            var count = 0
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { timer in
                count += 1
                if count == 3 {
                    timer.invalidate()
                    currentView.fadeOut()
                    if let idx = view_idx.firstIndex(of: currentView.current_view_idx) {
                        view_idx.remove(at: idx)
                    }
                }
            })
        case .two:
            Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false, block: { _ in
                currentView.fadeOut()
                if let idx = view_idx.firstIndex(of: currentView.current_view_idx) {
                    view_idx.remove(at: idx)
                }
            })
        case .three:
            DispatchQueue.global().asyncAfter(deadline: .now() + 3, execute: {
                DispatchQueue.main.async {
                    currentView.fadeOut()
                    if let idx = view_idx.firstIndex(of: currentView.current_view_idx) {
                        view_idx.remove(at: idx)
                    }
                }
            })
        case .four:
            currentView.perform(#selector(fadeOut), with: nil, afterDelay: 3.0)
            DispatchQueue.global().asyncAfter(deadline: .now() + 3, execute: {
                DispatchQueue.main.async {
                    if let idx = view_idx.firstIndex(of: currentView.current_view_idx) {
                        view_idx.remove(at: idx)
                    }
                }
            })
        case .five:
            DispatchQueue.global().async {
                Thread.sleep(forTimeInterval: 3.0)
                DispatchQueue.main.async {
                    currentView.fadeOut()
                    if let idx = view_idx.firstIndex(of: currentView.current_view_idx) {
                        view_idx.remove(at: idx)
                    }
                }
            }
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
        UIView.animate(withDuration: 0.33, animations: { [weak self] in
            self?.alpha = 0.0
        }, completion: { [weak self] _ in
            self?.removeFromSuperview()
        })
    }
    
    enum TimerType: Int, CaseIterable {
        case one = 0, two, three, four, five
    }
}
