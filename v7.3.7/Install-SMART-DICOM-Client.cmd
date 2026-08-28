@echo off
setlocal
title SMART DICOM Client installation
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Install-SMART-DICOM-Client.ps1"
set "EXIT_CODE=%ERRORLEVEL%"
if not "%EXIT_CODE%"=="0" (
  echo.
  echo Installation did not complete. Exit code: %EXIT_CODE%
  pause
)
exit /b %EXIT_CODE%
