//
//  LoginViewController.swift
//  GameOfChats
//
//  Created by John Raymund Catahay on 24/04/2017.
//  Copyright © 2017 John Raymund Catahay. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class LoginViewController: UIViewController {

    let inputsContainerView: UIView = {
        let inputsContainerView = UIView()
        inputsContainerView.backgroundColor = .white
        inputsContainerView.translatesAutoresizingMaskIntoConstraints = false
        inputsContainerView.layer.cornerRadius = 5
        inputsContainerView.layer.masksToBounds = true
        return inputsContainerView
    }()
    
    lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        button.setTitle("REGISTER", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(handleLoginOrRegister), for: .touchUpInside)
        return button
    }()
    
    func handleLoginOrRegister(){
        if loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
            handleLogin()
        }else{
            handleRegister()
        }
    }
    
    func handleLogin(){
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                print("auth error occured: \(String(describing: error?.localizedDescription))")
                return
            }
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    func handleRegister(){
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text, let chosenImage = profileImageView.image, chosenImage != #imageLiteral(resourceName: "winter-logo") else { return }
        
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                print("auth error occured: \(String(describing: error?.localizedDescription))")
                return
            }
            guard let uid = user?.uid else { return }
            
            self.upload(forUID: uid, userProfileImage: chosenImage, completion: { (result) in
                switch result{
                case .Success(let url):
                    let userProfile = UserProfile(name: name, email: email, password: password, profileImageURL: url)
                    self.updateUserProfile(forUID: uid, withProfile: userProfile, completion: { (error) in
                        print("yay :D")
                        self.dismiss(animated: true, completion: nil)
                    })
                    break
                case .Failure(let error):
                    break
                }
            })
        })
    }
    
    let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Name"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let nameSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let emailsSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = #imageLiteral(resourceName: "winter-logo")
        imageView.backgroundColor = .clear
        imageView.layer.shadowRadius = 2
        imageView.layer.shadowOpacity = 0.3
        imageView.layer.shadowOffset = .zero
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector((handleTapImageView))))
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    func handleTapImageView(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    lazy var loginRegisterSegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Login","Register"])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.tintColor = .white
        sc.selectedSegmentIndex = 0
        sc.addTarget(self, action: #selector(segmentControlValueChanged), for: .valueChanged)
        return sc
    }()
    
    func segmentControlValueChanged(){
        let title = loginRegisterSegmentedControl.titleForSegment(at: loginRegisterSegmentedControl.selectedSegmentIndex)
        loginButton.setTitle(title, for: .normal)
        
        containerViewHeightAnchor?.constant = loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 100 : 150
        
        nameTextFieldHeightAnchor?.isActive = false
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0 : 0.33)
        nameTextFieldHeightAnchor?.isActive = true
        nameTextField.isHidden = loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? true : false
        
        emailTextFieldHeightAnchor?.isActive = false
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0.5 : 0.33)
        emailTextFieldHeightAnchor?.isActive = true
        
        passwordTextFieldHeightAnchor?.isActive = false
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0.5 : 0.33)
        passwordTextFieldHeightAnchor?.isActive = true
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .heroBlue
        view.addSubview(inputsContainerView)
        view.addSubview(loginButton)
        view.addSubview(profileImageView)
        view.addSubview(loginRegisterSegmentedControl)
        
        setUpInputsContainer()
        setUpRegisterButton()
        setupLogoImageView()
        setupRegisterSegmentedControl()
        
        segmentControlValueChanged()
    }
    
    func setupRegisterSegmentedControl(){
        loginRegisterSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterSegmentedControl.bottomAnchor.constraint(equalTo: inputsContainerView.topAnchor, constant: -12).isActive = true
        loginRegisterSegmentedControl.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        loginRegisterSegmentedControl.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    func setupLogoImageView(){
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: loginRegisterSegmentedControl.topAnchor, constant: -12).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
    }
    
    func setUpRegisterButton(){
        loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginButton.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor, constant: 12).isActive = true
        loginButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
    }
    
    var containerViewHeightAnchor: NSLayoutConstraint?
    var nameTextFieldHeightAnchor: NSLayoutConstraint?
    var emailTextFieldHeightAnchor: NSLayoutConstraint?
    var passwordTextFieldHeightAnchor: NSLayoutConstraint?
    
    func setUpInputsContainer(){
        inputsContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        containerViewHeightAnchor = inputsContainerView.heightAnchor.constraint(equalToConstant: 150)
        containerViewHeightAnchor?.isActive = true
        
        //name text field
        inputsContainerView.addSubview(nameTextField)
        nameTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        nameTextField.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true
        nameTextField.rightAnchor.constraint(equalTo: inputsContainerView.rightAnchor, constant: 12).isActive = true
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 0.33)
        nameTextFieldHeightAnchor?.isActive = true
        
        //name separator
        inputsContainerView.addSubview(nameSeparatorView)
        nameSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        nameSeparatorView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        nameSeparatorView.rightAnchor.constraint(equalTo: inputsContainerView.rightAnchor).isActive = true
        nameSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //email textfield
        inputsContainerView.addSubview(emailTextField)
        emailTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        emailTextField.topAnchor.constraint(equalTo: nameSeparatorView.bottomAnchor).isActive = true
        emailTextField.rightAnchor.constraint(equalTo: inputsContainerView.rightAnchor, constant: 12).isActive = true
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 0.33)
        emailTextFieldHeightAnchor?.isActive = true
        
        //email separator
        inputsContainerView.addSubview(emailsSeparatorView)
        emailsSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        emailsSeparatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        emailsSeparatorView.rightAnchor.constraint(equalTo: inputsContainerView.rightAnchor).isActive = true
        emailsSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //password text field
        inputsContainerView.addSubview(passwordTextField)
        passwordTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: emailsSeparatorView.bottomAnchor).isActive = true
        passwordTextField.rightAnchor.constraint(equalTo: inputsContainerView.rightAnchor, constant: 12).isActive = true
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 0.33)
        passwordTextFieldHeightAnchor?.isActive = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
}

