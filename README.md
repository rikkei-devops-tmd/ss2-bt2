BÀI TẬP 2: KHỞI TẠO USER THƯỜNG VÀ THIẾT LẬP ĐẶC QUYỀN QUẢN TRỊ (SUDOERS CONFIGURATION)

1. MỤC TIÊU
- Tạo một tài khoản người dùng thường (non-root user) có tên là "devops" trên hệ điều hành Ubuntu Server.
- Cấp đặc quyền quản trị an toàn thông qua nhóm "sudo" và cấu hình sudoers theo nguyên tắc đặc quyền tối thiểu (Least Privilege).
- Sao chép và phân quyền chính xác SSH Key từ tài khoản root sang thư mục home của user devops để đăng nhập an toàn từ xa.

2. CÁC LỆNH LINUX THỰC HIỆN TRÊN SERVER

2.1. Tạo tài khoản người dùng devops
Chạy lệnh tạo user mới:
```bash
sudo adduser devops
```
Hoặc tạo không cần tương tác mật khẩu nếu dùng SSH Key:
```bash
sudo adduser --disabled-password --gecos "" devops
```

2.2. Thêm user devops vào nhóm quản trị sudo
```bash
sudo usermod -aG sudo devops
```

2.3. Sao chép cấu hình SSH Key từ root sang user devops
Cách 1: Dùng lệnh rsync
```bash
sudo rsync --archive --chown=devops:devops ~/.ssh /home/devops/
```

Cách 2: Tạo thư mục và copy thủ công
```bash
sudo mkdir -p /home/devops/.ssh
sudo cp /root/.ssh/authorized_keys /home/devops/.ssh/authorized_keys
sudo chown -R devops:devops /home/devops/.ssh
sudo chmod 700 /home/devops/.ssh
sudo chmod 600 /home/devops/.ssh/authorized_keys
```

2.4. Thiết lập cấu hình Sudoers (tùy chọn cấp quyền không cần hỏi pass nếu dùng keypair)
```bash
echo "devops ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/devops
sudo chmod 440 /etc/sudoers.d/devops
```

3. KIỂM TRA ĐĂNG NHẬP VÀ XÁC THỰC QUYỀN HẠN

3.1. Đăng nhập từ máy cá nhân bằng user devops
```bash
ssh -i ~/.ssh/id_ed25519_do devops@159.223.45.67
```

3.2. Chạy lệnh kiểm tra đặc quyền quản trị
```bash
sudo whoami
```

4. KẾT QUẢ KIỂM TRA VÀ LOG TERMINAL

Log kiểm tra xác thực quyền sudo:
```text
$ ssh -i ~/.ssh/id_ed25519_do devops@159.223.45.67
Welcome to Ubuntu 22.04.3 LTS (GNU/Linux 5.15.0-88-generic x86_64)

devops@ptit-devops-server:~$ whoami
devops

devops@ptit-devops-server:~$ id
uid=1001(devops) gid=1001(devops) groups=1001(devops),27(sudo)

devops@ptit-devops-server:~$ sudo whoami
root

devops@ptit-devops-server:~$ ls -la /home/devops/.ssh
total 12
drwx------ 2 devops devops 4096 Oct  4 10:15 .
drwxr-x--- 3 devops devops 4096 Oct  4 10:15 ..
-rw------- 1 devops devops  102 Oct  4 10:15 authorized_keys
```

5. KẾT LUẬN
- User devops được khởi tạo thành công với thư mục home riêng và thuộc nhóm sudo.
- Cấu hình SSH Key và phân quyền thư mục .ssh (700) cùng file authorized_keys (600) hoạt động chuẩn xác.
- Đăng nhập SSH bằng user devops và thực thi lệnh quản trị qua sudo thành công.
