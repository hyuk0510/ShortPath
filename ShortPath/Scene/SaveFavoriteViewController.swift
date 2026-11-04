//
//  SaveFavoriteViewController.swift
//  ShortPath
//
//  Created by 선상혁 on 3/5/26.
//

import UIKit

final class SaveFavoriteViewController: UIViewController {
    
    private let place: Place
    private let repository: FavoriteRepositoryProtocol
    
    var onComplete: (() -> Void)?
    
    private var folderNames: [String] = []
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "어느 폴더에 저장할까요?"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .black
        return label
    }()
    
    private var closeButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(systemName: "xmark"), for: .normal)
        view.tintColor = .black
        return view
    }()
    
    private var tableView = UITableView()
        
    private var addFolderButton: UIButton = {
        let view = UIButton(type: .system)
        var config = UIButton.Configuration.plain()
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 16, weight: .semibold)
        config.attributedTitle = AttributedString("+ 새 리스트 추가", attributes: container)
        config.baseForegroundColor = UIColor(hex: "0x3A7BD5")
        view.configuration = config
        return view
    }()
    
    init(place: Place, repository: FavoriteRepositoryProtocol = FavoriteRepository.shared) {
        self.place = place
        self.repository = repository
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        loadFolderNames()
        configure()
    }
    
    private func loadFolderNames() {
        folderNames = repository.fetchAllFolderNames()
    }
    
    private func configure() {
        [titleLabel, closeButton, tableView, addFolderButton].forEach { view.addSubview($0) }
        
        closeButton.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
        addFolderButton.addTarget(self, action: #selector(addFolderButtonPressed), for: .touchUpInside)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.equalToSuperview().offset(20)
        }
        
        closeButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalToSuperview().inset(16)
            make.width.height.equalTo(32)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(addFolderButton.snp.top).offset(-8)
        }
        
        addFolderButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.height.equalTo(44)
        }
        
        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FolderCell.self, forCellReuseIdentifier: FolderCell.identifier)
        tableView.rowHeight = 52
    }
    
    private func saveFavorite(folderName: String) {
        repository.savePlace(place: place)
        repository.updateFolder(placeID: place.id, folderName: folderName)
        
        onComplete?()
        dismiss(animated: true)
    }
    
    @objc
    private func closeButtonPressed() {
        dismiss(animated: true)
    }
    
    @objc
    private func addFolderButtonPressed() {
        let createFolderVC = CreateFolderViewController()
        createFolderVC.onCreate = { [weak self] folderName in
            guard let self else { return }
            
            dismiss(animated: true) {
                self.saveFavorite(folderName: folderName)
            }
        }
        
        present(createFolderVC, animated: true)
    }
}

extension SaveFavoriteViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        folderNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FolderCell.identifier, for: indexPath) as? FolderCell else { return FolderCell() }
        
        let folderName = folderNames[indexPath.row]
        let count = repository.fetchPlaces(inFolder: folderName).count
        cell.bind(name: folderName, count: count)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        saveFavorite(folderName: folderNames[indexPath.row])
    }
}
