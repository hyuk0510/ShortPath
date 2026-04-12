//
//  SettingView.swift
//  ShortPath
//
//  Created by 선상혁 on 4/12/26.
//

import SwiftUI
import WebKit

enum OpenSourceLicenseType: Hashable {
    case localText(fileName: String)
    case externalURL(String)
}

struct OpenSourceLicenseItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let licenseName: String
    let type: OpenSourceLicenseType
}

enum LicenseTextLoader {
    static func loadText(fileName: String) -> String {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "txt") else {
            return "라이선스 파일을 찾을 수 없습니다."
        }
        
        do {
            return try String(contentsOf: url, encoding: .utf8)
        } catch {
            return "라이선스 파일을 불러오는 중 오류가 발생했습니다."
        }
    }
}

struct SettingView: View {
    
    var body: some View {
        VStack {
            barView
            
            NavigationStack {
                
                ZStack {
                    
                    VStack(alignment: .leading, spacing: 24) {
                        appInfoSection
                        supportSection
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }
                .background(Color.white)
            }
            .background(Color.white)
            
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    
}
    
private extension SettingView {
    
    private var barView: some View {
        VStack(spacing: 8) {
            Capsule()
                .fill(Color(.lightGray))
                .frame(width: UIScreen.main.bounds.width * 0.1, height: 4)
                .padding(.top, 8)
                .background(Color.white)
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
    }
    
    // 앱 정보 섹션
    var appInfoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("앱 정보")
                .font(.subheadline)
                .foregroundColor(.black)
                .padding(.horizontal, 4)
            
            VStack(spacing: 0) {
                infoRow(title: "버전", value: "1.0.0")
                
                Divider()
                    .padding(.leading, 16)
                
                NavigationLink(destination: OpenSourceLicensesView()) {
                    navigationRow(title: "오픈소스 라이선스")
                }
                .buttonStyle(.plain)
            }
            .background(Color(UIColor(hex: "0xF5F5F5")))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    // 지원 섹션
    var supportSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("지원")
                .font(.subheadline)
                .foregroundColor(.black)
                .padding(.horizontal, 4)
            
            VStack(spacing: 0) {
                
                // 문의하기 (메일)
                Button {
                    openMail()
                } label: {
                    navigationRow(title: "문의하기")
                }
                
                Divider()
                    .padding(.leading, 16)
                
                // 개인정보처리방침
                NavigationLink {
                    PrivacyPolicyWebView(
                        title: "개인정보처리방침",
                        urlString: "https://debonair-harbor-0b5.notion.site/ShortPath-34020ea7138b806cae3ef78465880c25?source=copy_link"
                    )
                } label: {
                    navigationRow(title: "개인정보 처리방침")
                }
                .buttonStyle(.plain)
                
                Divider()
                    .padding(.leading, 16)
                
                // 위치 권한 설정
                Button {
                    openAppSettings()
                } label: {
                    navigationRow(title: "위치 권한 설정")
                }
                .buttonStyle(.plain)
            }
            .background(Color(UIColor(hex: "0xF5F5F5")))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    func infoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.black)
            
            Spacer()
            
            Text(value)
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 16)
        .frame(height: 52)
    }
    
    func navigationRow(title: String) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.black)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 16)
        .frame(height: 52)
        .contentShape(Rectangle())
    }
}

extension SettingView {
    func openMail() {
        let email = "hyouk970510@gmail.com"
        let subject = "ShortPath에 대해 문의하기"
        let body = "내용을 입력해주세요."
        
        let urlString = "mailto:\(email)?subject=\(subject)&body=\(body)"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        if let url = URL(string: urlString ?? "") {
            UIApplication.shared.open(url)
        }
    }
    
    func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(url) else { return }
        
        UIApplication.shared.open(url)
    }
}
    
struct PrivacyPolicyWebView: View {
    let title: String
    let urlString: String
    
