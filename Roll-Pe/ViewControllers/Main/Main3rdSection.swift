//
//  Main3rdSection.swift
//  Roll-Pe
//
//  Created by 김태은 on 1/20/25.
//

import UIKit
import SnapKit

class Main3rdSection: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .rollpeSectionBackground
        
        let contentView: UIStackView = UIStackView()
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.axis = .vertical
        contentView.spacing = 44
        contentView.alignment = .leading
        
        contentView.isLayoutMarginsRelativeArrangement = true
        contentView.layoutMargins = UIEdgeInsets(top: 76, left: 0, bottom: 56, right: 0)
        
        self.addSubview(contentView)
        
        contentView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(40)
            make.bottom.equalToSuperview()
        }
        
        // 제목
        let title: UILabel = UILabel()
        title.textColor = .rollpeSecondary
        title.font = UIFont(name: "HakgyoansimDunggeunmisoOTF-R", size: 28)
        title.numberOfLines = 2
        title.textAlignment = .left
        title.text = "함께 나누었던 추억,\n언제 어디서나"
        
        contentView.addArrangedSubview(title)
        
        // 이미지
        let imageView: UIImageView = UIImageView()
        let image: UIImage! = UIImage(named: "MainThirdSection")
        imageView.image = image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        
        contentView.addArrangedSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(imageView.snp.width).dividedBy(getImageRatio(image: image!))
        }
        
        self.snp.makeConstraints { make in
            make.height.equalTo(contentView.snp.height)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
