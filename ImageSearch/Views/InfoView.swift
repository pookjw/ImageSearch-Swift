import UIKit

class InfoView: UIView {
    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    
    static var sharedView: InfoView!
    
    static func loadFromNib() -> InfoView {
        let nibName = "\(self)".split { $0 == "." }.map(String.init).last!
        let nib = UINib(nibName: nibName, bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as! InfoView
    }
    
    static func showIn(viewController: UIViewController, message: String) {
        var displayVC = viewController
        
        if let tabController = viewController as? UITabBarController {
            displayVC = tabController.selectedViewController ?? viewController
        }
        
        if sharedView == nil {
            sharedView = loadFromNib()
            
            sharedView.layer.masksToBounds = false
            sharedView.layer.shadowColor = UIColor.darkGray.cgColor
            sharedView.layer.shadowOpacity = 1
            sharedView.layer.shadowOffset = CGSize(width: 0, height: 3)
        }
        
        sharedView.textLabel.text = message
        
        let (random_color, inversed_color) = getRamdomColor()
        
        sharedView.textLabel.textColor = random_color
        sharedView.backgroundColor = inversed_color
        sharedView.closeButton.tintColor = random_color
        
        if sharedView?.superview == nil {
            let y = displayVC.view.frame.height - sharedView.frame.size.height - 60
            
            sharedView.frame = CGRect(
                x: 12,
                y: y,
                width: displayVC.view.frame.size.width - 24,
                height: sharedView.frame.size.height
            )
            
            sharedView.alpha = 0.0
            
            displayVC.view.addSubview(sharedView)
            sharedView.fadeIn()
            
            sharedView.perform(#selector(fadeOut), with: nil, afterDelay: 3.0)
        }
    }
    
    @IBAction func closePressed(_ sender: UIButton) {
        fadeOut()
    }
    
    func fadeIn() {
        UIView.animate(withDuration: 0.33, animations: {
            self.alpha = 1.0
        })
    }
    
    @objc func fadeOut() {
        
        // [1] Counter balance previous perform:with:afterDelay
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        
        UIView.animate(withDuration: 0.33, animations: {
            self.alpha = 0.0
        }, completion: { _ in
            self.removeFromSuperview()
        }
        )
    }
    
    static func getRamdomColor() -> (UIColor, UIColor) {
        let r = CGFloat(arc4random_uniform(256)) / 255
        let g = CGFloat(arc4random_uniform(256)) / 255
        let b = CGFloat(arc4random_uniform(256)) / 255
        return (UIColor(red: r, green: g, blue: b, alpha: 1.0), UIColor(red: 1-r, green: 1-g, blue: 1-b, alpha: 1.0))
    }
}
