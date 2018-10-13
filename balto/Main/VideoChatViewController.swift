//
//  VideoChatViewController.swift
//  balto
//
//  Created by Abanoub Osama on 4/11/18.
//  Copyright © 2018 Abanoub Osama. All rights reserved.
//

import UIKit
import TwilioVideo

class VideoChatViewController: UIViewController, TVIRoomDelegate, TVIRemoteParticipantDelegate, ContentDelegate {
    
    @IBOutlet weak var videoViewMe: TVIVideoView!
    @IBOutlet weak var videoViewParticipant: TVIVideoView!
    
    @IBOutlet weak var labelDuration: UILabel!
    
    @IBOutlet weak var buttonSwitchCamera: UIButton!
    
    @IBOutlet weak var buttonSpeaker: UIButton!
    
    @IBOutlet weak var buttonEndCall: UIButton!
    @IBOutlet weak var buttonMute: UIButton!
    @IBOutlet weak var buttonVideoCall: UIButton!
    
    private var content: ContentSession!
    
    private var videoToken: String!
    
    private var room: TVIRoom!
    
    private var dataTrack: TVILocalDataTrack!
    private var audioTrack: TVILocalAudioTrack!
    private var videoTrack: TVILocalVideoTrack!
    
    private var camera: TVICameraCapturer!
    private var audioDevice: TVIDefaultAudioDevice!

    private var reservation: Reservation!
    
    private var isSpeakerOn = true
    
    private var timerCountDown: Timer!
    
    private var reservationId: Int!
    
    private var participant: TVIParticipant!
    
    public class func getInstance(reservationId: Int) -> VideoChatViewController {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "VideoChatViewController") as! VideoChatViewController
        
        vc.reservationId = reservationId
        
