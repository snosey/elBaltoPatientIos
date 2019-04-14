import UIKit

class PopupHandler {
    
    static let mainSB = UIStoryboard(name: "حopup", bundle: nil)
    
    static var forget: UIViewController {
        get {
            return mainSB.instantiateInitialViewController()!
        }
    }
    
    static var choose: UIViewController {
        get {
            return mainSB.instantiateInitialViewController()!
        }
    }
    
}


