//
//  PatientViewController.swift
//  Doctor ElBalto
//
//  Created by Abanoub Osama on 6/19/18.
//  Copyright © 2018 Abanoub Osama. All rights reserved.
//

import UIKit
import AVKit

class PatientViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, ContentDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var imageviewProfilePic: CircularImageView!
    @IBOutlet weak var textFieldFirstName: UITextField!
    @IBOutlet weak var textFieldLastName: UITextField!
    
    @IBOutlet weak var textFieldPhone: UITextField!
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var labelGender: UILabel!
    
    private let imagePicker = UIImagePickerController()
    
    private var loadingView: LoadingView!
    
    private var content: ContentSession!
    
    private var user: User!
    
    private var newProfileImage: UIImage!
    
    private var newPassword: String!
    
    private var isConfirm = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingView = LoadingView(frame: view.frame)
        loadingView.setLoadingImage(image: UIImage(named: "loading")!)
        loadingView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        loadingView.isHidden = true
        self.view.addSubview(loadingView)
        
        content = ContentSession(delegate: self)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissMyKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        imagePicker.delegate = self
        
        let userId = SettingsManager().getUserId()
        content.getUserData(userId: userId)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.topItem?.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "profile", comment: "")
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                
            self.newProfileImage = image
            imageviewProfilePic.image = newProfileImage
        }
        
        self.dismiss(animated: true , completion: nil)
    }
    
    @IBAction func changeImage(_ sender: UIButton) {
        
        var alert = UIAlertController(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "choose_image", comment: ""), message: nil, preferredStyle: .actionSheet)
        
        let hasCamera = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
        
        let hasGallery = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum)
        
        if hasCamera {
            
            let cameraAction = UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "camera", comment: ""), style: .default, handler: { _ in
                
                let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
                
                switch authStatus {
                case .authorized , .notDetermined :
                    
                    self.imagePicker.sourceType = UIImagePickerControllerSourceType.camera
                    
                    self.imagePicker.allowsEditing = false
                    
                    self.present(self.imagePicker, animated: false, completion: nil)
                    break
                default :
                    
                    Toast.showAlert(viewController: self, title: "", text:  LocalizationSystem.sharedInstance.localizedStringForKey(key:"camera_req", comment: ""), style: UIAlertControllerStyle.alert, UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key:"ok", comment: ""), style: .default, handler: { (action) in
                        
                        //go to permissions
                        UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
                    }), UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key:"cancel", comment: ""), style: .default, handler: nil))
                    
                    break
                }
            })
            
            alert.addAction(cameraAction)
        }
        
        if hasGallery {
            
            let galleryAction = UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key:"gallery", comment: ""), style: .default, handler: { _ in
                
                self.imagePicker.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum;
                self.imagePicker.allowsEditing = false
                
                self.present(self.imagePicker, animated: false, completion: nil)
            })
            
            alert.addAction(galleryAction)
        }
        
        if !hasGallery && !hasCamera {
            
            alert = UIAlertController(title: "No image source available", message: nil, preferredStyle: .actionSheet)
        }
        
        alert.addAction(UIAlertAction.init(title: LocalizationSystem.sharedInstance.localizedStringForKey(key:"cancel", comment: ""), style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func confirm(_ sender: UIButton) {
        
        let user = User()
        var shouldUpdate = false
        isConfirm = true
        
        if let name = textFieldFirstName.text, !name.isEmpty {
            
            user.firstName = name
            
            shouldUpdate = true
        } else {
        
            Toast.showAlert(viewController: self, text: LocalizationSystem.sharedInstance.localizedStringForKey(key:"first_name_empty", comment: ""))
            return
        }
        
        if let name = textFieldLastName.text, !name.isEmpty {
            
            user.lastName = name
            
            shouldUpdate = true
        } else {
            
            Toast.showAlert(viewController: self, text: LocalizationSystem.sharedInstance.localizedStringForKey(key:"last_name_empty", comment: ""))
            return
        }
        
        let email = textFieldEmail.text!
        if email.isEmpty {
            
            Toast.showAlert(viewController: self, text: LocalizationSystem.sharedInstance.localizedStringForKey(key:"mail_empty", comment: ""))
            return
        } else if email.range(of:  "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}", options: .regularExpression, range: nil, locale: nil) == nil {
            
            Toast.showAlert(viewController: self, text: LocalizationSystem.sharedInstance.localizedStringForKey(key:"enter_valid_email", comment: ""))
            return
        } else {
            
            user.email = email
            shouldUpdate = true
        }
        
        let phone = textFieldPhone.text!
        if phone.isEmpty {
            
            Toast.showAlert(viewController: self, text: LocalizationSystem.sharedInstance.localizedStringForKey(key: "phone_empty", comment: ""))
            return
        } else if phone.range(of:  "^[+2\\d]{11,}$", options: .regularExpression, range: nil, locale: nil) == nil {
            Toast.showAlert(viewController: self, text: LocalizationSystem.sharedInstance.localizedStringForKey(key: "phone_invalid", comment: ""))
            return
        } else {
            
            user.phone = phone
            shouldUpdate = true
        }
        
        
        if shouldUpdate {
            content.updateUser(user: user, profileImage: newProfileImage)
        }
    }
    
    @IBAction func chnagePassword(_ sender: UIButton) {
        
        var alert: UIAlertController!
        
        alert = Toast.showAlert(viewController: self, text: LocalizationSystem.sharedInstance.localizedStringForKey(key: "change_password", comment: ""), fieldHints: [LocalizationSystem.sharedInstance.localizedStringForKey(key: "old_password", comment: ""), LocalizationSystem.sharedInstance.localizedStringForKey(key: "new_password", comment: ""), LocalizationSystem.sharedInstance.localizedStringForKey(key: "confirm_password", comment: "")], UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "cancel", comment: ""), style: .cancel, handler: nil), UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "submit", comment: ""), style: .default, handler: { (action) in
            
            let textFieldOldPassword = alert.textFields![0]
            let textFieldNewPassword = alert.textFields![1]
            let textFieldConfPassword = alert.textFields![2]
            
            let oldPassword = textFieldOldPassword.text!
            let password = textFieldNewPassword.text!
            let confPassword = textFieldConfPassword.text!
            
            let settingsManager = SettingsManager()
            
            if oldPassword.compare(settingsManager.getPassword()) != .orderedSame {
                
                Toast.showAlert(viewController: self, text: LocalizationSystem.sharedInstance.localizedStringForKey(key: "WrongPassword", comment: "")) { (action) in
                    
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }
            
            if password.count < 8 {
                
                Toast.showAlert(viewController: self, text: LocalizationSystem.sharedInstance.localizedStringForKey(key: "WrongPassword", comment: "")) { (action) in
                    
                    self.present(alert, animated: true, completion: nil)
                }
                return
            } else if password.count > 16 {
                
                Toast.showAlert(viewController: self, text: LocalizationSystem.sharedInstance.localizedStringForKey(key: "password_long", comment: "")) { (action) in
                    
                    self.present(alert, animated: true, completion: nil)
                }
                return
            } else if password.compare(confPassword) != .orderedSame {
                
                Toast.showAlert(viewController: self, text: LocalizationSystem.sharedInstance.localizedStringForKey(key: "WrongPassword", comment: "")) { (action) in
                    
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }
            
            self.newPassword = password
            self.content.changePassword(to: password)
        }))
        
        for textField in alert.textFields! {
            
            textField.isSecureTextEntry = true
        }
    }
    
    func display(user: User) {
        self.user = user
        
        if let image = user.image, !image.isEmpty {
            
            imageviewProfilePic.sd_setImage(with: URL(string: image), completed: nil)
        } else {
            
            imageviewProfilePic.image = UIImage(named: "logo_profile")
        }
        
        textFieldFirstName.text = user.firstName
        textFieldLastName.text = user.lastName
        
        if let phone = user.phone {
            
            textFieldPhone.text = phone
        } else {
            
            textFieldPhone.text = "..."
        }
        
        textFieldEmail.text = user.email ?? "..."
        labelGender.text = user.gender?.name ?? "..."
    }
    
    func onPreExecute(action: ContentSession.ActionType) {
        loadingView.setIsLoading(true)
    }
    
    
    
    func onPostExecute(status: BaseUrlSession.Status, action: ContentSession.ActionType, response: Any!) {
        loadingView.setIsLoading(false)
        if status.success {
            
            switch action {
            case .updateUser:
                
                if let password = newPassword {
                    
                    let settingsManager = SettingsManager()
                    settingsManager.setPassword(value: password)
                    self.newPassword = nil
                }
                
                if let _ = newProfileImage {
                    
                    newProfileImage = nil
                }
                
                content.getUserData(userId: user.id)
                break
            case .getUserData:
                
                if isConfirm {
                    
                    // Nav to Home
                    let main = UIStoryboard(name: "Main", bundle: nil)
                    let vc = main.instantiateInitialViewController()
                    
                    let window = UIApplication.shared.keyWindow!
                    
                    window.rootViewController = vc
                    window.makeKeyAndVisible()
                } else {
                    
                    let user = response as! User
                    
                    let manager = SettingsManager()
                    manager.updateUser(user: user)
                    
                    display(user: user)
                }
                break
            default:
                break
            }
        } else {
            Toast.showAlert(viewController: self, text: status.message)
            self.newPassword = nil
        }
    }
    
    @objc func dismissMyKeyboard() {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification:NSNotification) {
        //give room at the bottom of the scroll view, so it doesn't cover up anything the user needs to tap
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        self.scrollView.contentInset = contentInset
        self.scrollView.contentOffset = CGPoint(x: 0, y: keyboardFrame.size.height)
    }
    
    @objc func keyboardWillHide(notification:NSNotification) {
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        self.scrollView.contentInset = contentInset
    }
}
