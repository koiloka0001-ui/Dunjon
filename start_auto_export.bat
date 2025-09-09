@echo off
echo Starting Dunjon Auto Export Service...
cd /d "C:\Users\koiko\Projects\dunjon"
start "Dunjon Auto Export" python auto_export_tiles.py
echo Service started in background window
pause


