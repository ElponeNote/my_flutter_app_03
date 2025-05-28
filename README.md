# Thread-Style SNS Flutter App

## 프로젝트 개요
- 트위터/쓰레드 스타일의 간단한 SNS 앱
- 블랙 테마의 미니멀 디자인
- 텍스트/이미지/영상 업로드, 무한 스크롤 피드, 프로필 편집 등 기본 SNS 기능 구현

## 프로젝트 개선 이력 및 구현 상태

이 Flutter 소셜 네트워크 앱의 주요 개선 이력과 현재 구현 상태를 아래와 같이 정리합니다. (2024년 6월 기준)

### [2024-06-09] 구조적 개선
- ProfileData와 Post 모델에 userId(고유 식별자) 필드 도입
- 내 게시글 필터링을 userId로만 수행 (프로필 정보 변경과 무관하게 내 게시글 유지)
- 프로필/게시글 이미지 저장 시 파일명에 userId와 timestamp를 포함하여 중복/덮어쓰기 방지
- 기존 더미 데이터 및 저장된 게시글은 userId가 없으면 빈 문자열로 보정
- (마이그레이션) 기존 내 게시글은 userId가 다를 수 있으니, 새로 작성한 게시글부터 정상 동작

### 1. 홈 탭 헤더 개선
- AppBar 타이틀을 '스쿨코리아'로, 배경색을 검정색(black)으로 통일.

### 2. 프로필 편집 및 영구 저장
- 프로필(이름, 소개, 이미지)은 StateNotifierProvider와 shared_preferences를 통해 영구 저장.
- ProfileData는 toJson/fromJson으로 직렬화.
- 프로필 이미지는 앱의 document 디렉토리에 복사하여 경로만 저장.
- 앱 시작 시 이미지 파일이 없으면 경로를 자동으로 정리.

### 3. UI Overflow 및 입력 UX 개선
- 프로필 화면의 Row/Column 레이아웃 및 버튼 제약 개선.
- Bio 입력란 placeholder UX 개선.

### 4. 게시글(피드) 영구 저장
- Post 모델에 toJson/fromJson 구현.
- 게시글은 shared_preferences에 저장/불러오기.
- PostListNotifier가 게시글 리스트를 관리하며, 모든 변경사항을 영구 저장.
- 앱 시작 시 저장된 게시글이 없으면 더미 데이터 사용.
- 게시글 작성 시 최상단에 추가 및 저장.

### 5. 무한 스크롤 및 더미 게시글 생성
- 홈 피드는 무한 스크롤 지원, 끝에 도달하면 더미 게시글 3개 자동 생성.

### 6. Provider 수정 타이밍 오류 해결
- 빌드 중 provider 수정 오류를 Future.microtask로 비동기 처리하여 방지.

### 7. 이미지 경로 처리 개선
- 게시글/프로필 이미지가 네트워크/로컬 파일을 구분하여 처리.
- 존재하지 않는 파일 경로는 앱 시작 시 자동으로 null 처리.

### 8. 로딩 인디케이터 및 스켈레톤 UI
- 피드 새로고침 시 상단 로딩 인디케이터와 shimmer 패키지 기반 스켈레톤 UI 적용.

### 9. 검색 및 상세 피드 이동
- 검색 결과 클릭 시 상세 게시글 화면으로 이동.

### 10. 좋아요(하트) 및 댓글 기능
- Post 모델에 likes, likedByMe, comments 필드 추가.
- 좋아요 버튼 애니메이션, 색상 변화, 카운트 표시.
- 댓글은 모달 시트로 표시, 실시간 추가 및 카운트, 영구 저장.

### 11. 앱 재시작 시 데이터 유실 문제 근본적 해결
- 프로필/게시글 이미지는 항상 영구 디렉토리에 복사하여 저장.
- 앱 시작 시 temp/없는 파일 경로 자동 정리.
- 모든 데이터가 shared_preferences에서 불러와져 앱 재시작 후에도 유지.

### 12. 최종 상태 확인
- 프로필/게시글 편집 후 앱 재시작 시 데이터가 정상적으로 유지됨을 코드상으로 확인.
- persistence 로직이 견고하게 구현됨.

---

> 이 문서는 향후 기능 추가, 버그 수정, 리팩토링 시 반드시 참고하세요.

## 주요 기능 및 작업 내역

### 1. 프로젝트 구조 및 세팅
- `lib/models`, `lib/screens`, `lib/widgets`, `lib/utils`, `lib/theme` 등 폴더 구조 설계
- `main.dart`에서 Riverpod, go_router, 테마 적용 및 네비게이션 구현

