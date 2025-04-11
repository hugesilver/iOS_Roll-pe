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

// 서버 IP 주소
let ip: String = Bundle.main.object(forInfoDictionaryKey: "SERVER_IP") as! String

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
        return "마감"
    }
}

// YYYY.M.D 계산
func dateToYYYYMD(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy.M.d"
    return dateFormatter.string(from: date)
}

// YYYY년 MM월 DD일 계산
func dateToYYYYMd(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "ko_KR")
    dateFormatter.dateFormat = "yyyy년 M월 d일"
    return dateFormatter.string(from: date)
}

// YYYY-MM-dd date로 변환
func convertYYYYMMddToDate(_ string: String) -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    dateFormatter.locale = Locale(identifier: "ko_KR")
    
    return dateFormatter.date(from: string)!
}

// 한글 날짜에서 yyyy-MM-dd 형식으로 변환
func convertDateFormat(_ input: String) -> String? {
    // 입력 형식 정의
    let inputFormatter = DateFormatter()
    inputFormatter.locale = Locale(identifier: "ko_KR")
    inputFormatter.dateFormat = "yyyy년 M월 d일 a h시"
    inputFormatter.amSymbol = "오전"
    inputFormatter.pmSymbol = "오후"
    
    let outputFormatter = DateFormatter()
    outputFormatter.dateFormat = "yyyy-MM-dd"
    
    guard let date = inputFormatter.date(from: input) else {
        print("날짜 변환 실패: \(input)")
        return nil
    }
    
    return outputFormatter.string(from: date)
}

extension UIViewController {
    // 키보드 숨기기
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // RxSwift + 확인 알림창
    func showConfirmAlert(title: String?, message: String?) -> Observable<Void> {
        let result = PublishSubject<Void>()
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "확인", style: .default, handler: { _ in
            result.onNext(())
            result.onCompleted()
        })
        let cancel = UIAlertAction(title: "취소", style: .cancel) { _ in
            result.onCompleted()
        }
        alert.addAction(ok)
        alert.addAction(cancel)
        present(alert, animated: true)
        return result
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

// hex에서 UIColor로 변환
extension UIColor {
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        let r = CGFloat((rgb >> 16) & 0xFF) / 255.0
        let g = CGFloat((rgb >> 8) & 0xFF) / 255.0
        let b = CGFloat(rgb & 0xFF) / 255.0

        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}

// UILabel에 line-height 설정
extension UILabel {
    func setTextWithLineHeight(text: String?, lineHeight: CGFloat) {
        if let text = text {
            let style = NSMutableParagraphStyle()
            style.maximumLineHeight = lineHeight
            style.minimumLineHeight = lineHeight
            
            let attributes: [NSAttributedString.Key: Any] = [
                .paragraphStyle: style,
                .baselineOffset: (lineHeight - font.lineHeight) / 4
            ]
            
            let attrString = NSAttributedString(string: text,
                                                attributes: attributes)
            self.attributedText = attrString
        }
    }
}
