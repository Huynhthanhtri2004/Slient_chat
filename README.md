# Silent Chat

App chat realtime (Flutter + Firebase) – đăng nhập email, chat 1–1, preview tin nhắn cuối, thả cảm xúc, link preview, dark/light theme.

## Chạy thử

```bash
git clone https://github.com/<username>/slient_chat.git
cd slient_chat
flutter pub get
flutterfire configure   # đăng nhập Firebase, chọn project → tạo firebase_options & google-services
flutter run
```

**Yêu cầu:** Flutter SDK, Firebase project (bật Auth Email/Password + Firestore).  
**Lưu ý:** File cấu hình Firebase (`firebase_options.dart`, `google-services.json`) đã nằm trong `.gitignore` – sau khi clone cần chạy `flutterfire configure` hoặc copy file từ nơi an toàn.
