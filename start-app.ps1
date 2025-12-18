# VibeCheck - Complete Startup Script
# Run this to start everything

Write-Host "=== Starting VibeCheck App ===" -ForegroundColor Cyan

# 1. Check Docker
Write-Host "`n[1/5] Checking Docker..." -ForegroundColor Yellow
$dockerRunning = docker ps 2>$null
if (!$?) {
    Write-Host "ERROR: Docker is not running. Please start Docker Desktop first." -ForegroundColor Red
    exit 1
}
Write-Host "✓ Docker is running" -ForegroundColor Green

# 2. Start Database Containers
Write-Host "`n[2/5] Starting Database Containers..." -ForegroundColor Yellow
docker-compose up -d
Start-Sleep -Seconds 5
Write-Host "✓ Database containers started" -ForegroundColor Green

# 3. Initialize Database
Write-Host "`n[3/5] Initializing Database..." -ForegroundColor Yellow
Get-Content backend\init-db.sql | docker exec -i vibecheck-postgres psql -U vibecheck -d vibecheck 2>$null
Write-Host "✓ Database initialized" -ForegroundColor Green

# 4. Start Backend
Write-Host "`n[4/5] Starting Backend Server..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD\backend'; Write-Host 'Starting Backend...' -ForegroundColor Cyan; npm run dev"
Start-Sleep -Seconds 8

# Test backend
$backendHealthy = $false
for ($i = 1; $i -le 5; $i++) {
    try {
        $response = Invoke-WebRequest -Uri http://localhost:3000/api/health -UseBasicParsing -ErrorAction Stop
        if ($response.StatusCode -eq 200) {
            $backendHealthy = $true
            break
        }
    }
    catch {
        Write-Host "  Waiting for backend... ($i/5)" -ForegroundColor Gray
        Start-Sleep -Seconds 2
    }
}

if ($backendHealthy) {
    Write-Host "✓ Backend is running on http://localhost:3000" -ForegroundColor Green
}
else {
    Write-Host "WARNING: Backend might not be fully ready" -ForegroundColor Yellow
}

# 5. Start Frontend
Write-Host "`n[5/5] Starting Frontend (Flutter Web)..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD\frontend'; Write-Host 'Starting Flutter App...' -ForegroundColor Cyan; flutter run -d chrome"

Write-Host "`n=== VibeCheck is Starting! ===" -ForegroundColor Cyan
Write-Host "Backend:  http://localhost:3000" -ForegroundColor White
Write-Host "Frontend: Opening in Chrome..." -ForegroundColor White
Write-Host "`nPress Ctrl+C in the backend/frontend windows to stop them." -ForegroundColor Gray
