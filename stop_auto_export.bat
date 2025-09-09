@echo off
echo Stopping Dunjon Auto Export Service...
taskkill /f /im python.exe /fi "WINDOWTITLE eq Dunjon Auto Export*"
echo Service stopped
pause