### 2. 홈 피드
- 더미 데이터 기반 무한 스크롤 피드 (`infinite_scroll_pagination`)
- 게시글: 텍스트, 이미지, 영상, 작성자 정보, 시간 표시
- 각 게시글에 좋아요/댓글/리포스트/공유 아이콘 및 동작 구현

### 3. 포스팅(업로드)
- 텍스트 입력, 이미지 업로드(`image_picker`), 영상 업로드(`image_picker`, `video_player`)
- 업로드 시 프로필 정보(이름, 사진, 소개글)도 함께 저장
- 업로드 후 피드에 즉시 반영

### 4. 프로필
- 프로필 사진 업로드(갤러리 선택)
- 프로필 편집(이름, 소개글, 사진 변경)
- 내 게시글 리스트 표시(프로필 정보와 일치하는 게시글만)

### 5. 기타 화면
- 바텀 네비게이션: 홈, 검색, 포스트, 알림, 프로필 탭
- 각 탭별 라우팅(go_router)
- 다크/라이트 테마 지원

### 6. 상태 관리
- Riverpod(StateProvider)로 전역 상태 관리(게시글, 프로필 등)

### 7. 사용 패키지
- flutter_riverpod
- go_router
- image_picker
- video_player
- infinite_scroll_pagination
- intl

## 앞으로 참고할 내용
- 실제 서버 연동/DB 연동은 미구현(더미 데이터 기반)
- 공유, 알림, 댓글 등은 UI/UX 위주, 실제 데이터 저장은 미구현
- 추가 기능(팔로우, 알림, 검색 등) 확장 가능

---

> 이 README.md는 현재까지의 작업 내역과 구조를 요약한 것으로, 이후 작업 시 참고용으로 활용하세요.

## 실행 방법
```bash
flutter pub get
flutter run
```

## 폴더 구조
```
lib/
├── main.dart
├── models/
├── screens/
├── widgets/
├── utils/
└── theme/
```

## 간단한 사용법
- 하단 네비게이션으로 각 탭 이동
- 포스팅 탭에서 글/이미지 업로드
- 검색 탭에서 키워드로 게시글/작성자 검색
- 프로필 탭에서 내 게시글 확인

---

## Getting Started (Flutter 기본 안내)

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# 프로젝트 작업 내역 및 참고사항

## 1. 홈 탭 헤더 수정
- 헤더 색상을 블랙으로, 타이틀을 '스쿨코리아'로 변경

## 2. 프로필 정보(이름/사진) 영구 저장
- StateProvider → StateNotifierProvider 구조로 변경
- shared_preferences를 이용해 프로필 정보(이름, 소개글, 이미지) 영구 저장/불러오기
- ProfileData에 toJson/fromJson 추가
- 저장/불러오기 로직 반영

## 3. 게시글(Post) 영구 저장
- postsProvider를 StateNotifierProvider로 변경
- Post 모델에 toJson/fromJson 추가
- shared_preferences를 이용해 게시글 리스트 영구 저장/불러오기
- 게시글 추가/삭제/수정 시마다 저장

## 4. 더미 데이터 완전 제거
- loadPostsFromPrefs에서 더미 데이터 생성 코드 제거
- 무한 스크롤 시 더미 게시글 추가 로직 제거
- 이제 실제 작성한 게시글만 저장/불러오기/노출됨

## 5. shared_preferences 초기화(더미 데이터 삭제)
- 기존에 남아있던 더미 데이터(posts)를 완전히 삭제하기 위해 main.dart에 clearPostsPrefs() 임시 추가
- 앱 실행 시 shared_preferences의 posts 데이터가 삭제됨을 확인
- 정상 동작 후 해당 코드 삭제

## 6. 시뮬레이터/기기 테스트 팁
- iOS 시뮬레이터에서는 카메라 기능 사용 불가 (Camera not available 에러는 정상)
- 시뮬레이터에서 비디오 업로드 시 "No Videos"가 뜨면, Mac에서 비디오 파일을 시뮬레이터로 드래그&드롭하여 사진 앱에 추가
- 실제 기기에서는 갤러리/카메라/비디오 모두 정상 동작

## 7. UI/UX 개선
- 프로필 상단 Row overflow(버튼 잘림) 문제: Flexible/Expanded/ConstrainedBox로 감싸고 버튼 크기 제한
- 소개글 입력 UX 개선: 입력란 클릭 시 예시문구 자동 삭제
- 로딩 중에는 CircularProgressIndicator 표시

## 8. 기타 참고사항
- 앱 재시작/핫 리스타트/핫 리로드 동작 차이점 숙지
- 데이터 구조 변경 시 마이그레이션 필요할 수 있음

---

**이 문서는 모든 주요 작업 내역을 기록하며, 다음 작업 시 반드시 참고하세요.**
