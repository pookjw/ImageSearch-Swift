import UIKit
import SnapKit

// 화면에 알림창을 띄우는 View 입니다.

final class InfoView: UIView {
    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    
    static var view_idx: [Int] = []
    private var current_view_idx = 0
    
    enum TimerType: Int, CaseIterable {
        case one = 0, two, three, four, five
    }
    
    enum ViewType: Int, CaseIterable {
        case frame = 0, nslayoutconstraint, snapkit
    }
    
    static func loadFromNib() -> InfoView {
        //let nibName = "\(self)".split { $0 == "." }.map(String.init).last!
        let nibName = "InfoView"
        let nib = UINib(nibName: nibName, bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as! InfoView
    }
    
    static func showIn(viewController: UIViewController, message: String) {
        let currentView = loadFromNib()
        
        currentView.layer.masksToBounds = false
        currentView.layer.shadowColor = UIColor.darkGray.cgColor
        currentView.layer.shadowOpacity = 1
        currentView.layer.shadowOffset = CGSize(width: 0, height: 3)
        currentView.alpha = 0.0
        currentView.textLabel.text = message
        
        let (random_color, inversed_color) = UIColor.getRamdomColor()
        currentView.textLabel.textColor = random_color
        currentView.backgroundColor = inversed_color
        currentView.closeButton.tintColor = random_color
        
        //
        
        while view_idx.contains(currentView.current_view_idx) { currentView.current_view_idx += 1 }
        
        unowned let displayVC = viewController
        
        //        if let tabController = viewController as? UITabBarController {
        //            displayVC = tabController.selectedViewController ?? viewController
        //        }
        
        guard let superview = displayVC.view.superview else {
            return
        }
        superview.addSubview(currentView)
        let y = superview.frame.size.height - 200 - ((currentView.frame.size.height + 12) * CGFloat(currentView.current_view_idx))
        
        switch SettingsManager.infoview_type {
        case .frame:
            currentView.frame = CGRect(
                x: 12,
                y: y,
                width: superview.frame.size.width - 24,
                height: currentView.frame.size.height
            )
        case .nslayoutconstraint:
            currentView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                currentView.topAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.topAnchor, constant: y),
                currentView.leftAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.leftAnchor, constant: 12),
                currentView.rightAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.rightAnchor, constant: -12),
                currentView.heightAnchor.constraint(equalToConstant: currentView.frame.size.height)
            ])
        case .snapkit:
            currentView.snp.makeConstraints { (make) -> Void in
                make.top.equalTo(superview.safeAreaLayoutGuide).offset(y)
                make.left.equalTo(superview.safeAreaLayoutGuide).offset(12)
                make.right.equalTo(superview.safeAreaLayoutGuide).offset(-12)
                make.height.equalTo(currentView.frame.size.height)
            }
        }
        
        
        view_idx.append(currentView.current_view_idx)
        currentView.fadeIn()
        currentView.fadeOut_Timer()
    }
    
    @IBAction func closePressed(_ sender: UIButton) {
        fadeOut()
    }
    
    private func fadeIn() {
        UIView.animate(withDuration: 0.33, animations: { [weak self] in
            self?.alpha = 1.0
        })
    }
    
    deinit {
        if let idx = InfoView.view_idx.firstIndex(of: self.current_view_idx) {
            InfoView.view_idx.remove(at: idx)
        }
        if SettingsManager.show_deinit_log_message {
            print("deinit: InfoView")
        }
    }
    
    private func fadeOut_Timer() {
        switch SettingsManager.infoview_timer {
        case .one:
            var count = 0
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] timer in
                count += 1
                if count == 3 {
                    timer.invalidate()
                    self?.fadeOut()
                }
            })
        case .two:
            Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false, block: { [weak self] _ in
                self?.fadeOut()
            })
        case .three:
            DispatchQueue.global().asyncAfter(deadline: .now() + 3, execute: {
                DispatchQueue.main.async { [weak self] in
                    self?.fadeOut()
                }
            })
        case .four:
            self.perform(#selector(fadeOut), with: nil, afterDelay: 3.0)
        case .five:
            DispatchQueue.global().async { 
                Thread.sleep(forTimeInterval: 3.0)
                DispatchQueue.main.async { [weak self] in
                    self?.fadeOut()
                }
            }
        }
    }
    
    @objc private func fadeOut() {
        UIView.animate(withDuration: 0.33, animations: { [weak self] in
            self?.alpha = 0.0
            }, completion: { [weak self] _ in
                self?.removeFromSuperview()
        })
    }
}