    var body: some View {
        Group {
            if let url = URL(string: urlString) {
                WebView(url: url)
            } else {
                VStack {
                    Spacer()
                    Text("올바른 URL이 아닙니다.")
                        .foregroundColor(.gray)
                    Spacer()
                }
            }
        }
        .background(Color.white)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.backgroundColor = .white
        webView.isOpaque = false
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

struct OpenSourceLicenseDetailView: View {
    let title: String
    let licenseText: String
    let sourceURL: String?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(licenseText)
                    .font(.system(size: 14))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                
                if let sourceURL,
                   let url = URL(string: sourceURL) {
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("GitHub")
                            .font(.footnote)
                            .foregroundColor(.gray)
                        
                        Link(destination: url) {
                            Text(sourceURL)
                                .font(.footnote)
                                .foregroundColor(.blue)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 100)
        }
        .background(Color.white)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color.white, for: .navigationBar)
        .toolbarColorScheme(.light, for: .navigationBar)
        .toolbarRole(.editor)
    }
}

struct OpenSourceLicenseRowView: View {
    let item: OpenSourceLicenseItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.name)
                .font(.body)
                .foregroundStyle(.black)
            
            Text(item.licenseName)
                .font(.subheadline)
                .foregroundStyle(.gray)
        }
        .padding(.vertical, 4)
    }
}

struct OpenSourceLicensesView: View {
    
    private let items: [OpenSourceLicenseItem] = [
        OpenSourceLicenseItem(
            name: "SnapKit",
            licenseName: "MIT License",
            type: .localText(fileName: "SnapKit_LICENSE")
        ),
        OpenSourceLicenseItem(
            name: "RealmSwift",
            licenseName: "Apache License 2.0",
            type: .localText(fileName: "RealmSwift_LICENSE")
        ),
        OpenSourceLicenseItem(
            name: "KakaoMapsSDK",
            licenseName: "Open Source Notice",
            type: .externalURL("https://apis.map.kakao.com/ios_v2/license/")
        ),
        OpenSourceLicenseItem(
            name: "Toast-Swift",
            licenseName: "MIT License",
            type: .localText(fileName: "Toast_LICENSE")
        )
    ]

    var body: some View {
        List {
            SwiftUI.Section {
                ForEach(items) { item in
                    rowView(for: item)
                        .foregroundColor(Color.black)
                }
            } header: {
                Text("사용 중인 라이브러리")
                    .font(.subheadline)
                    .foregroundColor(.black)
            }
            .listRowBackground(Color(UIColor(hex: "0xF5F5F5")))
        }
        .scrollContentBackground(.hidden)
        .background(Color.white)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color.white, for: .navigationBar)
        .toolbarColorScheme(.light, for: .navigationBar)
        .navigationTitle("오픈소스 라이선스")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarRole(.editor)
    }
    
    @ViewBuilder
    private func rowView(for item: OpenSourceLicenseItem) -> some View {
        switch item.type {
        case .localText(let fileName):
            NavigationLink {
                OpenSourceLicenseDetailView(
                    title: item.name,
                    licenseText: LicenseTextLoader.loadText(fileName: fileName),
                    sourceURL: githubURL(for: item.name)
                )
            } label: {
                OpenSourceLicenseRowView(item: item)
            }
            
        case .externalURL(let urlString):
            if let url = URL(string: urlString) {
                Link(destination: url) {
                    HStack {
                        OpenSourceLicenseRowView(item: item)
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .foregroundStyle(.blue)
                    }
                }
            } else {
                OpenSourceLicenseRowView(item: item)
            }
        }
    }
}

private func githubURL(for name: String) -> String? {
    switch name {
    case "SnapKit":
        return "https://github.com/SnapKit/SnapKit"
    case "RealmSwift":
        return "https://github.com/realm/realm-swift"
    case "Toast-Swift":
        return "https://github.com/scalessec/Toast-Swift"
    default:
        return nil
    }
}

private func row(title: String, value: String) -> some View {
    HStack {
        Text(title)
            .foregroundColor(.black)
        Spacer()
        Text(value)
            .foregroundColor(.black)
    }
    .padding()
}

private func buttonRow(title: String) -> some View {
    HStack {
        Text(title)
            .foregroundColor(.black)
        Spacer()
    }
    .padding()
    .contentShape(Rectangle())
}


//#Preview {
//    SettingView()
//}
