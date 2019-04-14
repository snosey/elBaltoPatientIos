//
//  chatViewController.swift
//  ElBalto
//
//  Created by rocky on 2/25/19.
//  Copyright © 2019 Abanoub Osama. All rights reserved.
//

import UIKit
import SwiftyJSON
import PusherSwift

let options = PusherClientOptions(
    host: .cluster("eu")
)

let pusher = Pusher(
    key: "32f543d2159b6dfb9892",
    options: options
)

// subscribe to channel and bind to event
let channel = pusher.subscribe("my-channel")


fileprivate let nib_left_identitifer = "leftChatTableViewCell"
fileprivate let nib_right_identitifer = "rightChatTableViewCell"
fileprivate let seperator_identitifer = "separatorTableViewCell"

class chatViewController: UIViewController , UINavigationControllerDelegate {

    @IBOutlet weak var classTableView: UITableView!
    @IBOutlet weak var messageTf: UITextField!
    var messages = [JSON]()
    var id_chat: Int?
    var imagePicker = UIImagePickerController() // UIimage picker set it's delegate to self
    var loadingView: LoadingView!
    var id_doctor: Doctor!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        classTableView.allowsSelection = false
        classTableView.register(UINib(nibName: nib_right_identitifer, bundle: nil), forCellReuseIdentifier: nib_right_identitifer)
        classTableView.register(UINib(nibName: nib_left_identitifer, bundle: nil), forCellReuseIdentifier: nib_left_identitifer)
        classTableView.register(UINib(nibName: seperator_identitifer, bundle: nil), forCellReuseIdentifier: seperator_identitifer)
        
        imagePicker.delegate = self
        // classTableView.transform = CGAffineTransform(rotationAngle: -(CGFloat)(Double.pi));
        
        loadingView = LoadingView(frame: view.frame)
        loadingView.setLoadingImage(image: UIImage(named: "loading")!)
        loadingView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        loadingView.isHidden = true
        self.view.addSubview(loadingView)
        
        let _ = channel.bind(eventName: "my-event", callback: { (data: Any?) -> Void in
            if let data = data as? [String : AnyObject] {
                let message = JSON(data)
                self.messages.append(message)
                self.classTableView.reloadData()
            }
        })
        
        pusher.connect()
        self.title = self.id_doctor.name
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.loadingView.setIsLoading(true)
        if id_chat != nil {
            let params = [
                "id_chat": Int(id_chat!)
            ] as [String: Any]
            
            DoctorsAPIS.getMessagesInChat(params: params) { (json, error) in
                let data = JSON(json)
                if let messages = data["chats"]["messages"].array {
                    self.messages = messages
                    let lang = LocalizationSystem.sharedInstance.getLanguage()
                    let first_name = data["chats"]["doctor"]["first_name_\(lang)"].string ?? ""
                    let last_name = data["chats"]["doctor"]["last_name_\(lang)"].string ?? ""
                    self.title = first_name + " " + last_name
                    self.classTableView.reloadData()
                }
                self.loadingView.setIsLoading(false)
            }
        }else {
            // create a new chat in case the user can create a chat
            
            let params = [
                "id_patient": SettingsManager().getUserId(),
                "id_doctor": self.id_doctor.id,
                "Fk_SecondCategoryProgram": self.id_doctor.specialization.id,
            ] as [String: Any]
            
            DoctorsAPIS.createChat(params: params) { (json, error) in
                if error == nil {
                    let data = JSON(json)
                    if let id_chat = data["chat"]["id"].int {
                        self.id_chat = id_chat
                    }else {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
            self.loadingView.setIsLoading(false)
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    @IBAction func sendMessage(_ sender: UIButton) {
        if sender.tag == 0 { // send
            guard let message = self.messageTf.text, message.isEmpty == false else { return }
            let params = [
                "user_id": SettingsManager().getUserId(),
                "id_chat": Int(id_chat!),
                "message": message,
            ] as [String: Any]
            print(params)
            
            addMessageRequest(params: params)
        }else if sender.tag == 1 { // file
        
            Messenger.alertWithActions(self, nil, message: "Choose Image", style: .actionSheet, actions: ["Gallery": .default, "Camera": .default, "Cancel": .cancel]) { (name) in
                if name == "Gallery" {
                    self.openGallary(imagePicker: self.imagePicker)
                } else if name == "Camera" {
                    self.openCamera(imagePicker: self.imagePicker)
                }
            }
            
        } // end of else if
        
    }
    
    func addMessageRequest(params: [String: Any]) {
        
        DoctorsAPIS.createMessage(params: params) { (json, error) in
            print("error is \(error != nil)")
            if error == nil {
                let message = JSON(json)
                print(message["message"])
                self.messages.append(message["message"])
                self.classTableView.reloadData()
            }
        }
    }
    
}

extension chatViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ( messages.count * 2 )
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row % 2 == 0 {
            let num = indexPath.row / 2
            let message = messages[num]

            if ( SettingsManager().getUserId() == (message["user_id"].int ?? 0) ) {
                let cell = tableView.dequeueReusableCell(withIdentifier: nib_right_identitifer, for: indexPath) as! rightChatTableViewCell
                if let file = message["file_name"].string {
                    cell.configCell(message: file)
                }else {
                    cell.configCell(message: message["message"].string!)
                }
                // cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
                return cell
            }else {
                let cell = tableView.dequeueReusableCell(withIdentifier: nib_left_identitifer, for: indexPath) as! leftChatTableViewCell
                if let file = message["file_name"].string {
                    cell.configCell(message: file)
                }else {
                    
                    cell.configCell(message: message["message"]["message"].string!)
                }
                // cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
                return cell
            }
            
        }else {
            return tableView.dequeueReusableCell(withIdentifier: seperator_identitifer, for: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row % 2 == 0 {
            return UITableViewAutomaticDimension
        }else {
            return 3
        }
    }
    
}


extension chatViewController: UIImagePickerControllerDelegate {
  
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
             dismiss(animated: true) {
                 let params = [
                     "user_id": SettingsManager().getUserId(),
                     "id_chat": Int(self.id_chat!),
                     "file_name": DoctorsAPIS.imageToBase64(image: image)!,
                     "file_type": "png"
                 ] as [String: Any]
                
                 print(params)
                
                 self.addMessageRequest(params: params)
             }

        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}
