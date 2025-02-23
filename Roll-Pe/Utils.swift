//
//  Utils.swift
//  Roll-Pe
//
//  Created by 김태은 on 1/19/25.
//

import Foundation
import UIKit
import SwiftUI
import RxSwift
import RxCocoa

// safearea
let scenes = UIApplication.shared.connectedScenes
let windowScene = scenes.first as? UIWindowScene
let window = windowScene?.windows.first

let safeareaTop = window?.safeAreaInsets.top ?? 0
let safeareaBottom = window?.safeAreaInsets.bottom ?? 0

// 이미지 비율 계산
func getImageRatio(image: UIImage) -> CGFloat {
    return image.size.width / image.size.height
}

// D-day 계산
func dateToDDay(_ endDate: Date) -> String {
    let today = Date()
    let calendar = Calendar.current
    
    guard let daysDifference = calendar.dateComponents([.day], from: today, to: endDate).day else {
        return "Error calculating D-Day"
    }
    
    if daysDifference == 0 {
        return "D-Day"
    } else if daysDifference > 0 {
        return "D-\(daysDifference)"
    } else {
        return "D+\(abs(daysDifference))"
    }
}

// YYYY.M.D 계산
func dateToYYYYMD(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy.M.d"
    return dateFormatter.string(from: date)
}

// YYYY년 MM월 DD일 A HH:mm 계산
func dateToYYYYMdahhmm(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "ko_KR")
    dateFormatter.dateFormat = "yyyy년 M월 d일 a hh:mm"
    return dateFormatter.string(from: date)
}

// YYYY-MM-dd date로 변환
func convertYYYYMMddToDate(_ string: String) -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    dateFormatter.locale = Locale(identifier: "ko_KR")
    
    return dateFormatter.date(from: string)!
}

// 키보드 숨기기
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

// 미리보기
struct UIViewControllerPreview: UIViewControllerRepresentable {
    let viewController: () -> UIViewController
    
    init(_ viewController: @escaping () -> UIViewController) {
        self.viewController = viewController
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        return viewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

// 버튼 여백 수정
extension UIButton {
    func removeConfigurationPadding() {
        var config = UIButton.Configuration.plain()
        config.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        self.configuration = config
    }
    
    // removeConfigurationPadding를 사용하는 경우 font 적용
    func setFont(_ font: UIFont) {
        self.configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = font
            return outgoing
        }
    }
}

// UILabel rx.tap 추가
extension Reactive where Base: UILabel {
    var tap: Observable<Void> {
        let tapGestureRecognizer = UITapGestureRecognizer()
        
        base.addGestureRecognizer(tapGestureRecognizer)
        base.isUserInteractionEnabled = true

        return tapGestureRecognizer.rx.event
            .map { _ in () }
            .asObservable()
    }
}
