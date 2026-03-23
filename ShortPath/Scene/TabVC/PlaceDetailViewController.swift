//
//  PlaceDetailViewController.swift
//  ShortPath
//
//  Created by 선상혁 on 2/20/26.
//

import UIKit

final class PlaceDetailViewController: UIViewController, BottomSheetInteractable, BottomSheetStateApplicable {
    
    var scrollView = UIScrollView()
    private var contentStackView = UIStackView()
    
    var trackingScrollView: UIScrollView? {
        return scrollView
    }
    
    var buttonEnabled: Bool = false
        
    private let place: Place
        
    weak var delegate: PlaceDetailViewControllerDelegate?
    
    private var addressContainer = UIStackView()
    private var telContainer = UIStackView()
    
    init(place: Place) {
        self.place = place
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var placeNameLabel: UILabel = {
        let view = UILabel()
        
        view.font = .systemFont(ofSize: 22, weight: .bold)
        view.textColor = .black
        view.numberOfLines = 0
        
        return view
    }()
    
    private var categoryNameLabel: UILabel = {
        let view = UILabel()
        
        view.font = .systemFont(ofSize: 14, weight: .regular)
        view.textColor = .gray
        
        return view
    }()
    
    private var favoriteButton: UIButton = {
        let view = UIButton()
        
        view.setImage(UIImage(systemName: "star"), for: .normal)
        view.tintColor = .black
        
        return view
    }()
    
    private var closeButton: UIButton = {
        let view = UIButton()
        
        view.setImage(UIImage(systemName: "xmark"), for: .normal)
        view.tintColor = .black
        
        return view
    }()
    
    private var distanceLabel: UILabel = {
        let view = UILabel()
        
        view.font = .systemFont(ofSize: 14, weight: .semibold)
        view.textColor = .gray
        
        return view
    }()
    
    private var startButton: UIButton = {
        let view = UIButton()
        var configuration = UIButton.Configuration.tinted()
        var container = AttributeContainer()
        
        container.font = .systemFont(ofSize: 14, weight: .semibold)
        configuration.attributedTitle = AttributedString("출발", attributes: container)
        configuration.cornerStyle = .capsule
        
        view.configuration = configuration
        
        return view
    }()
    
    private var wayPointButton: UIButton = {
        let view = UIButton()
        var configuration = UIButton.Configuration.tinted()
        var container = AttributeContainer()
        
        container.font = .systemFont(ofSize: 14, weight: .semibold)
        configuration.attributedTitle = AttributedString("경유지", attributes: container)
        configuration.cornerStyle = .capsule
        
        view.configuration = configuration
        
        return view
    }()
    
    private var destinationButton: UIButton = {
        let view = UIButton()
        var configuration = UIButton.Configuration.filled()
        var container = AttributeContainer()
        
        container.font = .systemFont(ofSize: 14, weight: .semibold)
        configuration.attributedTitle = AttributedString("도착", attributes: container)
        configuration.cornerStyle = .capsule
        
        view.configuration = configuration
        
        return view
    }()
    
    private var callButton: UIButton = {
        let view = UIButton()
        var configuration = UIButton.Configuration.filled()
        var container = AttributeContainer()
        
        container.font = .systemFont(ofSize: 14, weight: .semibold)
        configuration.attributedTitle = AttributedString("전화", attributes: container)
        configuration.image = UIImage(systemName: "phone.fill")
        configuration.imagePlacement = .leading
        configuration.imagePadding = 6
        configuration.cornerStyle = .capsule
        
        view.configuration = configuration
        
        return view
    }()
    
    private var openOnKakaoMapButton: UIButton = {
        let view = UIButton()
        var configuration = UIButton.Configuration.filled()
        var container = AttributeContainer()
        
        container.font = .systemFont(ofSize: 14, weight: .semibold)
        configuration.attributedTitle = AttributedString("카카오맵에서 열기", attributes: container)
        configuration.cornerStyle = .capsule
        configuration.baseBackgroundColor = .init(hex: "FEE500")
        configuration.baseForegroundColor = .black
        
        view.configuration = configuration
        
        return view
    }()
    
    private var placeAddressLabel: UILabel = {
        let view = UILabel()
        
        view.font = .systemFont(ofSize: 14, weight: .regular)
        view.numberOfLines = 0
        view.textColor = .black
        
        return view
    }()
    
    private var addressDetailButton: UIButton = {
        let view = UIButton()
        
        view.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        view.setImage(UIImage(systemName: "chevron.up"), for: .selected)
        view.tintColor = .black
        
        return view
    }()
    
    private var roadAddressTitle: UILabel = {
        let view = UILabel()
        
        view.font = .systemFont(ofSize: 14, weight: .semibold)
        view.textColor = .gray
        view.text = "도로명 :"
        
        return view
    }()
    
    private var roadAddressLabel: UILabel = {
        let view = UILabel()
        
        view.font = .systemFont(ofSize: 14, weight: .regular)
        view.numberOfLines = 0
        view.textColor = .black
        
        return view
    }()
    
    private var roadAddressCopyButton: UIButton = {
        let view = UIButton()
        var configuration = UIButton.Configuration.plain()
        var container = AttributeContainer()
        
        container.font = .systemFont(ofSize: 14, weight: .semibold)
        configuration.attributedTitle = AttributedString("복사", attributes: container)
        
        view.configuration = configuration
        
        return view
    }()
    
    private var addressTitle: UILabel = {
        let view = UILabel()
        
        view.font = .systemFont(ofSize: 14, weight: .semibold)
        view.textColor = .gray
        view.text = "지번 :"
        
        return view
    }()
    
    private var addressLabel: UILabel = {
        let view = UILabel()
        
        view.font = .systemFont(ofSize: 14, weight: .regular)
        view.numberOfLines = 0
        view.textColor = .black
        
        return view
    }()
    
    private var addressCopyButton: UIButton = {
        let view = UIButton()
        var configuration = UIButton.Configuration.plain()
        var container = AttributeContainer()
        
        container.font = .systemFont(ofSize: 14, weight: .semibold)
        configuration.attributedTitle = AttributedString("복사", attributes: container)
        
        view.configuration = configuration
        
        return view
    }()
    
    private var addressDetailView: UIView = {
        let view = UIView()
        
        
        view.backgroundColor = .white
        view.isHidden = true
        
        view.layer.cornerRadius = 12
        
        view.setShadow()
        view.layer.masksToBounds = false
            
        
        return view
    }()
    
    private var telNumberTitleLabel: UILabel = {
        let view = UILabel()
        
        view.font = .systemFont(ofSize: 13, weight: .semibold)
        view.textColor = .gray
        view.text = "전화번호"
        
        return view
    }()
    
    private var telNumber: UILabel = {
        let view = UILabel()
        
        view.font = .systemFont(ofSize: 16, weight: .medium)
        view.textColor = .black
        view.isUserInteractionEnabled = true
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        bind()
    }
    
    private func configure() {
        view.addSubview(scrollView)
        
        scrollView.addSubview(contentStackView)
        scrollView.delegate = self
        scrollView.isScrollEnabled = false
        
        scrollView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        contentStackView.axis = .vertical
        contentStackView.spacing = 16
        
        contentStackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().inset(12)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        setUpHeaderSection()
        setUpAddressSection()
        setUpTelSection()
        setUpButtonSection()
    }
    
    private func setUpHeaderSection() {
        let headerContainer = UIStackView()
        headerContainer.axis = .vertical
        headerContainer.spacing = 6
        
        let topRow = UIStackView()
        topRow.axis = .horizontal
        topRow.alignment = .center
        topRow.spacing = 6
        
        let buttonStack = UIStackView()
        buttonStack.axis = .horizontal
        buttonStack.spacing = 6
        
        placeNameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        favoriteButton.addTarget(self, action: #selector(favoriteButtonPressed), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
        
        [favoriteButton, closeButton].forEach { view in
            buttonStack.addArrangedSubview(view)
        }
        
        [placeNameLabel, makeSpacer(), buttonStack].forEach { view in
            topRow.addArrangedSubview(view)
        }
        
        [favoriteButton, closeButton].forEach {
            $0.snp.makeConstraints { make in
                make.width.height.equalTo(44)
            }
        }
        
        [topRow, categoryNameLabel].forEach { view in
            headerContainer.addArrangedSubview(view)
        }
        
        contentStackView.addArrangedSubview(headerContainer)
    }
    
    @objc
    private func favoriteButtonPressed() {
        guard buttonEnabled else { return }
        let vc = SaveFavoriteViewController()
        
        vc.modalPresentationStyle = .formSheet
        present(vc, animated: true)
    }
    
    @objc
    private func closeButtonPressed() {
        guard buttonEnabled else { return }

        delegate?.closeButtonPressed()
    }
    
    private func setUpButtonSection() {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 6
        
        [startButton, wayPointButton, destinationButton, callButton].forEach { view in
            stack.addArrangedSubview(view)
        }
        
        let verticalStack = UIStackView()
        verticalStack.axis = .vertical
        verticalStack.spacing = 6
        
        [stack, openOnKakaoMapButton].forEach { view in
            verticalStack.addArrangedSubview(view)
        }
        
        [startButton, wayPointButton, destinationButton, wayPointButton].forEach { view in
            view.snp.makeConstraints { make in
                make.height.equalTo(44)
            }
        }

        openOnKakaoMapButton.snp.makeConstraints { make in
            make.height.equalTo(48)
        }
        
        startButton.addTarget(self, action: #selector(startButtonPressed), for: .touchUpInside)
        wayPointButton.addTarget(self, action: #selector(wayPointButtonPressed), for: .touchUpInside)
        destinationButton.addTarget(self, action: #selector(destinationButtonPrseed), for: .touchUpInside)
        callButton.addTarget(self, action: #selector(callButtonPressed), for: .touchUpInside)
        openOnKakaoMapButton.addTarget(self, action: #selector(openOnKakaoMapButtonPressed), for: .touchUpInside)
        
        if place.phone == nil {
            callButton.isHidden = true
            telNumberTitleLabel.isHidden = true
        }
        
        contentStackView.addArrangedSubview(verticalStack)
    }
    
    @objc
    private func startButtonPressed() {
        guard buttonEnabled else { return }

        delegate?.didSelectRouteAction(place: place, action: .start)
    }
    
    @objc
    private func wayPointButtonPressed() {
        guard buttonEnabled else { return }

        delegate?.didSelectRouteAction(place: place, action: .wayPoints)
    }
    
    @objc
    private func destinationButtonPrseed() {
        guard buttonEnabled else { return }

        delegate?.didSelectRouteAction(place: place, action: .destination)
    }
    
    @objc
    private func callButtonPressed() {
        guard buttonEnabled else { return }

        let alert = UIAlertController(title: "\(String(place.phone ?? ""))로 전화 걸기", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "전화", style: .default, handler: { _ in
            let cleanedNumber = self.place.phone?
                .replacingOccurrences(of: "-", with: "")
                .replacingOccurrences(of: " ", with: "")
                .replacingOccurrences(of: "(", with: "")
                .replacingOccurrences(of: ")", with: "")
            
            guard let url = URL(string: "tel:\\\(cleanedNumber ?? "")") else { return }
            
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc
    private func openOnKakaoMapButtonPressed() {
        guard buttonEnabled else { return }

        let appURL: URL?
        let webURL: URL?
        
        if !place.id.isEmpty {
            appURL = URL(string: "kakaomap://place?id=\(place.id)")
            webURL = URL(string: "https://map.kakao.com/link/map/\(place.id)")
        } else {
            let encodedName = place.name.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? place.name
            appURL = URL(string: "kakaomap://look?p=\(place.latitude),\(place.longitude)")
            webURL = URL(string: "https://map.kakao.com/link/map/\(encodedName),\(place.latitude),\(place.longitude)")
        }
        
        if let appURL, UIApplication.shared.canOpenURL(appURL) {
            UIApplication.shared.open(appURL)
        } else if let webURL {
            UIApplication.shared.open(webURL)
        }
    }
    
    private func setUpAddressSection() {
        // 전체 스택뷰
        addressContainer.axis = .vertical
        addressContainer.spacing = 6
        
        // 거리 + 주소 + 상세 주소 버튼 스택뷰
        let disAddressStack = UIStackView()
        disAddressStack.axis = .horizontal
        disAddressStack.spacing = 6
        disAddressStack.alignment = .center
        disAddressStack.distribution = .fill
        
        // 상세 주소 화면 스택뷰
        let addressDetailStack = UIStackView()
        addressDetailStack.axis = .vertical
        addressDetailStack.spacing = 6
        addressDetailStack.alignment = .fill
        
        // 상세 주소 화면 도로명 주소 스택뷰
        let roadAddressStack = UIStackView()
        roadAddressStack.axis = .horizontal
        roadAddressStack.spacing = 6
        roadAddressStack.alignment = .center
        roadAddressStack.distribution = .fill
        
        // 상세 주소 화면 주소 스택뷰
        let addressStack = UIStackView()
        addressStack.axis = .horizontal
        addressStack.spacing = 6
        addressStack.alignment = .center
        addressStack.distribution = .fill
        
        // 상세 주소 화면 도로명 주소 스택뷰 구성
        
        [roadAddressTitle, roadAddressLabel, roadAddressCopyButton, makeSpacer()].forEach { view in
            roadAddressStack.addArrangedSubview(view)
        }
        
        roadAddressTitle.setContentHuggingPriority(.required, for: .horizontal)
        roadAddressTitle.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        roadAddressLabel.numberOfLines = 1
        roadAddressLabel.setContentHuggingPriority(.required, for: .horizontal)
        roadAddressLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        roadAddressCopyButton.setContentHuggingPriority(.required, for: .horizontal)
        roadAddressCopyButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        roadAddressCopyButton.addTarget(self, action: #selector(roadAddressCopyButtonPressed), for: .touchUpInside)
        
        // 상세 주소 화면 주소 스택뷰 구성
        
        [addressTitle, addressLabel, addressCopyButton, makeSpacer()].forEach { view in
            addressStack.addArrangedSubview(view)
        }
        
        addressTitle.setContentHuggingPriority(.required, for: .horizontal)
        addressTitle.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        addressLabel.numberOfLines = 1
        addressLabel.setContentHuggingPriority(.required, for: .horizontal)
        addressLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        addressCopyButton.setContentHuggingPriority(.required, for: .horizontal)
        addressCopyButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        addressCopyButton.addTarget(self, action: #selector(addressCopyButtonPressed), for: .touchUpInside)
        
        // 상세 주소 화면 스택뷰 구성
        
        [roadAddressStack, addressStack].forEach { view in
            addressDetailStack.addArrangedSubview(view)
        }
        
        addressDetailView.addSubview(addressDetailStack)
        
        addressDetailStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
                
        // 거리 + 주소 + 상세 주소 버튼 스택뷰 구성
        
        [distanceLabel, placeAddressLabel, addressDetailButton, makeSpacer()].forEach { view in
            disAddressStack.addArrangedSubview(view)
        }
        
        distanceLabel.setContentHuggingPriority(.required, for: .horizontal)
        distanceLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        placeAddressLabel.numberOfLines = 1
        placeAddressLabel.setContentHuggingPriority(.required, for: .horizontal)
        placeAddressLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        addressDetailButton.setContentHuggingPriority(.required, for: .horizontal)
        addressDetailButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        addressDetailButton.addTarget(self, action: #selector(addressDetailButtonPressed), for: .touchUpInside)
        
        // 전체 스택뷰 구성
        
        [disAddressStack, addressDetailView].forEach { view in
            addressContainer.addArrangedSubview(view)
        }
        
        contentStackView.addArrangedSubview(addressContainer)
    }
    
    private func makeSpacer() -> UIView {
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spacer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return spacer
    }
    
    @objc
    private func addressDetailButtonPressed(_ sender: UIButton) {
        guard buttonEnabled else { return }

        sender.isSelected.toggle()
        addressDetailView.isHidden.toggle()
    }
    
    @objc
    private func roadAddressCopyButtonPressed() {
        let roadAddress = roadAddressLabel.text
        UIPasteboard.general.string = roadAddress
        
        errorAlert(title: nil, message: "도로명 주소를 복사했습니다.")
    }
    
    @objc
    private func addressCopyButtonPressed() {
        let address = addressLabel.text
        UIPasteboard.general.string = address
        
        errorAlert(title: nil, message: "지번 주소를 복사했습니다.")
    }
    
    private func setUpTelSection() {
        telContainer.axis = .vertical
        telContainer.spacing = 6
        
        [telNumberTitleLabel, telNumber].forEach { view in
            telContainer.addArrangedSubview(view)
        }
                
        contentStackView.addArrangedSubview(telContainer)
    }
    
    func bind() {
        placeNameLabel.text = place.name
        categoryNameLabel.text = CategoryFormatter.string(from: place.category)
        distanceLabel.text = DistanceFormatter.string(from: place.distance ?? 0) + " ･"
        placeAddressLabel.text = place.roadAddress
        roadAddressLabel.text = place.roadAddress
        addressLabel.text = place.address
        telNumber.text = place.phone
    }
    
    func changedBottomSheetState(_ state: Mode) {
        switch state {
        case .tip:
            addressContainer.isHidden = true
            telContainer.isHidden = true
        case .medium, .max:
            addressContainer.isHidden = false
            telContainer.isHidden = false
        }
    }
}

extension PlaceDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 0 {
            scrollView.contentOffset = .zero
        }
    }
}
