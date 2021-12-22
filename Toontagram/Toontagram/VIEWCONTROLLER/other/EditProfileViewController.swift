//
//  EditProfileViewController.swift
//  Toontagram
//
//  Created by MacBookPro on 2021/12/20.
//

import UIKit
import SDWebImage
import SnapKit
import YPImagePicker
import Photos
import PhotosUI

protocol EditProfileViewControllerDelegate : AnyObject {
    func didFinish(_ vc : EditProfileViewController)
}
class EditProfileViewController: UIViewController {
    //MARK: - Properties
    private lazy var profilePhoto : UIImageView = {
        // 제스처 추가해야됨
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(changeUserPhoto))
        tap.numberOfTapsRequired = 1
        imageView.addGestureRecognizer(tap)
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    private lazy var backPhotoIv : UIImageView = {
        // 제스처 추가해야됨
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(profileBackTap))
        tap.numberOfTapsRequired = 1
        imageView.addGestureRecognizer(tap)
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    private lazy var introducetf : UITextField = {
        let tf = UITextField()
        tf.borderStyle = .none
        tf.textColor = .label
        tf.font = .systemFont(ofSize: 12, weight: .semibold)
        tf.keyboardType = .emailAddress
        tf.backgroundColor = .lightGray
        tf.layer.cornerRadius = 10
        tf.text = user?.introduction
        tf.leftPadding()
        tf.attributedPlaceholder = NSAttributedString(string: "자기소개", attributes: [.foregroundColor: UIColor(white: 1, alpha: 0.7)])
        return tf
    }()
    private lazy var endEdit : UIButton = {
        let bt = UIButton()
        bt.setTitle("저장", for: .normal)
        bt.setTitleColor(.white, for: .normal)
        bt.backgroundColor = .darkGray
        bt.titleLabel?.font = .systemFont(ofSize: 12, weight: .bold)
        bt.addTarget(self, action: #selector(didTapEditEnd), for: .touchUpInside)
        return bt
    }()
    weak var delegate : EditProfileViewControllerDelegate?
    
    var user : User? {
        didSet { configure() }
    }
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configure()
    }
    //MARK: - Configure
    func configure(){
        guard let user = user else { return }
        let userVM = ProfileHeaderViewModel(user: user)
        view.addSubview(backPhotoIv)
        backPhotoIv.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(140)
        }
        backPhotoIv.sd_setImage(with: userVM.backgrounImage)
        view.addSubview(profilePhoto)
        profilePhoto.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(140)
            make.height.equalTo(140)
        }
        profilePhoto.layer.cornerRadius = 140/2
        profilePhoto.sd_setImage(with: userVM.profileImageUrl)
        view.addSubview(introducetf)
        introducetf.snp.makeConstraints { make in
            make.top.equalTo(profilePhoto.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
            make.height.equalTo(40)
        }
        introducetf.attributedText = userVM.introduction
        view.addSubview(endEdit)
        endEdit.snp.makeConstraints { make in
            make.top.equalTo(introducetf.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(140)
            make.height.equalTo(40)
        }
    }
    //MARK: - @objc Method
    @objc func changeUserPhoto(){
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = 1
        config.filter = .images // 이미지만 동영상불가능
        let pickerVC = PHPickerViewController(configuration: config) //PickerViewController
        pickerVC.delegate = self
        present(pickerVC, animated: true, completion: nil)
    }
    @objc func profileBackTap(){
        var configure = YPImagePickerConfiguration()
        configure.library.mediaType = .photo
        configure.startOnScreen = .library
        configure.library.maxNumberOfItems = 1
        let picker = YPImagePicker(configuration: configure)
        picker.modalPresentationStyle = .fullScreen
        present(picker, animated: true, completion: nil)
        didFinishPick(picker)
    }
    func didFinishPick(_ picker : YPImagePicker) {
        picker.didFinishPicking { items, _ in
            picker.dismiss(animated: false) {
                guard let selectImage = items.singlePhoto?.image else { return }
                self.backPhotoIv.image = selectImage
            }
        }
    }
    @objc func didTapEditEnd(){
        showLoader(true)
        guard let img = profilePhoto.image , let  image = backPhotoIv.image , let intro = introducetf.text,let user = self.user else { return }
        UserService.editUserData(user: user, profile: img, backImage: image, intro: intro) { result in
            self.showLoader(false)
                let alert = UIAlertController(title: "변경", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { act in
                    self.delegate?.didFinish(self)
                }))
                self.present(alert, animated: true, completion: nil)
        }
    }
}
//MARK: - Extension
extension EditProfileViewController : PHPickerViewControllerDelegate {
func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
    picker.dismiss(animated: true, completion: nil)
    results.forEach { result in
        result.itemProvider.loadObject(ofClass: UIImage.self) { bridge, error in
            guard let image = bridge as? UIImage,error == nil else { return }
            DispatchQueue.main.async {
                self.profilePhoto.image = image
            }
        }
    }
}
}
