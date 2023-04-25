//
//  TutorialSlide.swift
//  JobDeal
//
//  Created by Nikola Majstorovic on 24.7.22..
//  Copyright © 2022 Qwertify. All rights reserved.
//

import UIKit

class TutorialSlide: UIView {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var textView: UILabel!
        
    

    func update(
        imageOne: String,
        imageTwo: String,
        text: String
    ) {
        imageView.image = UIImage(named: imageOne)
        imageView2.image = UIImage(named: imageTwo)
        textView.text = text
        
        
        imageView.contentMode = .scaleAspectFit
        imageView2.contentMode = .scaleAspectFit
    }

}

final class TutorialSlideNew: UIView {
    public var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    lazy var imageViewOne: UIImageView = makeImageView()
    lazy var imageViewTwo: UIImageView = makeImageView()
    lazy var label: UILabel = makeLabel()
    
    init(
        imageOne: String,
        imageTwo: String,
        textKey: String
    ) {
        super.init(frame: .zero)
        
        setup()
        
        update(
            imageOne: imageOne,
            imageTwo: imageTwo,
            textKey: textKey
        )
    }
    
    private func update(
        imageOne: String,
        imageTwo: String,
        textKey: String
    ) {

        imageViewOne.image = UIImage(named: imageOne)
        imageViewTwo.image = UIImage(named: imageTwo)
        label.text = LanguageManager.sharedInstance.getStringForKey(
            key: textKey
        )
        
        if screenHeight <= 667.0 {
            label.font = label.font.withSize(14)

        }
    }
    
    private func setup() {
        let isSmallScreen = screenHeight <= 667.0
        addSubview(imageViewOne)
        if isSmallScreen {
            imageViewOne.snp.makeConstraints {
                $0.top.equalToSuperview().offset(70)
                $0.trailing.equalTo(snp.centerX)
                $0.width.equalTo(168)
                $0.height.equalTo(300)
            }
        } else {
            imageViewOne.snp.makeConstraints {
                $0.top.equalToSuperview().offset(100)
                $0.trailing.equalTo(snp.centerX)
                $0.width.equalTo(168)
                $0.height.equalTo(300)
            }
        }
       
        
        addSubview(imageViewTwo)
        imageViewTwo.snp.makeConstraints {
            $0.top.equalTo(imageViewOne.snp.top)
            $0.leading.equalTo(snp.centerX)
            $0.width.equalTo(imageViewOne.snp.width)
            $0.height.equalTo(imageViewOne.snp.height)
        }
        
        addSubview(label)
        if isSmallScreen {
            label.snp.makeConstraints {
                $0.top.equalTo(imageViewOne.snp.bottom).offset(18)
                $0.leading.trailing.equalToSuperview().inset(16)
                $0.centerX.equalToSuperview()
            }
        } else {
            label.snp.makeConstraints {
                $0.top.equalTo(imageViewOne.snp.bottom).offset(28)
                $0.leading.trailing.equalToSuperview().inset(16)
                $0.centerX.equalToSuperview()
            }
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

private extension TutorialSlideNew {
    
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.numberOfLines = 0
        view.textAlignment = .center
        view.textColor = .white
        return view
    }
    
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }
    
}
