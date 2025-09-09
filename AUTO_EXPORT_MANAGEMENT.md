# Auto-Export Service Management

## Current Status
The auto-export service is currently running in your terminal, but it will stop when you close Cursor or the terminal.

## Solutions for Persistence

### 🎯 **Option 1: Manual Control (Recommended)**
**Best for development work**

**To Start:**
- Double-click `start_auto_export.bat`
- Service runs in a separate window
- Close the window to stop the service

**To Stop:**
- Double-click `stop_auto_export.bat`
- Or close the service window

**Pros:**
- ✅ Easy to start/stop
- ✅ See what's happening
- ✅ No admin rights needed
- ✅ Perfect for development

**Cons:**
- ❌ Need to remember to start it
- ❌ Stops when you close the window

### 🔄 **Option 2: Windows Task Scheduler (Persistent)**
**Best for "set it and forget it"**

**Setup:**
1. Open **Task Scheduler** (search in Start menu)
2. Click **"Create Basic Task"**
3. Name: "Dunjon Auto Export"
4. Trigger: **"When the computer starts"**
5. Action: **"Start a program"**
6. Program: Browse to `run_auto_export_task.bat`
7. Click **Finish**

**Pros:**
- ✅ Starts automatically with Windows
- ✅ Runs in background
- ✅ No need to remember to start it

**Cons:**
- ❌ Always running (uses some resources)
- ❌ Harder to see what's happening

### ⚙️ **Option 3: Windows Service (Advanced)**
**Best for production use**

**Setup (requires admin):**
```cmd
# Run as Administrator
python auto_export_service.py install
python auto_export_service.py start
```

**To stop:**
```cmd
python auto_export_service.py stop
python auto_export_service.py remove
```

**Pros:**
- ✅ True Windows service
- ✅ Starts with Windows
- ✅ Runs in background
- ✅ Professional setup

**Cons:**
- ❌ Requires admin rights
- ❌ More complex to manage
- ❌ Harder to debug

## My Recommendation

**For your development workflow, I recommend Option 1 (Manual Control):**

1. **When you start working on rooms:**
   - Double-click `start_auto_export.bat`
   - Keep the window open while working

2. **When you're done:**
   - Close the service window
   - Or double-click `stop_auto_export.bat`

3. **If you forget to start it:**
   - Just double-click `start_auto_export.bat`
   - The service will start monitoring

## Quick Commands

```bash
# Start service (manual)
start_auto_export.bat

# Stop service (manual)
stop_auto_export.bat

# Check if running
tasklist | findstr python
```

## What Happens When You Close Cursor

- **Current terminal service**: Stops
- **Manual service**: Keeps running (if you started it separately)
- **Task Scheduler service**: Keeps running
- **Windows Service**: Keeps running

## Best Practice

1. **Start the service** when you begin working on rooms
2. **Keep it running** while you edit in Tiled
3. **Stop it** when you're done (to save resources)
4. **Restart it** next time you work on rooms

This gives you full control and visibility while keeping it simple!