        return vc
    }
    
    public class func getInstance(reservation: Reservation) -> VideoChatViewController {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "VideoChatViewController") as! VideoChatViewController
        
        vc.reservation = reservation
        
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonMute.imageView?.contentMode = .scaleToFill
        
        content = ContentSession(delegate: self)
        
        dataTrack = TVILocalDataTrack()
        
        audioTrack = TVILocalAudioTrack()
        
        if let reservation = reservation {
            
            let serviceDuration = reservation.serviceDuration!
            
            var endDate = DateUtils.getDate(dateString: reservation.date, dateFormat: "\(DateUtils.SERVER_DATE_FORMAT) \(DateUtils.SERVER_TIME_SHORT_FORMAT)")
            endDate = endDate.addingTimeInterval(TimeInterval(serviceDuration * 60))
            
            if endDate < Date() {
                
                endCall(buttonEndCall)
            } else {
                
                self.navigationController?.navigationBar.topItem?.title = reservation.name
                
                content.createRoom(bookingId: reservation.id)
            }
        } else if let reservationId = reservationId {
            
            content.bookingData(bookingId: reservationId)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
        if let res = reservation {
            
            self.navigationController?.navigationBar.topItem?.title = res.name
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.topItem?.title = ""
        UIApplication.shared.isIdleTimerDisabled = false
        
        if self.isMovingFromParentViewController {
            endCall(buttonEndCall)
        }
    }
    
    @IBAction func toggleMute(_ sender: UIButton) {
        
        if audioTrack.isEnabled {
            
            sender.setBackgroundImage(UIImage(named: "mute_ico"), for: .normal)
            audioTrack.isEnabled = false
        } else {
            
            sender.setBackgroundImage(UIImage(named: "unmute"), for: .normal)
            audioTrack.isEnabled = true
        }
    }
    
    @IBAction func endCall(_ sender: UIButton) {
        if let room = room {
        
            room.disconnect()
        }
        
        if let nav = self.navigationController {
            
            nav.popViewController(animated: true)
        } else {
            
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func switchCamera(_ sender: UIButton) {
        
        if let camera = camera {
            
            if camera.source == .frontCamera {
                
                camera.selectSource(.backCameraWide)
            } else {
                
                camera.selectSource(.frontCamera)
            }
        }
    }
    
    @IBAction func speaker(_ sender: UIButton) {
        
        if isSpeakerOn {
            
            audioDevice.block = {
                
                do {
                    kDefaultAVAudioSessionConfigurationBlock()
                    
                    let audioSession = AVAudioSession.sharedInstance()
                    try audioSession.setMode(AVAudioSessionModeVoiceChat)
                    
                    sender.setImage(UIImage(named: "13-speaker_off"), for: .normal)
                    
                    self.isSpeakerOn = false
                } catch let error as NSError {
                    print("Fail: \(error.localizedDescription)")
                }
            }
            audioDevice.block()
        } else {
            
            audioDevice.block = {
                
                do {
                    kDefaultAVAudioSessionConfigurationBlock()
                    
                    let audioSession = AVAudioSession.sharedInstance()
                    try audioSession.setMode(AVAudioSessionModeVideoChat)
                    
                    sender.setImage(UIImage(named: "13_speaker_on"), for: .normal)
                    
                    self.isSpeakerOn = true
                } catch let error as NSError {
                    print("Fail: \(error.localizedDescription)")
                }
            }
            audioDevice.block()
        }
    }
    
    @IBAction func videoCall(_ sender: UIButton) {
        
        if let videoTrack = videoTrack {
            
            if videoTrack.isEnabled {
                
                videoTrack.isEnabled = false
                
                self.buttonVideoCall.setImage(UIImage(named: "video_call-1_off"), for: .normal)
            } else {
                
                videoTrack.isEnabled = true
                
                self.buttonVideoCall.setImage(UIImage(named: "video_call-1"), for: .normal)
            }
        } else {
            
            Toast.showAlert(viewController: self, text: "Unable to use camera")
        }
    }
    
    func didConnect(to room: TVIRoom) {
        
        print("\n\(#file)@\(#function):\("")\n")
        
        if let participant = room.remoteParticipants.first {
            
            participant.delegate = self
            
            self.participant = participant
        }
    }
    
    func room(_ room: TVIRoom, participantDidConnect participant: TVIRemoteParticipant) {
        
        participant.delegate = self
        self.participant = participant

    }
    
    func room(_ room: TVIRoom, participantDidDisconnect participant: TVIRemoteParticipant) {
        
        print("\n\(#file)@\(#function):\(participant)\n")
        videoViewParticipant.isHidden = true
        if let participant = room.remoteParticipants.first {
            
            participant.delegate = self
            
            self.participant = participant
        }
    }
    
    func room(_ room: TVIRoom, didFailToConnectWithError error: Error) {
        
        print("\n\(#file)@\(#function):\((error as NSError).localizedDescription)\n")
    }
    
    func room(_ room: TVIRoom, didDisconnectWithError error: Error?) {
        
        if let error = error as? NSError {
            
            print("\n\(#file)@\(#function):\(error.localizedDescription)\n")
        }
    }
    
    func subscribed(to videoTrack: TVIRemoteVideoTrack, publication: TVIRemoteVideoTrackPublication, for participant: TVIRemoteParticipant) {
        
        videoTrack.addRenderer(videoViewParticipant)
        videoViewParticipant.isHidden = false
    }
    
    func startTimer(countDownInMins: Int) {
        
        labelDuration.text = String(format: "%02d:%02d", countDownInMins, 0)
        
        if #available(iOS 10.0, *) {
            
            if let timer = timerCountDown {
                
                timer.invalidate()
                timerCountDown = nil
            }
            
            timerCountDown = Timer.scheduledTimer(withTimeInterval: TimeInterval(1), repeats: true, block: { (timer) in
                
                let minsRemaining = (self.labelDuration.text!.components(separatedBy: ":")[0] as NSString).integerValue
                let secsRemaining = (self.labelDuration.text!.components(separatedBy: ":")[1] as NSString).integerValue
                
                var secs = minsRemaining * 60 + secsRemaining - 1
                let mins = secs / 60
                
                if let participant = self.participant, let track = participant.videoTracks.first {
                    
                    if track.isTrackEnabled {
                        
                        self.videoViewParticipant.isHidden = false
                    } else {
                        
                        self.videoViewParticipant.isHidden = true
                    }
                }
                
                if secs <= 0 {
                    
                    timer.invalidate()
                    self.timerCountDown = nil
                    
                    let vc = AddReviewViewController(bookingId: self.reservation.id, afterAction: { addReviewVC in
                        
                        addReviewVC.dismiss(animated: true, completion: nil)
                        
                        self.endCall(self.buttonEndCall)
                        
                        return true
                    })
                    
                    self.present(vc, animated: true, completion: nil)
                } else {
                    
                    if mins < 5 {
                        
                        self.labelDuration.textColor = UIColor.red
                    }
                    
                    self.labelDuration.text = String(format: "%02d:%02d", mins, secs % 60)
                }
            })
        } else {
            // Fallback on earlier versions
        }
    }
    
    func onPreExecute(action: ContentSession.ActionType) {
    }
    
    func onPostExecute(status: BaseUrlSession.Status, action: ContentSession.ActionType, response: Any!) {
        if status.success {
            
            switch action {
            case .getBookingData:
                
                if reservation == nil {
                    
                    self.reservation = response as! Reservation
                    
                    let serviceDuration = reservation.serviceDuration!
                    
                    var endDate = DateUtils.getDate(dateString: reservation.date, dateFormat: "\(DateUtils.SERVER_DATE_FORMAT) \(DateUtils.SERVER_TIME_SHORT_FORMAT)")
                    endDate = endDate.addingTimeInterval(TimeInterval(serviceDuration * 60))
                    
                    if endDate < Date() {
                        
                        endCall(buttonEndCall)
                    } else {
                        
                        self.navigationController?.navigationBar.topItem?.title = reservation.name
                        
                        content.createRoom(bookingId: reservation.id)
                    }
                }
                break
            case .createRoom:
                
                self.videoToken = response as! String
                
                let serviceDuration = reservation.serviceDuration!
                
                var endDate = DateUtils.getDate(dateString: reservation.date, dateFormat: "\(DateUtils.SERVER_DATE_FORMAT) \(DateUtils.SERVER_TIME_SHORT_FORMAT)")
                endDate = endDate.addingTimeInterval(TimeInterval(serviceDuration * 60))
                
                let remaining = endDate.timeIntervalSince1970 - Date().timeIntervalSince1970
                
                self.startTimer(countDownInMins: Int(remaining / 60))
                
                let connectOptions = TVIConnectOptions.init(token: videoToken) { (builder) in
                    
                    builder.roomName = String(self.reservation.id)
                    
                    if let dataTrack = self.dataTrack {
                        builder.dataTracks = [dataTrack]
                    }
                    
                    if let audioTrack = self.audioTrack {
                        
                        builder.audioTracks = [audioTrack]
                        self.audioDevice = TVIDefaultAudioDevice()
                    }
                    
                    if let camera = TVICameraCapturer(source: .frontCamera) {
                        self.camera = camera
                        
                        if let videoTrack = TVILocalVideoTrack(capturer: camera) {
                            self.videoTrack = videoTrack
                            
                            videoTrack.addRenderer(self.videoViewMe)
                            
                            builder.videoTracks = [videoTrack]
                            
                            self.buttonVideoCall.setImage(UIImage(named: "video_call-1"), for: .normal)
                        }
                    }
                }
                
                room = TwilioVideo.connect(with: connectOptions, delegate: self)
                
                if reservation.stateId < 4 {
                
                    content.updateBooking(with: reservation.id, toState: 4)
                
                    content.sendNotification(bookingId: reservation.id, fcmToken: reservation.fcmToken, kind: NotificationHandler.Kind.video_room_is_created, title: "", message: "")
                }
                break
            default:
                break
            }
        } else {
            
            Toast.showAlert(viewController: self, text: status.message)
        }
    }
}

