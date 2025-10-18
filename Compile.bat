@echo off

chcp 65001 >nul

call :setESC

set THESIS=main

set flag=%1
if %flag%x == x (
	set flag=thesis
)

if %flag%x == thesisx (
	call :cleanall
	call :thesis	
	if ERRORLEVEL 1 (
		echo.
		echo %ESC%[31mError! Please check the %ESC%[7m'%THESIS%.log'%ESC%[0;31m for more details . . .%ESC%[0m
		pause
	) else (
		call :clean
		echo %ESC%[32mFinished!%ESC%[0m
		pause
	)
	goto :EOF
)

if %flag%x == cleanx (
	call :clean
	goto :EOF
)

if %flag%x == cleanallx (
	call :cleanall
	goto :EOF
)

if %flag%x == wordcountx (
	call :wordcount
	goto :EOF
)

:help
	echo %ESC%[33mThis is the compile batch script for SJTUThesis.
	echo Usage:
	echo     compile.bat [option]
	echo options:
	echo   thesis    Compile the thesis (default)
	echo   clean     Clean all work files
	echo   cleanall  Clean all work files and main.pdf
	echo   wordcount Count words in main.pdf
	echo   help      Print this help message%ESC%[0m
goto :EOF

:thesis
	echo %ESC%[33mCompile . . .%ESC%[0m
	latexmk -quiet -file-line-error -halt-on-error -interaction=nonstopmode %THESIS% 2>nul
goto :EOF

:clean
	echo %ESC%[33mClean files . . .%ESC%[0m
	latexmk -quiet -c %THESIS% 2>nul
goto :EOF

:cleanall
	echo %ESC%[33mClean files . . .%ESC%[0m
	latexmk -quiet -C %THESIS% 2>nul
	if exist %THESIS%.pdf (
		echo %ESC%[31mClose the file: %ESC%[7m'%THESIS%.pdf'%ESC%[0;31m!%ESC%[0m
		pause
		call :cleanall
	)
goto :EOF
:wordcount
    setlocal enabledelayedexpansion

    rem ——判断英文（支持 en / english）
    findstr /I /R /C:"^[ ]*\\documentclass\[[^]]*lang *= *en" "%THESIS%.tex" >nul
    if %errorlevel% equ 0 (
        rem 英文：统计字符（如需英文单词，改 -word）
        for /f "usebackq delims=" %%i in (`texcount "%THESIS%.tex" -inc -char-only 2^>nul`) do (
            echo %%i | findstr /I "total" >nul
            if not errorlevel 1 (
                echo %ESC%[33m英文字符数            :%ESC%[36m%%i%ESC%[0m
                goto total
            )
        )
    ) else (
        rem 非英文：同样用 -char-only；若你更偏好中文统计可用 -chinese（看发行版支持）
        for /f "usebackq delims=" %%i in (`texcount "%THESIS%.tex" -inc -char-only 2^>nul`) do (
            echo %%i | findstr /I "total" >nul
            if not errorlevel 1 (
                echo %ESC%[33m纯中文字数            :%ESC%[36m%%i%ESC%[0m
                goto total
            )
        )
    )

:total
    rem 这里直接让 texcount 只输出总数，避免再去找 total 行
    for /f "usebackq delims=" %%i in (`texcount "%THESIS%.tex" -inc -chinese -sum -1 2^>nul`) do (
        echo %ESC%[33m总字数（英文单词 + 中文字） :%ESC%[36m%%i%ESC%[0m
        endlocal
        goto :EOF
    )

    rem 如果走不到上面的 for（比如 -chinese 不被支持），回退方案：
    for /f "usebackq delims=" %%i in (`texcount "%THESIS%.tex" -inc -sum 2^>nul ^| findstr /I /C:"Sum" /C:"Total"`) do (
        echo %ESC%[33m总字数（汇总）            :%ESC%[36m%%i%ESC%[0m
        endlocal
        goto :EOF
    )

    endlocal
    goto :EOF

:setESC
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (
	set ESC=%%b
	exit /B 0
)
exit /B 0
