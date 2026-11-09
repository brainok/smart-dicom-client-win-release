@echo off
chcp 65001 > nul
setlocal EnableExtensions EnableDelayedExpansion
title SMART DICOM Client 설치

set "ROOT=%~dp0"
set "TAILSCALE=%ROOT%Tailscale.msi"
set "NETWORK_SETUP=%ROOT%Brainok-Network-Setup.exe"
set "CLIENT=%ROOT%Smart-DICOM-Client.msi"
set "TAILSCALE_SETUP=%ROOT%Configure-Brainok-Tailscale.ps1"
set "BRAINOK_SERVER=http://zyst.taila65c71.ts.net:4040"
set "BRAINOK_HEALTH=%BRAINOK_SERVER%/health"
set "BRAINOK_REGISTER_API=%BRAINOK_SERVER%/api/install/register"

echo.
echo SMART DICOM Client 설치
echo.
echo 이 설치 프로그램은 다음 순서로 진행합니다:
echo   1. Tailscale 설치
echo   2. Tailscale 연결 및 DNS 자동 설정 ^(브라우저 인증이 필요할 수 있음^)
echo   3. Brainok 서버 health 확인
echo   4. 이 PC를 Brainok 보안 네트워크에 등록
echo   5. SMART DICOM Client 설치
echo.
echo Brainok 서버: !BRAINOK_SERVER!
echo 등록 서버 API: !BRAINOK_REGISTER_API!
echo 이 주소는 Tailscale Tailnet 내부에서만 연결됩니다.
echo.

for %%F in ("!TAILSCALE!" "!NETWORK_SETUP!" "!CLIENT!" "!TAILSCALE_SETUP!") do (
  if not exist "%%~F" (
    echo 필요한 파일이 없습니다: %%~nxF
    echo ZIP의 모든 파일을 같은 폴더에 압축 해제하십시오.
    pause
    exit /b 1
  )
)

if exist "%ProgramFiles%\Tailscale\tailscale.exe" (
  echo Tailscale이 이미 설치되어 있습니다.
) else (
  echo Tailscale 설치 중...
  echo Windows 관리자 권한 확인 창과 설치 진행 창이 표시됩니다.
  echo 권한 확인 창에서 예를 선택한 뒤 진행 창이 닫힐 때까지 기다리십시오.
  start "" /wait msiexec.exe /i "!TAILSCALE!" /passive /norestart
  set "EXIT_CODE=!ERRORLEVEL!"
  if not "!EXIT_CODE!"=="0" if not "!EXIT_CODE!"=="3010" (
    echo Tailscale 설치 실패. 종료 코드: !EXIT_CODE!
    pause
    exit /b !EXIT_CODE!
  )
  if not exist "%ProgramFiles%\Tailscale\tailscale.exe" (
    echo Tailscale 설치는 성공으로 보고되었지만 프로그램 파일을 찾을 수 없습니다.
    echo Windows를 한 번 다시 시작한 뒤 이 명령 파일을 다시 실행하십시오.
    pause
    exit /b 1603
  )
)

echo.
echo Tailscale 연결 및 DNS 설정 중...
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "!TAILSCALE_SETUP!" -ServerHost "zyst.taila65c71.ts.net" -ServerPort 4040
set "EXIT_CODE=!ERRORLEVEL!"
if not "!EXIT_CODE!"=="0" (
  echo.
  echo Tailscale 연결 또는 Brainok 서버 확인에 실패했습니다.
  echo 기존 Tailscale 로그인은 변경하지 않았습니다.
  pause
  exit /b !EXIT_CODE!
)
echo Brainok 서버 health 확인 성공.

echo.
echo Brainok 네트워크 설정을 시작합니다...
echo 서버 주소 입력란: !BRAINOK_SERVER!
echo 등록 서버 API 주소를 직접 묻는 경우: !BRAINOK_REGISTER_API!
echo Site Uploader ID와 병원 비밀번호를 입력하십시오.
start "" /wait "!NETWORK_SETUP!"
set "EXIT_CODE=!ERRORLEVEL!"
if not "!EXIT_CODE!"=="0" (
  echo Brainok 네트워크 설정이 완료되지 않았습니다. 종료 코드: !EXIT_CODE!
  echo SMART DICOM Client를 설치하지 않았습니다.
  pause
  exit /b !EXIT_CODE!
)

echo.
echo SMART DICOM Client 설치 중...
echo Windows 설치 진행 창이 표시됩니다.
start "" /wait msiexec.exe /i "!CLIENT!" /passive /norestart
set "EXIT_CODE=!ERRORLEVEL!"
if not "!EXIT_CODE!"=="0" if not "!EXIT_CODE!"=="3010" (
  echo SMART DICOM Client 설치 실패. 종료 코드: !EXIT_CODE!
  pause
  exit /b !EXIT_CODE!
)

if "!EXIT_CODE!"=="3010" (
  echo SMART DICOM Client 설치가 완료되었지만 Windows 재시작이 필요할 수 있습니다.
)

set "CLIENT_APP="
for %%P in ("%ProgramFiles%\SMART DICOM Client\SmartDicomClient.Win.exe" "%ProgramW6432%\SMART DICOM Client\SmartDicomClient.Win.exe") do (
  if exist "%%~fP" (
    set "CLIENT_APP=%%~fP"
    goto LAUNCH_CLIENT_APP
  )
)

:LAUNCH_CLIENT_APP
echo.
echo 설치가 완료되었습니다.
if defined CLIENT_APP (
  echo SMART DICOM Client를 실행합니다...
  start "" "!CLIENT_APP!"
) else (
  echo SMART DICOM Client 실행 파일을 찾을 수 없습니다.
  echo 시작 메뉴 또는 바탕화면 바로가기로 SMART DICOM Client를 실행하십시오.
)
pause
exit /b 0