struct UserProfile{
    let name: String
    let email: String
    let password: String
    let profileImageURL: String
}

typealias URLString = String

enum Result<ResultObject>{
    case Success(ResultObject)
    case Failure(Error)
}

//uploading stuff
extension LoginViewController{
    
    func upload(forUID uid: String, userProfileImage: UIImage, completion: @escaping (_ result: Result<URLString>) -> Void){
        //upload the image first
        let storageRef = FIRStorage.storage().reference().child("profileImageViews").child("\(uid).png")
        guard let imageData = UIImagePNGRepresentation(userProfileImage) else { return }
        storageRef.put(imageData, metadata: nil, completion: { (metaData, error) in
            if let error = error {
                completion(.Failure(error))
            }else{
                if let url = metaData?.downloadURL()?.absoluteString{
                    completion(.Success(url))
                }else{
                    
                }
            }
        })
    }
    
    func updateUserProfile(forUID uid: String, withProfile profile: UserProfile, completion: @escaping (_ error: Error?) -> Void) {
        let ref = FIRDatabase.database().reference(fromURL: firURL)
        let userRef = ref.child("users").child(uid)
        let values = ["email": profile.email,
                      "password": profile.password,
                      "name": profile.name,
                      "profileImageURL": profile.profileImageURL]
        
        userRef.updateChildValues(values, withCompletionBlock: { (error, ref) in
            if error != nil {
                print("auth error occured: \(String(describing: error?.localizedDescription))")
                completion(error)
                return
            }
            print("saved user successfully")
            completion(nil)
        })
    }
}

extension LoginViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = getImage(fromPickerViewInfo: info){
            profileImageView.image = image
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        profileImageView.image = #imageLiteral(resourceName: "winter-logo")
        dismiss(animated: true, completion: nil)
    }
}

func getImage(fromPickerViewInfo info: [String: Any]) -> UIImage?{
    if let chosen = info[UIImagePickerControllerEditedImage] as? UIImage{
        return chosen
    }else{
        return info[UIImagePickerControllerOriginalImage] as? UIImage
    }
}
