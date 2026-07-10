//
//  LoginViewController.swift
//  ShortPath
//

import UIKit
import AuthenticationServices
import CryptoKit
import FirebaseAuth
import FirebaseCore
import SnapKit
import GoogleSignIn

final class LoginViewController: UIViewController {

    private var currentNonce: String?

    private static let mainBlue = UIColor(red: 0.227, green: 0.482, blue: 0.835, alpha: 1)
    private static let bgBlue  = UIColor(red: 0.918, green: 0.953, blue: 1.0,   alpha: 1)

    private let iconImageView: UIImageView = {
        let view = UIImageView()

        view.image = UIImage(named: "routee_logo_mark")
        view.contentMode = .scaleAspectFit

        return view
    }()

    private let titleLabel: UILabel = {
        let view = UILabel()
        
        view.text = "Routee"
        view.font = .systemFont(ofSize: 30, weight: .bold)
        view.textColor = UIColor(red: 0.227, green: 0.482, blue: 0.835, alpha: 1)
        view.textAlignment = .center
        
        return view
    }()

    private let subtitleLabel: UILabel = {
        let view = UILabel()
        
        view.text = "나만의 경로를 찾아보세요"
        view.font = .systemFont(ofSize: 14, weight: .regular)
        view.textColor = UIColor(red: 0.227, green: 0.482, blue: 0.835, alpha: 0.7)
        view.textAlignment = .center
        
        return view
    }()

    private let cardView: UIView = {
        let view = UIView()
        
        view.backgroundColor = .white
        view.layer.cornerRadius = 32
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowOffset = CGSize(width: 0, height: -4)
        view.layer.shadowRadius = 12
        
        return view
    }()

    private let googleLoginButton: UIButton = {
        let view = UIButton(type: .system)
        
        var configuration = UIButton.Configuration.filled()
        var title = AttributeContainer()
        title.font = UIFont(name: "Roboto-Medium", size: 18) ?? .systemFont(ofSize: 18, weight: .medium)
        configuration.attributedTitle = AttributedString("Sign in with Google", attributes: title)
        configuration.image = UIImage(named: "google_logo")?.withRenderingMode(.alwaysOriginal)
        configuration.imagePadding = 0
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        configuration.baseBackgroundColor = UIColor(red: 0.949, green: 0.949, blue: 0.949, alpha: 1)
        configuration.baseForegroundColor = UIColor(red: 0.122, green: 0.122, blue: 0.122, alpha: 1)
        configuration.cornerStyle = .fixed
        configuration.background.cornerRadius = 12
        configuration.background.strokeWidth = 0
        view.configuration = configuration
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 6
        
        return view
    }()

    private let appleLoginButton = ASAuthorizationAppleIDButton(type: .signIn, style: .black)

    private let termsLabel: UILabel = {
        let view = UILabel()
        
        view.text = "로그인하면 서비스 이용약관과 개인정보 처리방침에 동의하게 됩니다."
        view.font = .systemFont(ofSize: 12, weight: .regular)
        view.textColor = UIColor(red: 0.36, green: 0.40, blue: 0.48, alpha: 1)
        view.textAlignment = .center
        view.numberOfLines = 2
        
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Self.bgBlue
        appleLoginButton.layer.cornerRadius = 12
        appleLoginButton.clipsToBounds = true
        setupLayout()
        setupActions()
    }

    private func setupLayout() {
        [iconImageView, titleLabel, subtitleLabel, cardView].forEach { view.addSubview($0) }
        [googleLoginButton, appleLoginButton, termsLabel].forEach { cardView.addSubview($0) }

        iconImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(72)
            make.width.height.equalTo(84)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
        }

        cardView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(subtitleLabel.snp.bottom).offset(72)
        }

        googleLoginButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(48)
            make.leading.trailing.equalToSuperview().inset(28)
            make.height.equalTo(52)
        }

        appleLoginButton.snp.makeConstraints { make in
            make.top.equalTo(googleLoginButton.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(28)
            make.height.equalTo(52)
        }
        
        termsLabel.snp.makeConstraints { make in
            make.top.equalTo(appleLoginButton.snp.bottom).offset(18)
            make.leading.trailing.equalToSuperview().inset(36)
        }
    }

    private func setupActions() {
        googleLoginButton.addTarget(self, action: #selector(didTapGoogleLogin), for: .touchUpInside)
        appleLoginButton.addTarget(self, action: #selector(didTapAppleLogin), for: .touchUpInside)
    }
    
    @objc
    private func didTapGoogleLogin() {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            showAlert("Google 로그인용 CLIENT_ID 설정이 필요해요.")
            return
        }

        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] result, error in
            if let error {
                if (error as NSError).code != GIDSignInError.canceled.rawValue {
                    self?.showAlert(error.localizedDescription)
                }
                return
            }

            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                self?.showAlert("Google 인증 정보를 가져오지 못했어요.")
                return
            }

            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: user.accessToken.tokenString
            )

            Auth.auth().signIn(with: credential) { _, error in
                if let error {
                    self?.showAlert(error.localizedDescription)
                    return
                }
                self?.switchToMain()
            }
        }
    }

    @objc
    private func didTapAppleLogin() {
        let nonce = randomNonceString()
        currentNonce = nonce

        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }

    private func switchToMain() {
        guard let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate else { return }
        sceneDelegate.showMain()
    }

    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Apple Sign In
extension LoginViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let tokenData = credential.identityToken,
              let token = String(data: tokenData, encoding: .utf8),
              let nonce = currentNonce else { return }

        let firebaseCredential = OAuthProvider.appleCredential(
            withIDToken: token,
            rawNonce: nonce,
            fullName: credential.fullName
        )

        Auth.auth().signIn(with: firebaseCredential) { [weak self] _, error in
            if let error {
                self?.showAlert(error.localizedDescription)
                return
            }
            self?.switchToMain()
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        showAlert(error.localizedDescription)
    }
}

// MARK: - Nonce Helpers
private extension LoginViewController {

    func randomNonceString(length: Int = 32) -> String {
        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        while remainingLength > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in
                var random: UInt8 = 0
                _ = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                return random
            }
            randoms.forEach { random in
                if remainingLength == 0 { return }
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }

    func sha256(_ input: String) -> String {
        let data = Data(input.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}
