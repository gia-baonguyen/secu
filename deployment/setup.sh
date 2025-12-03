#!/bin/bash

# =============================================
# University Grade Management System
# Complete Setup Script
# System B: Quy trình quản lý điểm trong trường đại học
# =============================================

set -e

echo "================================================"
echo "University Grade Management System Setup"
echo "System B: Grade Management Process in University"
echo "================================================"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    echo ""
    echo "Checking prerequisites..."

    # Check Java
    if command -v java &> /dev/null; then
        JAVA_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}' | cut -d'.' -f1)
        if [ "$JAVA_VERSION" -ge 17 ]; then
            print_status "Java 17+ found"
        else
            print_error "Java 17+ required, found version $JAVA_VERSION"
            exit 1
        fi
    else
        print_error "Java not found. Please install Java 17 or later"
        exit 1
    fi

    # Check Maven
    if command -v mvn &> /dev/null; then
        print_status "Maven found"
    else
        print_error "Maven not found. Please install Maven 3.8+"
        exit 1
    fi

    # Check Node.js
    if command -v node &> /dev/null; then
        NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
        if [ "$NODE_VERSION" -ge 18 ]; then
            print_status "Node.js 18+ found"
        else
            print_error "Node.js 18+ required, found version $NODE_VERSION"
            exit 1
        fi
    else
        print_error "Node.js not found. Please install Node.js 18+"
        exit 1
    fi

    # Check Oracle connection
    print_warning "Oracle Database connection will be verified during database setup"
}

# Setup database
setup_database() {
    echo ""
    echo "Setting up Oracle Database..."

    read -p "Enter Oracle SYS password: " -s ORACLE_SYS_PASSWORD
    echo ""

    read -p "Enter Oracle connection string (e.g., localhost:1521:ORCL): " ORACLE_CONNECTION

    # Create setup SQL script
    cat > /tmp/db_setup.sql << EOF
-- Connect as SYSDBA
CONNECT sys/${ORACLE_SYS_PASSWORD}@${ORACLE_CONNECTION} as sysdba;

-- Run setup scripts
@$(pwd)/database/schema/01_create_tablespaces.sql
@$(pwd)/database/schema/02_create_users.sql

-- Connect as GMS_ADMIN
CONNECT GMS_ADMIN/Admin@2024#Secure@${ORACLE_CONNECTION};

@$(pwd)/database/schema/03_create_tables.sql
@$(pwd)/database/security-policies/01_password_profiles.sql
@$(pwd)/database/security-policies/02_vpd_policies.sql
@$(pwd)/database/security-policies/03_audit_policies.sql
@$(pwd)/database/sample-data/01_insert_sample_data.sql

EXIT;
EOF

    # Execute database setup
    sqlplus /nolog < /tmp/db_setup.sql

    if [ $? -eq 0 ]; then
        print_status "Database setup completed successfully"
    else
        print_error "Database setup failed"
        exit 1
    fi

    # Clean up
    rm /tmp/db_setup.sql
}

# Setup backend
setup_backend() {
    echo ""
    echo "Setting up Spring Boot backend..."

    cd backend

    # Update application.properties with connection details
    read -p "Update database connection in application.properties? (y/n): " UPDATE_CONFIG

    if [ "$UPDATE_CONFIG" == "y" ]; then
        read -p "Enter database URL (default: jdbc:oracle:thin:@localhost:1521:ORCL): " DB_URL
        DB_URL=${DB_URL:-jdbc:oracle:thin:@localhost:1521:ORCL}

        # Update application.properties
        sed -i "s|spring.datasource.url=.*|spring.datasource.url=${DB_URL}|" src/main/resources/application.properties
        print_status "Updated database configuration"
    fi

    # Build backend
    print_status "Building backend application..."
    mvn clean install -DskipTests

    if [ $? -eq 0 ]; then
        print_status "Backend build completed successfully"
    else
        print_error "Backend build failed"
        exit 1
    fi

    cd ..
}

# Setup frontend
setup_frontend() {
    echo ""
    echo "Setting up React frontend..."

    cd frontend

    # Install dependencies
    print_status "Installing frontend dependencies..."
    npm install

    if [ $? -eq 0 ]; then
        print_status "Frontend dependencies installed successfully"
    else
        print_error "Frontend dependency installation failed"
        exit 1
    fi

    # Build frontend
    print_status "Building frontend application..."
    npm run build

    if [ $? -eq 0 ]; then
        print_status "Frontend build completed successfully"
    else
        print_error "Frontend build failed"
        exit 1
    fi

    cd ..
}

# Start services
start_services() {
    echo ""
    echo "Starting services..."

    # Start backend
    print_status "Starting backend service..."
    cd backend
    nohup java -jar target/grade-management-system-1.0.0.jar > ../logs/backend.log 2>&1 &
    BACKEND_PID=$!
    echo $BACKEND_PID > ../backend.pid
    cd ..

    # Wait for backend to start
    sleep 10

    # Check if backend is running
    if curl -s http://localhost:8080/api/actuator/health > /dev/null; then
        print_status "Backend service started successfully (PID: $BACKEND_PID)"
    else
        print_error "Backend service failed to start"
        exit 1
    fi

    # Start frontend (development mode)
    print_status "Starting frontend service..."
    cd frontend
    nohup npm start > ../logs/frontend.log 2>&1 &
    FRONTEND_PID=$!
    echo $FRONTEND_PID > ../frontend.pid
    cd ..

    print_status "Frontend service started (PID: $FRONTEND_PID)"
}

# Main setup flow
main() {
    echo ""
    echo "This script will set up the complete Grade Management System"
    echo "============================================================"

    # Create logs directory
    mkdir -p logs

    # Check prerequisites
    check_prerequisites

    # Ask user what to setup
    echo ""
    echo "Select setup options:"
    echo "1. Complete setup (Database + Backend + Frontend)"
    echo "2. Database only"
    echo "3. Backend only"
    echo "4. Frontend only"
    echo "5. Start services only"
    read -p "Enter your choice (1-5): " SETUP_CHOICE

    case $SETUP_CHOICE in
        1)
            setup_database
            setup_backend
            setup_frontend
            start_services
            ;;
        2)
            setup_database
            ;;
        3)
            setup_backend
            ;;
        4)
            setup_frontend
            ;;
        5)
            start_services
            ;;
        *)
            print_error "Invalid choice"
            exit 1
            ;;
    esac

    echo ""
    echo "================================================"
    print_status "Setup completed successfully!"
    echo ""
    echo "Access the application:"
    echo "- Frontend: http://localhost:3000"
    echo "- Backend API: http://localhost:8080/api"
    echo "- API Documentation: http://localhost:8080/api/swagger-ui.html"
    echo ""
    echo "Test Accounts:"
    echo "- Student: sv001 / Student@2024"
    echo "- Lecturer: lecturer001 / Lecturer@2024"
    echo "- Academic Affairs: academic001 / Academic@2024"
    echo "================================================"
}

# Stop services
stop_services() {
    echo "Stopping services..."

    if [ -f backend.pid ]; then
        kill $(cat backend.pid) 2>/dev/null || true
        rm backend.pid
        print_status "Backend service stopped"
    fi

    if [ -f frontend.pid ]; then
        kill $(cat frontend.pid) 2>/dev/null || true
        rm frontend.pid
        print_status "Frontend service stopped"
    fi
}

# Handle script arguments
if [ "$1" == "stop" ]; then
    stop_services
elif [ "$1" == "restart" ]; then
    stop_services
    start_services
else
    main
fi