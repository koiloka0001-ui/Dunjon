#!/usr/bin/env python3
"""
Setup Auto-Export Service
Creates a Windows service or scheduled task to run the auto-export service persistently
"""

import os
import sys
import subprocess
import time
from pathlib import Path

def create_startup_script():
    """Create a startup script that can be run automatically"""
    
    startup_script = """@echo off
cd /d "{}"
python auto_export_tiles.py
pause
""".format(os.getcwd())
    
    with open("start_auto_export_persistent.bat", "w") as f:
        f.write(startup_script)
    
    print("✅ Created start_auto_export_persistent.bat")

def create_windows_service():
    """Create a Windows service for the auto-export (requires admin)"""
    
    service_script = """import win32serviceutil
import win32service
import win32event
import servicemanager
import socket
import sys
import os
import time
import subprocess

class AutoExportService(win32serviceutil.ServiceFramework):
    _svc_name_ = "DunjonAutoExport"
    _svc_display_name_ = "Dunjon Auto Export Tiles"
    _svc_description_ = "Automatically converts Tiled TMX files to JSON for Godot"

    def __init__(self, args):
        win32serviceutil.ServiceFramework.__init__(self, args)
        self.hWaitStop = win32event.CreateEvent(None, 0, 0, None)
        socket.setdefaulttimeout(60)

    def SvcStop(self):
        self.ReportServiceStatus(win32service.SERVICE_STOP_PENDING)
        win32event.SetEvent(self.hWaitStop)

    def SvcDoRun(self):
        servicemanager.LogMsg(servicemanager.EVENTLOG_INFORMATION_TYPE,
                              servicemanager.PYS_SERVICE_STARTED,
                              (self._svc_name_, ''))
        self.main()

    def main(self):
        # Change to the project directory
        os.chdir(r'{}')
        
        # Start the auto-export service
        process = subprocess.Popen([sys.executable, 'auto_export_tiles.py'])
        
        # Wait for stop signal
        win32event.WaitForSingleObject(self.hWaitStop, win32event.INFINITE)
        
        # Stop the process
        process.terminate()
        process.wait()

if __name__ == '__main__':
    win32serviceutil.HandleCommandLine(AutoExportService)
""".format(os.getcwd())
    
    with open("auto_export_service.py", "w") as f:
        f.write(service_script)
    
    print("✅ Created auto_export_service.py")
    print("To install as Windows service (requires admin):")
    print("  python auto_export_service.py install")
    print("  python auto_export_service.py start")

def create_task_scheduler_script():
    """Create a script for Windows Task Scheduler"""
    
    task_script = """@echo off
REM Dunjon Auto Export Tiles - Task Scheduler Script
REM This script runs the auto-export service

cd /d "{}"
python auto_export_tiles.py
""".format(os.getcwd())
    
    with open("run_auto_export_task.bat", "w") as f:
        f.write(task_script)
    
    print("✅ Created run_auto_export_task.bat")
    print("Add this to Windows Task Scheduler to run at startup")

def create_manual_control_scripts():
    """Create scripts for manual control"""
    
    # Start script
    start_script = """@echo off
echo Starting Dunjon Auto Export Service...
cd /d "{}"
start "Dunjon Auto Export" python auto_export_tiles.py
echo Service started in background window
pause
""".format(os.getcwd())
    
    with open("start_auto_export.bat", "w") as f:
        f.write(start_script)
    
    # Stop script
    stop_script = """@echo off
echo Stopping Dunjon Auto Export Service...
taskkill /f /im python.exe /fi "WINDOWTITLE eq Dunjon Auto Export*"
echo Service stopped
pause
""".format(os.getcwd())
    
    with open("stop_auto_export.bat", "w") as f:
        f.write(stop_script)
    
    print("✅ Created start_auto_export.bat")
    print("✅ Created stop_auto_export.bat")

def main():
    """Setup persistent auto-export service"""
    print("Dunjon Auto Export Setup")
    print("=" * 30)
    print()
    
    # Create all scripts
    create_startup_script()
    create_manual_control_scripts()
    create_task_scheduler_script()
    create_windows_service()
    
    print()
    print("Setup complete! Choose your preferred method:")
    print()
    print("1. MANUAL CONTROL (Recommended for development):")
    print("   - Double-click start_auto_export.bat to start")
    print("   - Double-click stop_auto_export.bat to stop")
    print("   - Service runs until you close the window")
    print()
    print("2. WINDOWS TASK SCHEDULER (Persistent):")
    print("   - Open Task Scheduler")
    print("   - Create Basic Task")
    print("   - Set trigger to 'At startup'")
    print("   - Set action to run run_auto_export_task.bat")
    print("   - Service will start automatically with Windows")
    print()
    print("3. WINDOWS SERVICE (Advanced, requires admin):")
    print("   - Run as administrator:")
    print("     python auto_export_service.py install")
    print("     python auto_export_service.py start")
    print("   - Service runs in background always")
    print()
    print("For development, I recommend option 1 (manual control)")

if __name__ == "__main__":
    main()


