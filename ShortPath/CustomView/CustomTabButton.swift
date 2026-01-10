//
//  CustomTabButton.swift
//  ShortPath
//
//  Created by 선상혁 on 12/29/25.
//

import UIKit

final class CustomTabButton: UIButton {
    
    var defaultImage: String!
    var title: String!
    var selectedImage: String!
    
    init(defaultImage: String, title: String, selectedImage: String) {
        super.init(frame: .zero)
        
        self.defaultImage = defaultImage
        self.title = title
        self.selectedImage = selectedImage
        
        configure()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        var config = UIButton.Configuration.plain()
        var titleContainer = AttributeContainer()
        
        titleContainer.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        config.attributedTitle = AttributedString(title, attributes: titleContainer)
        config.baseForegroundColor = .black
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 15)
        config.imagePadding = 5
        config.imagePlacement = .top
        
        self.configuration = config
        
        self.configurationUpdateHandler = { [unowned self] button in
            var selectedContainer = AttributeContainer()
            selectedContainer.font = .systemFont(ofSize: 10, weight: .bold)
            
            var container = AttributeContainer()
            container.font = UIFont.systemFont(ofSize: 10, weight: .regular)
            
            var configuration = button.configuration
            
            switch button.state {
            case .selected:
                selectedContainer.foregroundColor = .black
                configuration?.image = UIImage(systemName: selectedImage)
                configuration?.background.backgroundColor = .white
                configuration?.attributedTitle = AttributedString(self.title, attributes: selectedContainer)
            case .highlighted:
                break
            default:
                container.foregroundColor = .black
                configuration?.image = UIImage(systemName: defaultImage)
                configuration?.background.backgroundColor = .white
                configuration?.attributedTitle = AttributedString(self.title, attributes: container)
            }
            
            button.configuration = configuration
        }
    }
}
