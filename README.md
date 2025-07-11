# Access Control App

A Rails application for managing organization memberships with age verification, parental consent, and role-based access control.

## Features

- **User Authentication**: Secure login/logout system
- **Organization Management**: Create and manage organizations
- **Membership System**: Invite and manage organization members
- **Age Verification**: Age-based access control with parental consent
- **Role-Based Permissions**: Flexible permission system
- **Analytics Dashboard**: Organization insights and reporting
- **Email Notifications**: Automated invitation and notification system

## Prerequisites

Before you begin, ensure you have the following installed:

- **Ruby**: Version 3.1+ (check with `ruby -v`)
- **Rails**: Version 7+ (check with `rails -v`)
- **PostgreSQL**: Version 12+ (check with `psql --version`)
- **Node.js**: Version 16+ (check with `node -v`)
- **Yarn**: Latest version (check with `yarn -v`)
- **Docker**: Optional, for containerized deployment

## Setup

### 1. Clone the Repository

```bash
git clone <repository-url>
cd access_control_app
```

### 2. Install Dependencies

```bash
# Install Ruby gems
bundle install

# Install JavaScript dependencies
yarn install
```

### 3. Database Setup

```bash
# Create and setup the database
rails db:create
rails db:migrate

# Seed the database with initial data (optional)
rails db:seed
```

### 4. Environment Configuration

Create a `.env` file in the root directory (or use Rails credentials):

```bash
# Database
DATABASE_URL=postgresql://username:password@localhost/access_control_app_development

# Email configuration (for invitations)
SMTP_ADDRESS=smtp.gmail.com
SMTP_PORT=587
SMTP_DOMAIN=yourdomain.com
SMTP_USER_NAME=your_email@gmail.com
SMTP_PASSWORD=your_app_password
SMTP_AUTHENTICATION=plain
SMTP_ENABLE_STARTTLS_AUTO=true

# Application host
HOST=localhost:3000
```

### 5. Asset Compilation

```bash
# Precompile assets for production
rails assets:precompile

# Or for development with live reloading
bin/dev
```

## Running the Application

### Development Mode

```bash
# Start the Rails server
rails server

# Or use the dev script for full development environment
bin/dev
```

The application will be available at `http://localhost:3000`
