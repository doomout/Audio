import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate {

    var audioPlayer: AVAudioPlayer!
    var audioFile:URL!
    var MAX_VOLUME: Float = 10.0
    var progressTimer : Timer!
    
    let timePlayerSelector:Selector = #selector(ViewController.updatePlayTime)
    let timeRecordSelector:Selector = #selector(ViewController.updateRecordTime)
    
    @IBOutlet var pvProgressPlay: UIProgressView!
    @IBOutlet var lblCurrentTime: UILabel!
    @IBOutlet var lblEndTime: UILabel!
    
    @IBOutlet var btnPlay: UIButton!
    @IBOutlet var btnPause: UIButton!
    @IBOutlet var btnStop: UIButton!
    
    @IBOutlet var slVolume: UISlider!
    
    @IBOutlet var btnRecord: UIButton!
    @IBOutlet var lblRecordTime: UILabel!
    
    var audioRecorder : AVAudioRecorder! //AVAudioRecorder 인스턴스 추가
    var isRecordMode = false //현재 녹음 모드라는 것을 나태낼 변수 false는 재생모드
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        selectAudioFile()
        if !isRecordMode {
            initPlay()
            btnRecord.isEnabled = false
            lblRecordTime.isEnabled = false
        } else {
            initRecord()
        }
    }
    // 녹음 파일 생성 함수
    func selectAudioFile() {
        //녹음 모드가 아니라면~
        if !isRecordMode{
            audioFile = Bundle.main.url(forResource: "Sicilian_Breeze", withExtension: "mp3")
        } else { //녹음 모드라면?
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            audioFile = documentDirectory.appendingPathComponent("recordFile.m4a")
        }
    }
    //녹음을 위한 초기화 함수
    func initRecord() {
        //녹음 설정
        let recordSettings = [
            AVFormatIDKey : NSNumber(value: kAudioFormatAppleLossless as UInt32),
            AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue, //음질은 최대
            AVEncoderBitRateKey : 320000, //비트율
            AVNumberOfChannelsKey : 2, //오디오 채널
            AVSampleRateKey : 44100.0 //샘플율
        ] as [String : Any]
        
        do{
            audioRecorder = try AVAudioRecorder(url: audioFile, settings: recordSettings)
        } catch let error as NSError {
            print("Error-initRecord : \(error)")
        }
        
        audioRecorder.delegate = self
        
        slVolume.value = 1.0 //볼륨 기본 값
        audioPlayer.volume = slVolume.value //볼륨도 1.0으로 설정
        lblEndTime.text = convertNSTimeInterval2String(0) //총 재생시간을 0으로 초기화
        lblCurrentTime.text = convertNSTimeInterval2String(0) //현재 재생시간을 0으로 초기화
        setPlayButtons(false, pause: false, stop: false)
        
        let session = AVAudioSession.sharedInstance()
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error as NSError {
            print(" Error-setCategory: \(error)")
        }
        do {
            try session.setActive(true)
        } catch let error as NSError {
            print(" Error-setActive : \(error)")
        }
    }
    
    func initPlay() {
        do{
            audioPlayer = try AVAudioPlayer(contentsOf: audioFile)
        } catch let error as NSError {
            print("Error-initPlay : \(error)")
        }
        slVolume.maximumValue = MAX_VOLUME  //슬라이더의 최대 볼륭음 상수 10.0으로 초기화 한다.
        slVolume.value = 1.0 //슬라이더의 볼륨을 1.0으로 초기화 한다
        pvProgressPlay.progress = 0 //프로그래스 뷰의 진행을 0으로 초기화 한다.
        
        audioPlayer.delegate = self 
        audioPlayer.prepareToPlay()
        audioPlayer.volume = slVolume.value
        
        lblEndTime.text = convertNSTimeInterval2String(audioPlayer.duration) //오디오 파일 재생 시간의 int 값을 string 로 형변환
        lblCurrentTime.text = convertNSTimeInterval2String(0)
          
        setPlayButtons(true, pause: false, stop: false)
    }
    
    func setPlayButtons(_ play:Bool, pause:Bool, stop:Bool){
        btnPlay.isEnabled = play
        btnPause.isEnabled = pause
        btnStop.isEnabled = stop
    }
    
    //재생 시간을 00:00으로 바꾸기 위한 함수
    func convertNSTimeInterval2String(_ time:TimeInterval) -> String {
        let min = Int(time/60) //재생 시간의 매개변수인 time 값을 60으로 나눈 몫을 정수 값으로 변환하여 상수 min 값에 초기화 한다.
        let sec = Int(time.truncatingRemainder(dividingBy: 60)) //60으로 나눈 나머지 값을 정수 값으로 변환하여 sec 값에 초기화 한다.
        let strTime = String(format: "%02d:%02d", min, sec) //00:00 형태의 문자열로 변환한다.
        return strTime //변환한 값을 반환한다.
    }

    @IBAction func btnPlayAudio(_ sender: UIButton) {
        audioPlayer.play()
        setPlayButtons(false, pause: true, stop: true)
        progressTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: timePlayerSelector, userInfo: nil, repeats: true)
    }
    
    @objc func updatePlayTime() {
        //재생 시간인 currentTime을 레이블에 표시한다.
        lblCurrentTime.text = convertNSTimeInterval2String(audioPlayer.currentTime)
        //프로그레스 뷰에 (현재 재생시간/총 재생시간)의 값을 넣는다.
        pvProgressPlay.progress = Float(audioPlayer.currentTime/audioPlayer.duration)
    }
    
    
    @IBAction func btnPauseAudio(_ sender: UIButton) {
        audioPlayer.pause()
        setPlayButtons(true, pause: false, stop: true)
    }
    
    @IBAction func btnStopAudio(_ sender: UIButton) {
        audioPlayer.stop()
        audioPlayer.currentTime = 0 //오디오를 정지하고 다시 재생하면 처음부터 재생해야 하기에 시간을 0으로 설정
        lblCurrentTime.text = convertNSTimeInterval2String(0) // 재생시간도 00:00으로 초기화
        setPlayButtons(true, pause: false, stop: false)
        progressTimer.invalidate() //타이머도 초기화
    }
    
    
    @IBAction func slChangeVolume(_ sender: UISlider) {
        audioPlayer.volume = slVolume.value
    }
    
    //오디오 재생이 끝나면 맨 처음 상태로 돌아가는 함수
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        progressTimer.invalidate() //타이머 무효화
        setPlayButtons(true, pause: false, stop: false)
    }
    
    
    @IBAction func swRecordMode(_ sender: UISwitch) {
        if sender.isOn {
            audioPlayer.stop()
            audioPlayer.currentTime = 0
            lblRecordTime!.text = convertNSTimeInterval2String(0)
            isRecordMode = true
            btnRecord.isEnabled = true
            lblRecordTime.isEnabled = true
        } else {
            isRecordMode = false
            btnRecord.isEnabled = false
            lblRecordTime.isEnabled = false
            lblRecordTime.text = convertNSTimeInterval2String(0)
        }
        selectAudioFile()
        if !isRecordMode {
            initPlay()
        } else {
            initRecord()
        }
    }
    
    
    @IBAction func btnRecord(_ sender: UIButton) {
        if (sender as AnyObject).titleLabel?.text == "Record" {
            audioRecorder.record()
            (sender as AnyObject).setTitle("Stop", for: UIControl.State())
            //녹음할 때 타이머가 작동하도록 0.1초 간격으로 타이머를 생성한다.
            progressTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: timeRecordSelector, userInfo: nil, repeats: true)
        } else {
            audioRecorder.stop()
            progressTimer.invalidate()
            (sender as AnyObject).setTitle("Record", for: UIControl.State())
            btnPlay.isEnabled = true
            initPlay()
        }
    }
    
    //녹음 시간 표시 함수
    @objc func updateRecordTime() {
        lblRecordTime.text = convertNSTimeInterval2String(audioRecorder.currentTime)
    }
}

