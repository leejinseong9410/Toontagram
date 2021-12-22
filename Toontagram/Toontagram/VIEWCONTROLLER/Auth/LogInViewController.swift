//
//  LogInViewController.swift
//  Toontagram
//
//  Created by MacBookPro on 2021/12/13.
//

import UIKit
import Combine
import SnapKit
//MARK: - AuthDelegate
/*
 AuthDelegate <= 앱 계획 당시 coordinator 등은 생각하지 않고 navigationController,혹시 present 로 전환을 생각했다
 이유 : firebase 앱을 만들다보면 노트북이 상당히 버거워 하는 느낌. fetch들이 너무 느림,이유없는? 크러쉬가 많이 나옴 그래서 뷰 전환은 가볍게 띄우고 dismiss로 대체
 상황 : dismiss이기 때문에 로그아웃 > 다른계정 로그인 해도 데이터가 그대로 남음
 해결 : 로그인버튼을 누른후(didTapLogin) 성공하면 delegate 메소드 실행 -> MainTabCT로 넘어가서 DataFetch를 실행 -> 그데이터를 가지고 ProfileVC에 init으로 fetch된 데이터를 넘겨줌(데이터 처리를 미리 하고 입장) 프로필 작업단계에서 발견 회원가입도 마찬가지라 수정해야됨
 */
protocol AuthDelegate : AnyObject {
    func authComplete()
}
/*
 로그인,회원가입 버튼과 각 필드들에게 RxCocoa or Combine 으로 alpha 값이나 isEnabled 값을 조종할수 있지만
 라이브러리 사용하지않고 구현해보고 싶다. AuthViewModel에 method들을 만들어 값이 바뀔때마다 호출하는 형식으로 로직을 구성
 */
class LogInViewController: UIViewController {
    //MARK: - Properties
    
    private let emailtf : UITextField = {
        let tf = UITextField()
        tf.borderStyle = .none
        tf.textColor = .label
        tf.font = .systemFont(ofSize: 12, weight: .semibold)
        tf.keyboardType = .emailAddress
        tf.backgroundColor = .lightGray
        tf.layer.cornerRadius = 10
        tf.leftPadding()
        tf.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [.foregroundColor: UIColor(white: 1, alpha: 0.7)])
        return tf
    }()
    private let passwordtf : UITextField = {
        let tf = UITextField()
        tf.borderStyle = .none
        tf.textColor = .label
        tf.font = .systemFont(ofSize: 12, weight: .semibold)
        tf.keyboardType = .numbersAndPunctuation
        tf.isSecureTextEntry = true
        tf.backgroundColor = .lightGray
        tf.layer.cornerRadius = 10
        tf.leftPadding()
        tf.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [.foregroundColor: UIColor(white: 1, alpha: 0.7)])
        return tf
    }()
    
    private let LogInBt : UIButton = {
        let bt = UIButton(type: .system)
        bt.setTitle("로그인", for: .normal)
        bt.setTitleColor(.white, for: .normal)
        bt.layer.cornerRadius = 10
        bt.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)
        return bt
    }()
    private let accountBt : UIButton = {
        let bt = UIButton(type: .system)
        bt.attributedTitle(firstPart: "작가님! 혹시 계정이 없으신가요?", secondPart: " 회원가입")
        bt.addTarget(self, action: #selector(accountAction), for: .touchUpInside)
        return bt
    }()
    private let reAccountBt : UIButton = {
        let bt = UIButton(type: .system)
        bt.attributedTitle(firstPart: "작가님! 혹시 계정이 기억나지 않습니까?", secondPart: " 계정찾기")
        bt.addTarget(self, action: #selector(findAccount), for: .touchUpInside)
         return bt
    }()
    var vM : LoginVM!
    private var cancellable = Set<AnyCancellable>()
    private var stackView : UIStackView!
    // weak 로 한 이유 : 메모리가 점점 올라가기 때문에
    // 안해도 앱을 실행 되지만 작업이 많아지면 크러쉬가 나는경우도 있다
    weak var delegate : AuthDelegate?
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        vM = LoginVM()
        configure()
        dismisskeyboardAround()
        moveViewKeyboardAppearOrDisappear()
    }
    
    //MARK: - Configure
    private func configure(){
        view.backgroundColor = .white
        combined()
        setUpStackView()
        view.addSubview(LogInBt)
        LogInBt.snp.makeConstraints { (make) in
            make.top.equalTo(stackView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(45)
            make.trailing.equalToSuperview().offset(-45)
            make.height.equalTo(50)
        }
        view.addSubview(reAccountBt)
        reAccountBt.snp.makeConstraints { (make) in
            make.top.equalTo(LogInBt.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(45)
            make.trailing.equalToSuperview().offset(-45)
            make.height.equalTo(50)
        }
        view.addSubview(accountBt)
        accountBt.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-50)
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(45)
            make.trailing.equalToSuperview().offset(-45)
            make.height.equalTo(50)
        }
        combined()
    }
    private func combined(){
        passwordtf.publisher.receive(on: RunLoop.main).assign(to:\.passwordnput, on: vM).store(in: &cancellable)
        emailtf.publisher.receive(on: RunLoop.main).assign(to:\.emailInput, on: vM).store(in: &cancellable)
        vM.isEmpty.receive(on: RunLoop.main).assign(to: \.isVaild, on: LogInBt).store(in: &cancellable)
        
    }
    private func setUpStackView(){
        stackView = UIStackView(arrangedSubviews: [emailtf,passwordtf])
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 10
        view.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.centerY.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(100)
        }
    }
    
    //MARK: - @objc Action
    
    @objc private func didTapSignIn(){
        showLoader(true)
        guard let email = emailtf.text , let password = passwordtf.text else { return }
        AuthService.logInUser(with: email, password: password) { (result,error) in
            if error != nil {
                self.showLoader(false)
                print("DEBUG = login\(String(describing: error?.localizedDescription))")
                let alert = UIAlertController(title: "LogIn - Fail", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil ))
                self.present(alert, animated: true, completion: nil)
                return
            }else{
                self.showLoader(false)
                let alert = UIAlertController(title: "LogIn - Success", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { act in
                    self.delegate?.authComplete()
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    @objc private func accountAction(){
        let vc = RegisterViewController()
        vc.delegate = delegate
        navigationController?.pushViewController(vc, animated: true)
    }
    @objc private func findAccount(){
        
    }
}
//MARK: - Extension
extension UITextField {
    var publisher : AnyPublisher<String,Never> {
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: self)
            .compactMap { $0.object as? UITextField } //UITextField 가져오기
            .map { $0.text ?? "" }  //텍스트 가져오기 옵셔널 처리해줘야됨
            .eraseToAnyPublisher()
    }
}
extension UIButton {
    var isVaild : Bool {
        get {
            backgroundColor == .darkGray
        }
        set {
            backgroundColor = newValue ? .darkGray : .lightGray.withAlphaComponent(0.8)
            isEnabled = newValue
        }
    }
}
