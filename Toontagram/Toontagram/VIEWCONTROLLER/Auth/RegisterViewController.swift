//
//  RegisterViewController.swift
//  Toontagram
//
//  Created by MacBookPro on 2021/12/13.
//
import UIKit
import SnapKit
import Combine
import Photos
import PhotosUI
import YPImagePicker

class RegisterViewController: UIViewController {
    //MARK: - Properties
    private let photoBt : UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "plus.circle")
        button.setBackgroundImage(image, for: .normal)
        button.clipsToBounds = true
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(changeUserPhoto), for: .touchUpInside)
        return button
    }()
    private lazy var backPhotoIv : UIImageView = {
        // 제스처 추가해야됨
        let image = UIImage(named: "logo")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(profileBackTap))
        tap.numberOfTapsRequired = 1
        imageView.addGestureRecognizer(tap)
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
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
    private let nametf : UITextField = {
        let tf = UITextField()
        tf.borderStyle = .none
        tf.textColor = .label
        tf.font = .systemFont(ofSize: 12, weight: .semibold)
        tf.backgroundColor = .lightGray
        tf.layer.cornerRadius = 10
        tf.leftPadding()
        tf.attributedPlaceholder = NSAttributedString(string: "Name", attributes: [.foregroundColor: UIColor(white: 1, alpha: 0.7)])
        return tf
    }()
    private let penNametf : UITextField = {
        let tf = UITextField()
        tf.borderStyle = .none
        tf.textColor = .label
        tf.font = .systemFont(ofSize: 12, weight: .semibold)
        tf.backgroundColor = .lightGray
        tf.layer.cornerRadius = 10
        tf.leftPadding()
        tf.attributedPlaceholder = NSAttributedString(string: "Pename", attributes: [.foregroundColor: UIColor(white: 1, alpha: 0.7)])
        return tf
    }()
    private let introductiontf : UITextField = {
        let tf = UITextField()
        tf.borderStyle = .none
        tf.textColor = .label
        tf.font = .systemFont(ofSize: 12, weight: .semibold)
        tf.backgroundColor = .lightGray
        tf.layer.cornerRadius = 10
        tf.leftPadding()
        tf.attributedPlaceholder = NSAttributedString(string: "Introduction..", attributes: [.foregroundColor: UIColor(white: 1, alpha: 0.7)])
        return tf
    }()
    private let SignInBt : UIButton = {
        let bt = UIButton(type: .system)
        bt.setTitle("회원가입", for: .normal)
        bt.setTitleColor(.white, for: .normal)
        bt.layer.cornerRadius = 10
        bt.addTarget(self, action: #selector(didTapSignUp), for: .touchUpInside)
        return bt
    }()
    var vM : SignInVM!
    private var stacktView : UIStackView!
    private var cancellable = Set<AnyCancellable>()
    
    private var profileImage : UIImage?
    private var profileBackground : UIImage?
    
    weak var delegate : AuthDelegate?
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        vM = SignInVM()
        combined()
        view.backgroundColor = .white
        configure()
        dismisskeyboardAround()
        moveViewKeyboardAppearOrDisappear()
    }
    
    //MARK: - Configure
    private func configure(){
        view.addSubview(backPhotoIv)
        backPhotoIv.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(140)
        }
        view.addSubview(photoBt)
        photoBt.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(140)
            make.height.equalTo(140)
        }
        photoBt.layer.cornerRadius = 140/2
        stackViewSetUp()
        view.addSubview(SignInBt)
        SignInBt.snp.makeConstraints { (make) in
            make.top.equalTo(stacktView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(80)
            make.trailing.equalToSuperview().offset(-80)
            make.height.equalTo(40)
        }
        
    }
    private func stackViewSetUp(){
        stacktView = UIStackView(arrangedSubviews: [emailtf,passwordtf,nametf,penNametf,introductiontf])
        stacktView.spacing = 10
        stacktView.distribution = .fillEqually
        stacktView.axis = .vertical
        view.addSubview(stacktView)
        stacktView.snp.makeConstraints { (make) in
            make.top.equalTo(backPhotoIv.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(300)
        }
    }
    private func combined(){
        emailtf.publisher.receive(on: RunLoop.main).assign(to: \.emailInput, on: vM).store(in: &cancellable)
        passwordtf.publisher.receive(on: RunLoop.main).assign(to:\.passwordnput, on: vM).store(in: &cancellable)
        penNametf.publisher.receive(on: RunLoop.main).assign(to:\.pennameInput, on: vM).store(in: &cancellable)
        nametf.publisher.receive(on: RunLoop.main).assign(to: \.nameInput, on: vM).store(in: &cancellable)
        vM.emptyVaild.receive(on: RunLoop.main).assign(to: \.isVaild, on: SignInBt).store(in: &cancellable)
    }
    func didFinishPick(_ picker : YPImagePicker) {
        picker.didFinishPicking { items, _ in
            picker.dismiss(animated: false) {
                guard let selectImage = items.singlePhoto?.image else { return }
                self.profileBackground = selectImage
                self.backPhotoIv.image = selectImage
            }
        }
    }
    //MARK: - @objc Action
    @objc private func changeUserPhoto(){
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = 1
        config.filter = .images // 이미지만 동영상불가능
        let pickerVC = PHPickerViewController(configuration: config) //PickerViewController
        pickerVC.delegate = self
        present(pickerVC, animated: true, completion: nil)
    }
    @objc private func profileBackTap(){
        var configure = YPImagePickerConfiguration()
        configure.library.mediaType = .photo
        configure.startOnScreen = .library
        configure.library.maxNumberOfItems = 1
        let picker = YPImagePicker(configuration: configure)
        picker.modalPresentationStyle = .fullScreen
        present(picker, animated: true, completion: nil)
        didFinishPick(picker)
    }
    @objc private func didTapSignUp(){
        showLoader(true)
        guard let email = emailtf.text , let password = passwordtf.text , let name = nametf.text , let penname = penNametf.text,let profileImage = profileImage ,let profileBackground = profileBackground, let introduction = introductiontf.text else { return }
        
        let credential = AuthCredentials(email: email, password: password, name: name, penname: penname, profileImage: profileImage,profileBackgroundImage: profileBackground,introduction: introduction)
        AuthService.userRegister(with: credential) { error in
            if error != nil {
                self.showLoader(false)
                print("DEBUG = register\(String(describing: error?.localizedDescription))")
                let alert = UIAlertController(title: "SignUp - Fail", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil ))
                self.present(alert, animated: true, completion: nil)
                return
            }else{
                self.showLoader(false)
                let alert = UIAlertController(title: "SignUp - Success", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "로그인", style: .destructive, handler: { act in
                    self.delegate?.authComplete()
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
}
    //MARK: - Extension
extension RegisterViewController : PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        results.forEach { result in
            result.itemProvider.loadObject(ofClass: UIImage.self) { bridge, error in
                guard let image = bridge as? UIImage,error == nil else { return }
                DispatchQueue.main.async {
                    self.photoBt.setBackgroundImage(image, for: .normal)
                    self.profileImage = image
                }
            }
        }
    }
}
