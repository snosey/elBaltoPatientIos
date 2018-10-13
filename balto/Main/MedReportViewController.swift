//
//  MedReportViewController.swift
//  balto
//
//  Created by Abanoub Osama on 4/24/18.
//  Copyright © 2018 Abanoub Osama. All rights reserved.
//

import UIKit

class MedReportViewController: UIViewController {
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelSpecialization: UILabel!
    
    @IBOutlet weak var imageViewProfile: UIImageView!
    
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelDate: UILabel!
    
    @IBOutlet weak var textViewDaignosis: UITextView!
    @IBOutlet weak var textViewPrescription: UITextView!
    
    private var reservation: Reservation!
    
    public class func getInstance(reservation: Reservation) -> MedReportViewController {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MedReportViewController") as! MedReportViewController
        vc.reservation = reservation
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        labelTitle.text = reservation?.name ?? "--"
        labelSpecialization.text = reservation.subCategoryName
        
        labelName.text = SettingsManager().getFullName()
        
        if let date = reservation?.date, !date.isEmpty {
            
            let split = date.components(separatedBy: " ")
            
            labelDate.text = split[0]
        } else {
        
            labelDate.text = "--"
        }
        
        if let diagnosis = reservation.diagnosis, !diagnosis.isEmpty {
            
            textViewDaignosis.text = diagnosis
        } else {
            textViewDaignosis.text = "--"
        }
        
        if let medication = reservation.medication, !medication.isEmpty {
            
            textViewPrescription.text = medication
        } else {
            textViewPrescription.text = "--"
        }

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.topItem?.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "med_report", comment: "")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.topItem?.title = ""
    }
}
