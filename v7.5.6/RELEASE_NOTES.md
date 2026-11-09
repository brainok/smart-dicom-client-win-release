# SMART DICOM Client v7.5.6

Windows 통합 설치 패키지에서 Tailscale 연결과 MagicDNS 설정을 확인하도록 수정했습니다.

- Tailscale이 설치되지 않은 PC에서는 포함된 MSI로 설치합니다.
- Tailscale 로그인이 필요한 경우 브라우저 인증을 안내합니다.
- Brainok Tailnet 연결 여부를 확인하고 Tailscale DNS를 활성화한 뒤 서버 연결을 검사합니다.
- 연결에 실패하면 원인별 오류를 표시하고 설치를 중단합니다.

`Smart-DICOM-Client.msi`, `Tailscale.msi`, `Brainok-Network-Setup.exe`는 v7.5.5와 동일한 바이너리입니다. v7.5.6은 설치 패키지와 설치 스크립트의 배포 버전입니다.

설치: ZIP 전체를 한 폴더에 압축 해제한 다음 `Install-SMART-DICOM-Client.cmd`를 실행하세요. Tailscale 계정 인증과 Brainok 네트워크 등록에는 사용자 입력이 필요할 수 있습니다.
