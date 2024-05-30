//
//  AvatarView.swift
//  DynamicIslandDemo
//
//  Created by Сергей Штейман on 11.03.2024.
//

import SwiftUI


// MARK: - AvatarViewRepresentable
struct AvatarViewRepresentable: UIViewRepresentable {
    
    var shouldShow: Bool
    
    func makeUIView(context: Context) -> AvatarView {
        return AvatarView()
    }

    func updateUIView(_ uiView: AvatarView, context: Context) {
        uiView.shouldShow = shouldShow
    }
}

// MARK: - AvatarView
final class AvatarView: UIView {
    
    private var adaptiveTopAnchor: NSLayoutConstraint?
    
    private var heighAnchorForFullAvatar: NSLayoutConstraint?
    private var widthAnchorForFullAvatar: NSLayoutConstraint?
    
    private var heighAnchorForHiddenAvatar: NSLayoutConstraint?
    private var widthAnchorForHiddenAvatar: NSLayoutConstraint?
    
    private var firstOpen: Bool = true
    
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "Puslan"))
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 45
        imageView.clipsToBounds = true
        return imageView
    }()
    
    var shouldShow: Bool = false {
        didSet {
            if shouldShow == true {
                shouldShowFullAvatar()
            }
            if shouldShow == false && !firstOpen {
                shouldHideFullAvatar()
            } else {
                firstOpen = false
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        addSubview(avatarImageView)
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            avatarImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
        ])
        
        adaptiveTopAnchor = avatarImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 30)
        adaptiveTopAnchor?.isActive = true
        
        heighAnchorForHiddenAvatar = avatarImageView.heightAnchor.constraint(equalToConstant: Const.MainView.imageSize)
        heighAnchorForHiddenAvatar?.isActive = true
        widthAnchorForHiddenAvatar = avatarImageView.widthAnchor.constraint(equalTo: avatarImageView.heightAnchor)
        widthAnchorForHiddenAvatar?.isActive = true
        
        heighAnchorForFullAvatar = avatarImageView.heightAnchor.constraint(equalToConstant: Const.MainView.fullImageSize)
        widthAnchorForFullAvatar = avatarImageView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width)
    }
    
    func shouldShowFullAvatar() {
        UIView.animate(withDuration: 0.15, animations: {
            self.avatarImageView.layer.cornerRadius = 0
            self.heighAnchorForHiddenAvatar?.isActive = false
            self.widthAnchorForHiddenAvatar?.isActive = false
            self.heighAnchorForFullAvatar?.isActive = true
            self.widthAnchorForFullAvatar?.isActive = true
            self.adaptiveTopAnchor?.constant = -60
            self.haptics(.medium)
            self.layoutIfNeeded()
        })
    }
    
    func shouldHideFullAvatar() {
        UIView.animate(withDuration: 0.15, animations: {
            self.avatarImageView.layer.cornerRadius = 45
            self.heighAnchorForFullAvatar?.isActive = false
            self.widthAnchorForFullAvatar?.isActive = false
            self.heighAnchorForHiddenAvatar?.isActive = true
            self.widthAnchorForHiddenAvatar?.isActive = true
            self.adaptiveTopAnchor?.constant = 30
            self.haptics(.soft)
            self.layoutIfNeeded()
        })
    }
}
