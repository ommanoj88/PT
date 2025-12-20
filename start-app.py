#!/usr/bin/env python3
"""
VibeCheck - Universal Application Starter
Cross-platform Python script to start the entire application
"""

import os
import sys
import subprocess
import time
import platform
import signal
import shutil
from pathlib import Path
from urllib.request import urlopen
from urllib.error import URLError

# ANSI color codes for colored output
class Colors:
    CYAN = '\033[96m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    GRAY = '\033[90m'
    WHITE = '\033[97m'
    RESET = '\033[0m'
    BOLD = '\033[1m'

def print_colored(message, color=Colors.WHITE):
    """Print colored message"""
    print(f"{color}{message}{Colors.RESET}")

def print_step(step, total, message):
    """Print step progress"""
    print_colored(f"\n[{step}/{total}] {message}", Colors.YELLOW)

def print_success(message):
    """Print success message"""
    print_colored(f"✓ {message}", Colors.GREEN)

def print_error(message):
    """Print error message"""
    print_colored(f"ERROR: {message}", Colors.RED)

def print_warning(message):
    """Print warning message"""
    print_colored(f"WARNING: {message}", Colors.YELLOW)

def check_command_exists(command):
    """Check if a command exists in PATH"""
    return shutil.which(command) is not None

def is_docker_running():
    """Check if Docker is running"""
    try:
        result = subprocess.run(['docker', 'ps'], 
                              stdout=subprocess.PIPE, 
                              stderr=subprocess.PIPE,
                              check=False)
        return result.returncode == 0
    except FileNotFoundError:
        return False

def start_docker_containers():
    """Start Docker containers using docker-compose"""
    print_step(2, 5, "Starting Database Containers...")
    
    try:
        # Start containers in detached mode
        subprocess.run(['docker-compose', 'up', '-d'], check=True)
        time.sleep(5)
        print_success("Database containers started")
        return True
    except subprocess.CalledProcessError as e:
        print_error(f"Failed to start Docker containers: {e}")
        return False

def initialize_database(script_dir):
    """Initialize the database with init-db.sql"""
    print_step(3, 5, "Initializing Database...")
    
    init_sql_path = script_dir / 'backend' / 'init-db.sql'
    
    if not init_sql_path.exists():
        print_warning("init-db.sql not found, skipping database initialization")
        return True
    
    try:
        # Read the SQL file and pipe it to docker exec
        with open(init_sql_path, 'r', encoding='utf-8') as f:
            sql_content = f.read()
        
        process = subprocess.Popen(
            ['docker', 'exec', '-i', 'vibecheck-postgres', 
             'psql', '-U', 'vibecheck', '-d', 'vibecheck'],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        )
        
        stdout, stderr = process.communicate(input=sql_content.encode('utf-8'))
        
        if process.returncode == 0:
            print_success("Database initialized")
            return True
        else:
            print_warning(f"Database initialization had warnings: {stderr.decode()}")
            return True  # Continue even with warnings
            
    except Exception as e:
        print_error(f"Failed to initialize database: {e}")
        return False

def check_backend_health(max_retries=5):
    """Check if backend is responding"""
    backend_url = 'http://localhost:3000/api/health'
    
    for i in range(1, max_retries + 1):
        try:
            response = urlopen(backend_url, timeout=5)
            if response.status == 200:
                return True
        except URLError:
            print_colored(f"  Waiting for backend... ({i}/{max_retries})", Colors.GRAY)
            time.sleep(2)
    
    return False

def start_backend(script_dir):
    """Start the backend server"""
    print_step(4, 5, "Starting Backend Server...")
    
    backend_dir = script_dir / 'backend'
    
    if not backend_dir.exists():
        print_error("Backend directory not found")
        return None
    
    # Determine the shell command based on OS
    system = platform.system()
    
    try:
        if system == 'Windows':
            # Windows: start in new PowerShell window
            process = subprocess.Popen(
                ['powershell', '-NoExit', '-Command', 
                 f"cd '{backend_dir}'; Write-Host 'Starting Backend...' -ForegroundColor Cyan; npm run dev"],
                creationflags=subprocess.CREATE_NEW_CONSOLE
            )
        else:
            # Linux/Mac: start in background
            process = subprocess.Popen(
                ['npm', 'run', 'dev'],
                cwd=backend_dir,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE
            )
        
        time.sleep(8)
        
        # Check if backend is healthy
        if check_backend_health():
            print_success("Backend is running on http://localhost:3000")
        else:
            print_warning("Backend might not be fully ready")
        
        return process
        
    except Exception as e:
        print_error(f"Failed to start backend: {e}")
        return None

def start_frontend(script_dir):
    """Start the Flutter frontend"""
    print_step(5, 5, "Starting Frontend (Flutter Web)...")
    
    frontend_dir = script_dir / 'frontend'
    
    if not frontend_dir.exists():
        print_error("Frontend directory not found")
        return None
    
    # Check if Flutter is installed
    if not check_command_exists('flutter'):
        print_warning("Flutter is not installed. Skipping frontend.")
        print_colored("To run the frontend later, install Flutter from:", Colors.CYAN)
        print_colored("https://flutter.dev/docs/get-started/install", Colors.CYAN)
        print_colored("\nYou can still use the backend API at http://localhost:3000", Colors.GREEN)
        return None
    
    # Determine the shell command based on OS
    system = platform.system()
    
    try:
        if system == 'Windows':
            # Windows: start in new PowerShell window
            process = subprocess.Popen(
                ['powershell', '-NoExit', '-Command',
                 f"cd '{frontend_dir}'; Write-Host 'Starting Flutter App...' -ForegroundColor Cyan; flutter run -d chrome"],
                creationflags=subprocess.CREATE_NEW_CONSOLE
            )
        else:
            # Linux/Mac: start in background
            process = subprocess.Popen(
                ['flutter', 'run', '-d', 'chrome'],
                cwd=frontend_dir,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE
            )
        
        print_success("Frontend is starting in Chrome...")
        return process
        
    except Exception as e:
        print_error(f"Failed to start frontend: {e}")
        return None

def cleanup(processes):
    """Cleanup processes on exit"""
    print_colored("\n\nStopping application...", Colors.YELLOW)
    
    for process in processes:
        if process and process.poll() is None:
            try:
                process.terminate()
                process.wait(timeout=5)
            except:
                try:
                    process.kill()
                except:
                    pass
    
    print_colored("Application stopped.", Colors.GREEN)

def main():
    """Main application startup function"""
    print_colored("=== Starting VibeCheck App ===", Colors.CYAN + Colors.BOLD)
    
    # Get the script directory
    script_dir = Path(__file__).parent.resolve()
    os.chdir(script_dir)
    
    processes = []
    
    # Step 1: Check Docker
    print_step(1, 5, "Checking Docker...")
    if not is_docker_running():
        print_error("Docker is not running. Please start Docker Desktop first.")
        sys.exit(1)
    print_success("Docker is running")
    
    # Step 2: Start Docker containers
    if not start_docker_containers():
        sys.exit(1)
    
    # Step 3: Initialize database
    if not initialize_database(script_dir):
        print_warning("Continuing without database initialization...")
    
    # Step 4: Start backend
    backend_process = start_backend(script_dir)
    if backend_process:
        processes.append(backend_process)
    
    # Step 5: Start frontend
    frontend_process = start_frontend(script_dir)
    if frontend_process:
        processes.append(frontend_process)
    
    # Print summary
    print_colored("\n=== VibeCheck is Running! ===", Colors.CYAN + Colors.BOLD)
    print_colored("Backend:  http://localhost:3000", Colors.WHITE)
    
    if frontend_process:
        print_colored("Frontend: Opening in Chrome...", Colors.WHITE)
    else:
        print_colored("Frontend: Not started (Flutter not installed)", Colors.YELLOW)
        print_colored("\nAPI Testing:", Colors.WHITE)
        print_colored("  You can test the API with Postman or curl", Colors.GRAY)
        print_colored("  Example: curl http://localhost:3000/api/health", Colors.GRAY)
    
    print_colored("\nPress Ctrl+C to stop all services.", Colors.GRAY)
    
    # Handle Ctrl+C gracefully
    def signal_handler(sig, frame):
        cleanup(processes)
        sys.exit(0)
    
    signal.signal(signal.SIGINT, signal_handler)
    
    # Keep the script running
    try:
        if platform.system() == 'Windows':
            print_colored("\nClose the backend/frontend windows or press Ctrl+C here to stop.", Colors.GRAY)
            # On Windows, the processes run in separate windows
            while True:
                time.sleep(1)
        else:
            # On Linux/Mac, wait for processes
            for process in processes:
                if process:
                    process.wait()
    except KeyboardInterrupt:
        cleanup(processes)
        sys.exit(0)

if __name__ == '__main__':
    main()
