//
//  ProfileView.swift
//  DynamicIslandDemo
//
//  Created by Konstantin Stolyarenko on 09.11.2023.
//  Copyright © 2023 SKS. All rights reserved.
//

import SwiftUI


// 1) Следаить непосредственно за offsetY
// 2) Дергать переключатель непосредственно в AvatarView

// MARK: - AvatarViewRepresentable
struct AvatarViewRepresentable: UIViewRepresentable {
    
    @Binding var offsetY: Bool
    
    func makeUIView(context: Context) -> AvatarView {
        return AvatarView()
    }

    func updateUIView(_ uiView: AvatarView, context: Context) {
        uiView.shouldShow = offsetY
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
        
        heighAnchorForHiddenAvatar = avatarImageView.heightAnchor.constraint(equalToConstant: 90)
        heighAnchorForHiddenAvatar?.isActive = true
        widthAnchorForHiddenAvatar = avatarImageView.widthAnchor.constraint(equalTo: avatarImageView.heightAnchor)
        widthAnchorForHiddenAvatar?.isActive = true
        
        heighAnchorForFullAvatar = avatarImageView.heightAnchor.constraint(equalToConstant: 375)
        widthAnchorForFullAvatar = avatarImageView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width)
    }
    
    func shouldShowFullAvatar() {
        UIView.animate(withDuration: 0.25, animations: {
            self.avatarImageView.layer.cornerRadius = 0
            self.heighAnchorForHiddenAvatar?.isActive = false
            self.widthAnchorForHiddenAvatar?.isActive = false
            self.heighAnchorForFullAvatar?.isActive = true
            self.widthAnchorForFullAvatar?.isActive = true
            self.adaptiveTopAnchor?.constant = -60
            self.layoutIfNeeded()
        })
    }
    
    func shouldHideFullAvatar() {
        UIView.animate(withDuration: 0.25, animations: {
            self.avatarImageView.layer.cornerRadius = 45
            self.heighAnchorForFullAvatar?.isActive = false
            self.widthAnchorForFullAvatar?.isActive = false
            self.heighAnchorForHiddenAvatar?.isActive = true
            self.widthAnchorForHiddenAvatar?.isActive = true
            self.adaptiveTopAnchor?.constant = 30
            self.layoutIfNeeded()
        })
    }
}

// MARK: - ProfileView
struct ProfileView: View {

    // MARK: - Private Properties

    @ObservedObject private var viewModel: ViewModel
    @Environment(\.scenePhase) private var scenePhase

    // MARK: - Init

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    @State private var showFullAvatar: Bool = false
    
    // MARK: - Body

    var body: some View {
        GeometryReader { bounds in
            ZStack(alignment: .top) {
//                if viewModel.isIslandShapeVisible {
//                    Canvas { context, size in
//                        context.addFilter(.alphaThreshold(min: 0.5, color: .black))
//                        context.addFilter(.blur(radius: 6))
//                        context.drawLayer { ctx in
//                            if let island = ctx.resolveSymbol(id: Const.MainView.islandViewId) {
//                                ctx.draw(island, at: CGPoint(x: (size.width / 2),
//                                                             y: viewModel.islandTopPadding + (viewModel.islandSize.height / 2)))
//                            }
//                            if let image = ctx.resolveSymbol(id: Const.MainView.imageViewId) {
//                                let yImageOffset = (Const.MainView.imageSize / 2) + Const.MainView.imageTopPadding
//                                let yImagePosition = bounds.safeAreaInsets.top + yImageOffset + 22
//                                ctx.draw(image, at: CGPoint(x: size.width / 2, y: yImagePosition))
//                            }
//                        }
//                    } symbols: {
//                        islandShapeView()
//                        avatarShapeView()
//                    }
//                    .edgesIgnoringSafeArea(.top)
//                }
                avatarView(offsetY: bounds)
                scrollView()
                navigationButtons()
            }
        }
        .background(Color(uiColor: .systemGray6))
        .onChange(of: scenePhase) { newPhase in
            let isActive = newPhase == .active
            let duration = isActive ? 0.3 : .zero
            withAnimation(Animation.linear(duration: duration).delay(duration)) {
                viewModel.isIslandShapeVisible = isActive
            }
        }
    }

    // MARK: - Private Methods

    private func islandShapeView() -> some View {
        Capsule(style: .continuous)
            .frame(width: viewModel.islandSize.width,
                   height: viewModel.islandSize.height,
                   alignment: .center)
            .scaleEffect(viewModel.islandScale)
            .tag(Const.MainView.islandViewId)
    }

    private func avatarShapeView() -> some View {
        Circle()
            .fill(.black)
            .frame(width: Const.MainView.imageSize, height: Const.MainView.imageSize, alignment: .center)
            .scaleEffect(viewModel.scale)
            .offset(y: max(-viewModel.offset.y, -Const.MainView.imageSize + Const.MainView.imageSize.percentage(20)))
            .tag(Const.MainView.imageViewId)
    }

