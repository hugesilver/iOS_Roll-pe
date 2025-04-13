//
//  ChangePasswordViewController.swift
//  Roll-Pe
//
//  Created by DongHyeokHwang on 1/31/25.
//

import UIKit
import SnapKit
import SwiftUI
import RxSwift

class ChangePasswordViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private let changePasswordViewModel = ChangePasswordViewModel()
    private let userViewModel = UserViewModel()
    
    // MARK: - 요소
    
    // 네비게이션 바
    private let navigationBar: NavigationBar = {
        let navigationBar = NavigationBar()
        navigationBar.menuIndex = 4
        navigationBar.showSideMenu = true
        
        return navigationBar
    }()
    
    // 제목
    private let titleLabel : UILabel = {
        let label = UILabel()
        label.text = "비밀번호 변경"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .rollpeSecondary
        
        if let customFont = UIFont(name: "HakgyoansimDunggeunmisoOTF-R", size: 32) {
            label.font = customFont
        } else {
            label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        }
        
        return label
    }()
    
    // 비밀번호 text field
    private let changePasswordTextField: RoundedBorderTextField = {
        let textField = RoundedBorderTextField()
        textField.placeholder = "새 비밀번호"
        textField.textContentType = .password
        textField.isSecureTextEntry = true
        
        return textField
    }()
    
    // 비밀번호 확인 text field
    private let confirmPasswordTextField: RoundedBorderTextField = {
        let textField = RoundedBorderTextField()
        textField.placeholder = "새 비밀번호 확인"
        textField.textContentType = .password
        textField.isSecureTextEntry = true
        
        return textField
    }()
    
    // 변경 버튼
    private let changeConfirmButton = PrimaryButton(title: "변경하기")
    
    // 로딩 뷰
    private let loadingView: LoadingView = {
        let view = LoadingView()
        view.isHidden = true
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 네비게이션 및 배경 설정
        view.backgroundColor = .rollpePrimary
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        // Bind 설정
        bind()
        
        // UI 설정
        setupNavigationBar()
        setupTitleLabel()
        setupChangePasswordTextField()
        setupConfirmPasswordTextField()
        setupChangeConfirmButton()
        
        addLoadingView()
    }
    
    // MARK: - UI 설정
    
    // 로딩 뷰
    private func addLoadingView() {
        view.addSubview(loadingView)
        
        loadingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupNavigationBar() {
        view.addSubview(navigationBar)
        
        navigationBar.parentViewController = self
        
        navigationBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
    }
    
    private func setupTitleLabel() {
        view.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(76)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupChangePasswordTextField() {
        view.addSubview(changePasswordTextField)
        
        changePasswordTextField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(52)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
    }
    
    private func setupConfirmPasswordTextField() {
        view.addSubview(confirmPasswordTextField)
        
        confirmPasswordTextField.snp.makeConstraints { make in
            make.top.equalTo(changePasswordTextField.snp.bottom).offset(8)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
    }
    
    private func setupChangeConfirmButton(){
        view.addSubview(changeConfirmButton)
        
        changeConfirmButton.snp.makeConstraints { make in
            make.top.equalTo(confirmPasswordTextField.snp.bottom).offset(32)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
    }
    
    // MARK: - Bind
    
    private func bind() {
        let input = ChangePasswordViewModel.Input(
            password: changePasswordTextField.rx.text,
            confirmPassword: confirmPasswordTextField.rx.text,
            buttonTapEvent: changeConfirmButton.rx.tap
        )
        
        let output = changePasswordViewModel.transform(input)
        
        output.isButtonEnabled
            .drive(onNext: { isEnabled in
                self.changeConfirmButton.disabled = !isEnabled
            })
            .disposed(by: disposeBag)
        
        output.isLoading
            .drive(onNext: { isLoading in
                self.loadingView.isHidden = !isLoading
            })
            .disposed(by: disposeBag)
        
        output.successAlertMessage
            .drive(onNext: { message in
                if let message = message {
                    self.showSuccessAlert(message: message)
                }
            })
            .disposed(by: disposeBag)
        
        output.errorAlertMessage
            .drive(onNext: { message in
                if let message = message {
                    self.showErrorAlert(message: message)
                }
            })
            .disposed(by: disposeBag)
        
        output.criticalAlertMessage
            .drive(onNext: { message in
                if let message = message {
                    self.showCriticalErrorAlert(message: message)
                }
            })
            .disposed(by: disposeBag)
    }
    
    // 완료 알림창
    private func showSuccessAlert(message: String) {
        let alertController = UIAlertController(title: "알림", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
            self.userViewModel.logout()
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    // 오류 알림창
    private func showErrorAlert(message: String) {
        let alertController = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    // 심각한 오류 알림창
    private func showCriticalErrorAlert(message: String) {
        let alertController = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
            self.navigationController?.popViewController(animated: true)
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
}

#if DEBUG
struct ChangePasswordViewControllerPreview: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreview {
            ChangePasswordViewController()
        }
    }
}
#endif
