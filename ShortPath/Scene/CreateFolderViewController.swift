//
//  CreateFolderViewController.swift
//  ShortPath
//
//  Created by 선상혁 on 9/7/26.
//

import UIKit
import SnapKit

final class CreateFolderViewController: UIViewController {
    var onCreate: ((String) -> Void)?
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "새 리스트 이름"
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
    
    private var nameTextField: UITextField = {
        let view = UITextField()
        view.attributedPlaceholder = NSAttributedString(
            string: "예: 카페, 회사",
            attributes: [.foregroundColor: UIColor.gray]
        )
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(hex: "0xEAF3FF").cgColor
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.backgroundColor = .white
        view.textColor = .black
        view.returnKeyType = .done
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 44))
        view.leftView = paddingView
        view.leftViewMode = .always
        
        return view
    }()
    
    private var confirmButton: UIButton = {
        let view = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.title = "추가"
        config.baseBackgroundColor = UIColor(hex: "0x3A7BD5")
        config.cornerStyle = .medium
        view.configuration = config
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        configure()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        nameTextField.becomeFirstResponder()
    }
    
    private func configure() {
        [titleLabel, closeButton, nameTextField, confirmButton].forEach { view.addSubview($0) }
        
        closeButton.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(confirmButtonPressed), for: .touchUpInside)
        nameTextField.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.equalToSuperview().offset(20)
        }
        
        closeButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalToSuperview().inset(16)
            make.width.height.equalTo(32)
        }
        
        nameTextField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }
        
        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(nameTextField.snp.bottom).offset(16)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(48)
        }
    }
    
    @objc
    private func closeButtonPressed() {
        dismiss(animated: true)
    }
    
    @objc
    private func confirmButtonPressed() {
        guard let name = nameTextField.text?.trimmingCharacters(in: .whitespaces), !name.isEmpty else { return }
        
        onCreate?(name)
    }
    
    @objc
    private func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension CreateFolderViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
