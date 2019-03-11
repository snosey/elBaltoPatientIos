//
//  ProfileViewController.swift
//  balto
//
//  Created by Abanoub Osama on 4/18/18.
//  Copyright © 2018 Abanoub Osama. All rights reserved.
//

import UIKit
import SDWebImage

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,  UINavigationControllerDelegate, UIImagePickerControllerDelegate, ContentDelegate {
    
    @IBOutlet weak var imageviewProfilePic: CircularImageView!
    @IBOutlet weak var textFieldName: UITextField!
    @IBOutlet weak var labelSpecialization: UILabel!
    @IBOutlet weak var labelRate: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var labelGender: UILabel!
    
    private var loadingView: LoadingView!
    
    private var content: ContentSession!
    
    private var doctor: Doctor!
    private var reviews = [Review]()
    
    private var oldDocs = [BaseModel]()
    
    var doctorId: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "ReviewTableCell", bundle: nil), forCellReuseIdentifier: "ReviewCell")
        tableView.register(UINib(nibName: "DocTableCell", bundle: nil), forCellReuseIdentifier: "DocCell")
        tableView.estimatedRowHeight = 220
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedSectionHeaderHeight = 120
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        
        loadingView = LoadingView(frame: view.frame)
        loadingView.setLoadingImage(image: UIImage(named: "loading")!)
        loadingView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        loadingView.isHidden = true
        self.view.addSubview(loadingView)
        
        content = ContentSession(delegate: self)
        
        content.getDoctor(doctorId: doctorId)
        content.getReviewsBy(doctorId: doctorId)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.topItem?.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "profile", comment: "")
    }
    
    func display(doctor: Doctor) {
        self.doctor = doctor
        
        if let image = doctor.image, !image.isEmpty {
            
            imageviewProfilePic.sd_setImage(with: URL(string: image), completed: nil)
        } else {
            
            imageviewProfilePic.image = UIImage(named: "profilePic")
        }
        
        textFieldName.text = doctor.name
        labelSpecialization.text = doctor.specialization?.name ?? "..."
        
        labelRate.text = "\(doctor.rate ?? 0)"
        
        labelGender.text = doctor.gender?.name ?? "..."
        
        oldDocs = doctor.documents
    }
    
    // start of tableView's datasource and delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = ProfileSectionHeaderView.instantiateFromNib(named: "ProfileSectionHeaderView")
        
        if section == 0 {
            
            view.labelName.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "reviews", comment: "")
        } else {
            
            view.labelName.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "certifications", comment: "")
        }
        
        return view
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            
            return reviews.count
        } else {
            
            return oldDocs.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell!
        
        if indexPath.section == 0 {
            
            let reviewCell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath) as! ReviewTableCell
            
            reviewCell.setDetails(review: reviews[indexPath.row])
            
            cell = reviewCell
        } else {
            
            let docCell = tableView.dequeueReusableCell(withIdentifier: "DocCell", for: indexPath) as! DocTableCell
            
            docCell.setDetails(self, url: oldDocs[indexPath.row].name)
            
            cell = docCell
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    // end of tableView's datasource and delegate
    
    func onPreExecute(action: ContentSession.ActionType) {
        loadingView.setIsLoading(true)
    }
    
    func onPostExecute(status: BaseUrlSession.Status, action: ContentSession.ActionType, response: Any!) {
        loadingView.setIsLoading(false)
        if status.success {
            
            switch action {
            case .getDoctorData:
                
                let doctor = response as! Doctor
                
                display(doctor: doctor)
                
                content.getReviewsBy(doctorId: doctor.id)
                break
            case .getDoctorReviews:
                
                reviews = response as! [Review]
                
                tableView.reloadData()
                break
            default:
                break
            }
        } else {
            Toast.showAlert(viewController: self, text: status.message)
        }
    }
}