    private func avatarView(offsetY: GeometryProxy) -> some View {
        let height: CGFloat = showFullAvatar ? Const.MainView.fullImageSize : Const.MainView.imageSize
        let width: CGFloat = showFullAvatar ? UIScreen.main.bounds.width : height
        return AvatarViewRepresentable(offsetY: $showFullAvatar)
            .frame(height: 100)
            .scaleEffect(viewModel.scale)
//            .blur(radius: viewModel.blur)
//            .opacity(showFullAvatar ? 1 : viewModel.avatarOpacity)
            .offset(y: max(-viewModel.offset.y, -Const.MainView.imageSize + Const.MainView.imageSize.percentage(10)))
            .onChange(of: viewModel.offset.y, perform: { offset in
                if offset <= -10 && !showFullAvatar  {
                    showFullAvatar = true
                }
                if offset >= 10 && showFullAvatar {
                    showFullAvatar = false
                }
            })
    }

    private func scrollView() -> some View {
        OffsetObservingScrollView(
            offset: $viewModel.offset,
            showsIndicators: $viewModel.showsIndicators,
            isHeaderPagingEnabled: $viewModel.isHeaderPagingEnabled
        ) {
            LazyVStack(
                alignment: .center,
                pinnedViews: viewModel.isHeaderPinningEnabled ? [.sectionHeaders] : []
            ) {
                Section(header: Text("")) {
                    Text("\(viewModel.offset.y)")
                    Text("\(viewModel.scale)")
//                    AvatarViewRepresentable(offsetY: $showFullAvatar)
                }
                Section(header: headerView()) {
                    scrollViewCells()
                }
            }
            .padding(.top, Const.MainView.imageSize + Const.MainView.imageTopPadding)
            .padding(.horizontal)
        }
        .padding(.top, Const.MainView.imageTopPadding)
        .scrollDismissesKeyboard(.interactively)
    }

    private func headerView() -> some View {
        VStack(spacing: 4.0) {
            Text(viewModel.userName)
                .font(.system(size: viewModel.titleFontSize, weight: .medium))

            HStack(spacing: 4.0) {
                Text(viewModel.userPhoneNumber)
                Text(Const.General.bulletPointSymbol)
                Text(viewModel.userNickname)
            }
            .foregroundColor(Color(uiColor: .systemGray))
            .font(.system(size: viewModel.descriptionFontSize, weight: .regular))
            .opacity(viewModel.headerOpacity)
            .padding(.bottom, viewModel.headerPadding)
        }
        .frame(maxWidth: .infinity)
        .background(Color(uiColor: .systemGray6))
        .id(Const.MainView.headerViewId)
    }

    private func scrollViewCells() -> some View {
        VStack(spacing: 24.0) {
//            generalSettingsCells()
//            headerSettingsCells()
            emptyCells()
        }
    }

    private func generalSettingsCells() -> some View {
        VStack(spacing: 24.0) {
            ToggleCellView(parameterName: "Indicators", isToggleOn: $viewModel.showsIndicators)
            ToggleCellView(parameterName: "Zoom Effect", isToggleOn: $viewModel.isZoomEffectEnabled)
        }
    }

    private func headerSettingsCells() -> some View {
        VStack {
            ToggleCellView(parameterName: "Header Paging", isToggleOn: $viewModel.isHeaderPagingEnabled)
            ToggleCellView(parameterName: "Header Pinning", isToggleOn: $viewModel.isHeaderPinningEnabled)
        }
    }

    private func emptyCells() -> some View {
        VStack {
            ForEach(0..<25) { _ in
                ToggleCellView(isToggleOn: .constant(false), showToggle: false)
            }
        }
    }

    private func navigationButtons() -> some View {
        HStack {
            if viewModel.isAvatarHidden {
                Button {
                    print("QR button tapped")
                } label: {
                    Image(systemName: "qrcode").imageScale(.large)
                }
                .opacityTransition(move: .top)
            }

            Spacer()

            Button {
                print("\(viewModel.isAvatarHidden ? "Edit" : "Search") button tapped")
            } label: {
                if viewModel.isAvatarHidden {
                    AnyView(Text("Edit"))
                        .opacityTransition(move: .top)
                } else {
                    if viewModel.isHeaderPinningEnabled {
                        AnyView(Image(systemName: "magnifyingglass").imageScale(.large))
                            .opacityTransition(move: .bottom)
                    }
                }
            }
        }
        .padding(.horizontal, 16.0)
        .padding(.top, 4.0)
        .onChange(
            of: viewModel.percentage,
            perform: { value in
                withAnimation(.linear(duration: 0.2)) {
                    viewModel.isAvatarHidden = !(value == 100)
                }
            }
        )
    }
}

// MARK: - PreviewProvider

struct ProfileView_Previews: PreviewProvider {

    static var previews: some View {
        ProfileView(viewModel: .init(user: .mock()))
    }
}
