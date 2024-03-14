//
//  LableView.swift
//  DynamicIslandDemo
//
//  Created by Сергей Штейман on 13.03.2024.
//

import SwiftUI


// MARK: - LabelViewRepresentable
struct LabelViewRepresentable: UIViewRepresentable {
    
    var text: String
    
    var isShowFullAvatar: Bool
    
    var fontSize: CGFloat

    func makeUIView(context: Context) -> LableView {
        let label = LableView()
        label.label.text = text
        return LableView()
    }

    func updateUIView(_ uiView: LableView, context: Context) {
        uiView.label.text = text
        uiView.isShowFullAvatar = isShowFullAvatar
        uiView.label.font = .systemFont(ofSize: fontSize, weight: .semibold)
    }
    
}

// MARK: - LableView
final class LableView: UIView {
    
    private var centerContentAlignment: NSLayoutConstraint?
    private var leadingContentAlignment: NSLayoutConstraint?
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
//        label.font = .preferredFont(forTextStyle: .title1)
        label.font = .systemFont(ofSize: 28, weight: .semibold)
        return label
    }()
    
    var isShowFullAvatar: Bool = false {
        didSet {
            if isShowFullAvatar {
                shouldShowFullAvatar()
            } else {
                shouldHideFullAvatar()
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
    
    func setupView() {
        addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        centerContentAlignment = label.centerXAnchor.constraint(equalTo: centerXAnchor)
        centerContentAlignment?.isActive = true
        
        leadingContentAlignment = label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -15)
    }
    
    func shouldShowFullAvatar() {
        UIView.animate(withDuration: 0.25, animations: {
            self.centerContentAlignment?.isActive = false
            self.leadingContentAlignment?.isActive = true
            self.label.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            self.label.textColor = .white
            self.layoutIfNeeded()
        })
    }
    
    func shouldHideFullAvatar() {
        UIView.animate(withDuration: 0.25, animations: {
            self.leadingContentAlignment?.isActive = false
            self.centerContentAlignment?.isActive = true
            self.label.transform = CGAffineTransform.identity
            self.label.textColor = UIScreen.main.traitCollection.userInterfaceStyle == .dark ? .white : .black
            self.layoutIfNeeded()
        })
    }
    
}


// MARK: - PreviewProvider
struct LableView_Previews: PreviewProvider {

    static var previews: some View {
        ProfileView(viewModel: .init(user: .mock()))
    }
}
