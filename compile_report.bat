@echo off
echo Compiling CHOLO Project Diagrams...
echo.

cd project_report

echo [1/3] Compiling diagrams...
pdflatex -interaction=nonstopmode diagrams.tex
if %errorlevel% neq 0 (
    echo Error compiling diagrams!
    pause
    exit /b 1
)

echo.
echo [2/3] Compiling main report...
pdflatex -interaction=nonstopmode report.tex
if %errorlevel% neq 0 (
    echo Error compiling report!
    pause
    exit /b 1
)

echo.
echo [3/3] Compiling report again for TOC...
pdflatex -interaction=nonstopmode report.tex

echo.
echo ============================================
echo Compilation Complete!
echo ============================================
echo Generated files:
echo - diagrams.pdf (6 diagrams)
echo - report.pdf (main report)
echo ============================================
pause
