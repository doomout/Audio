import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioPlayerDelegate {

    var audioPlayer: AVAudioPlayer!
    var audioFile:URL!
    var MAX_VOLUME: Float = 10.0
    var progressTimer : Timer!
    
    @IBOutlet var pvProgressPlay: UIProgressView!
    @IBOutlet var lblCurrentTime: UILabel!
    @IBOutlet var lblEndTime: UILabel!
    
    @IBOutlet var btnPlay: UIButton!
    @IBOutlet var btnPause: UIButton!
    @IBOutlet var btnStop: UIButton!
    
    @IBOutlet var slVolume: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        audioFile = Bundle.main.url(forResource: "Sicilian_Breeze", withExtension: "mp3")
        initPlay()
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
    }
    
    @IBAction func btnPauseAudio(_ sender: UIButton) {
        audioPlayer.pause()
        setPlayButtons(true, pause: false, stop: true)
    }
    
    @IBAction func btnStopAudio(_ sender: UIButton) {
        audioPlayer.stop()
        setPlayButtons(true, pause: false, stop: false)
    }
    
    
    @IBAction func slChangeVolume(_ sender: UISlider) {
    }
}

