# 오디오 앱
AVAudioPlay 란?  
오디오 재생을 위한 앱    
1. 지원하는 포멧  
ACC, HE-ACC, Linear PCM, ALAC, AMR, iLBC, MP3

2. do - try - catch 문   
오류가 발생할 수 있는 함수를 호출 할 때 에러 처리를 위한 문 
(사용 형식)     
do {    
    try 오류 발생 가능 코드 
    오류가 발생하지 않을 시 실행할 코드    
} catch 오류 패턴 1 {   
    처리 구문   
} catch 오류 패턴 2 where 추가 조건 {   
    처리 구문   
} catch {   
    처리 구문   
}   
오류 타입은 한개 또는 그 이상도 가능. 
