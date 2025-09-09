import win32serviceutil
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
        os.chdir(r'C:\Users\koiko\Projects\dunjon')
        
        # Start the auto-export service
        process = subprocess.Popen([sys.executable, 'auto_export_tiles.py'])
        
        # Wait for stop signal
        win32event.WaitForSingleObject(self.hWaitStop, win32event.INFINITE)
        
        # Stop the process
        process.terminate()
        process.wait()

if __name__ == '__main__':
    win32serviceutil.HandleCommandLine(AutoExportService)
