//
//  ViewController.swift
//  ShortPath
//
//  Created by 선상혁 on 11/29/25.
//

import UIKit
import KakaoMapsSDK
import SnapKit

class MapViewController: UIViewController, MapControllerDelegate {
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        _observerAdded = false
        _auth = false
        _appear = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        _observerAdded = false
        _auth = false
        _appear = false
        super.init(coder: aDecoder)
    }
    
    deinit {
        mapController?.pauseEngine()
        mapController?.resetEngine()
        
        print("deinit")
    }
    
    private lazy var mapView = {
        let view = KMViewContainer()
        return view
    }()
    
    private let button = {
        let view = UIButton()
        var config = UIButton.Configuration.filled()
        config.image = UIImage(named: "noti")
        view.configuration = config
        return view
    }()
    
    private let poiView = {
        let view = UIView(frame: .init(x: 50, y: 50, width: 50, height: 50))
        view.backgroundColor = .green
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: "pin_green")
        imageView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        imageView.contentMode = .scaleAspectFit
        
        view.addSubview(imageView)
        return view
    }()
    
    private let poiBadgeView = {
        let view = UIView(frame: .init(x: 15, y: 15, width: 15, height: 15))
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: "noti")
        imageView.frame = CGRect(x: 0, y: 0, width: 15, height: 15)
        imageView.contentMode = .scaleAspectFit
        
        view.addSubview(imageView)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapContainer = mapView
        
        guard mapContainer != nil else {
            print("맵 생성 실패")
            return
        }
        
        mapController = KMController(viewContainer: mapContainer!)
        mapController!.delegate = self
                
        mapSetupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        addObservers()
        _appear = true
        
        if mapController?.isEnginePrepared == false {
            mapController?.prepareEngine()
        }
        
        if mapController?.isEngineActive == false {
            mapController?.activateEngine()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        _appear = false
        mapController?.pauseEngine()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        removeObservers()
        mapController?.resetEngine()
    }
    
    func authenticationFailed(_ errorCode: Int, desc: String) {
        print("error code: \(errorCode)")
        print("desc: \(desc)")
        _auth = false
        
        switch errorCode {
        case 400:
            showToast(self.view, message: "지도 종료(API인증 파라미터 오류)")
            break
        case 401:
            showToast(self.view, message: "지도 종료(API인증 키 오류)")
            break
        case 403:
            showToast(self.view, message: "지도 종료(API인증 권한 오류)")
            break
        case 429:
            showToast(self.view, message: "지도 종료(API 사용쿼터 초과)")
            break
        case 499:
            showToast(self.view, message: "지도 종료(네트워크 오류) 5초 후 재시도..")
            
            // 인증 실패 delegate 호출 이후 5초뒤에 재인증 시도..
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                print("retry auth...")
                
                self.mapController?.prepareEngine()
            }
            break
        default:
            break
        }
    }
    
    func authenticationSucceeded() {
        print("성공")
        if _auth == false {
            _auth = true
        }
        
        if _appear && mapController?.isEngineActive == false {
            mapController?.activateEngine()
        }
    }
    
    private func mapSetupUI() {
        view.backgroundColor = .white
        
        [mapView, button].forEach {
            self.view.addSubview($0)
        }
        
        mapView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        button.snp.makeConstraints { make in
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(30)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(30)
            make.size.equalTo(50)
        }
        
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
    }
    
    @objc func buttonPressed() {
        
    }

    func addViews() {
        let defaultPosition: MapPoint = MapPoint(longitude: 126.9137, latitude: 37.5491)
        let mapViewInfo: MapviewInfo = MapviewInfo(viewName: "mapview", viewInfoName: "map", defaultPosition: defaultPosition, defaultLevel: 17)
        
        DispatchQueue.main.async {
            self.mapController?.addView(mapViewInfo)
        }
    }
    
    func viewInit(viewName: String) {
        print("OK")
        
        createLabelLayer()
        createPoiStyle()
        createPois()
    }
    
    //addView 성공 이벤트 delegate. 추가적으로 수행할 작업을 진행한다.
    func addViewSucceeded(_ viewName: String, viewInfoName: String) {
        print("OK")
        
        kakaoMap.viewRect = mapContainer!.bounds    //뷰 add 도중에 resize 이벤트가 발생한 경우 이벤트를 받지 못했을 수 있음. 원하는 뷰 사이즈로 재조정.
        viewInit(viewName: viewName)
    }
    
    func addViewFailed(_ viewName: String, viewInfoName: String) {
        print("Failed")
    }
    
    func containerDidResized(_ size: CGSize) {
        let mapView: KakaoMap? = mapController?.getView("mapview") as? KakaoMap
        mapView?.viewRect = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: size)
    }
    
    func viewWillDestroyed(_ view: ViewBase) {
        
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        _observerAdded = true
    }
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        
        _observerAdded = false
    }
    
    @objc func willResignActive() {
        mapController?.pauseEngine()
    }
    
    @objc func didBecomeActive() {
        mapController?.activateEngine()
    }
    
    func mapControllerDidChangeZoomLevel() {
        
    }
    
    func showToast(_ view: UIView, message: String, duration: TimeInterval = 2.0) {
        let toastLabel = UILabel(frame: CGRect(x: view.frame.size.width / 2 - 150, y: view.frame.size.height - 100, width: 300, height: 35))
        toastLabel.backgroundColor = UIColor.black
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = NSTextAlignment.center
        view.addSubview(toastLabel)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds  =  true
        
        UIView.animate(withDuration: 0.4,
                       delay: duration - 0.4,
                       options: .curveEaseOut,
                       animations: {
            toastLabel.alpha = 0.0
        },
                       completion: { (finished) in
            toastLabel.removeFromSuperview()
        })
    }
    
    func createLabelLayer() {
        let manager = kakaoMap.getLabelManager()

        let layerOption = LabelLayerOptions(layerID: "PoiLayer", competitionType: .none, competitionUnit: .symbolFirst, orderType: .rank, zOrder: 10001)
        let _ = manager.addLabelLayer(option: layerOption)
    }
    
    func createPoiStyle() {
        let manager = kakaoMap.getLabelManager()

        let red = TextStyle(fontSize: 20, fontColor: UIColor.white, strokeThickness: 2, strokeColor: UIColor.red)
        let blue = TextStyle(fontSize: 20, fontColor: UIColor.white, strokeThickness: 2, strokeColor: UIColor.blue)
        
        let textStyle1 = PoiTextStyle(textLineStyles: [
            PoiTextLineStyle(textStyle: red)
        ])
        let textStyle2 = PoiTextStyle(textLineStyles: [
            PoiTextLineStyle(textStyle: blue)
        ])

        let noti = PoiBadge(badgeID: "badge1", image: poiBadgeView.asImage(), offset: CGPoint(x: 0.9, y: 0.1), zOrder: 0)
        let iconStyle = PoiIconStyle(symbol: poiView.asImage(), anchorPoint: CGPoint(x: 0.5, y: 0.0), badges: [noti])
        let perLevelStyle = PerLevelPoiStyle(iconStyle: iconStyle, textStyle: textStyle1, level: 0)
        let poiStyle = PoiStyle(styleID: "customStyle1", styles: [perLevelStyle])
        manager.addPoiStyle(poiStyle)
    }
    
    func createPois() {
        let manager = kakaoMap.getLabelManager()

        let layer = manager.getLabelLayer(layerID: "PoiLayer")
        let poiOption = PoiOptions(styleID: "customStyle1")
        poiOption.rank = 0
        
        poiOption.addText(PoiText(text: "testPoi", styleIndex: 0))
        poiOption.clickable = true
        
        let poi1 = layer?.addPoi(option: poiOption, at: MapPoint(longitude: 126.9136, latitude: 37.5493))
                
        poi1?.show()
    }
    
    var mapContainer: KMViewContainer?
    var mapController: KMController?
    lazy var kakaoMap: KakaoMap = mapController?.getView("mapview") as! KakaoMap
    var _observerAdded: Bool = false
    var _auth: Bool = false
    var _appear: Bool = false
}
