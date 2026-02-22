# E-Tiket - Pelayanan Terpadu

<div align="center">

![E-Tiket Logo](assets/images/logo.png)

**Sistem Pelayanan Terpadu**

A professional queue management system designed for Indonesian government institutions.

[Version](https://github.com/yourusername/sistem_antrean_satker/releases/latest) | [Issues](https://github.com/yourusername/sistem_antrean_satker/issues) | [Contributing](#contributing)

</div>

---

## Table of Contents

- [About](#about)
- [Features](#features)
- [Screenshots](#screenshots)
- [Installation](#installation)
- [Usage](#usage)
- [Technology Stack](#technology-stack)
- [Project Structure](#project-process)
- [Development](#development)
- [Build Instructions](#build-instructions)
- [Version History](#version-history)
- [License](#license)

---

## About

**E-Tiket** (Pelayanan Terpadu) is a desktop-based queue management system specifically designed for Indonesian government institutions (Satuan Kerja). The application manages document submission and retrieval workflows with professional receipt generation and comprehensive data tracking.

### Key Workflow

The system manages two main processes:

1. **MASUK (IN)** - Document drop-off process where visitors submit their documents
2. **KELUAR (OUT)** - Document pickup process where authorized personnel retrieve completed documents

### Target Users

- Secretariat departments (Sekretariat)
- Education centers (Pusduk)
- Intelligence agencies (Pusintelhan)
- Information centers (Pusiber)
- Other government institutions requiring document queue management

---

## Features

### Core Features

#### Document Submission (MASUK)
- **Visitor Registration**: Record visitor names with "Keep Name" option for frequent visitors
- **Department Selection**: Support for multiple institutional departments
- **FD Number Management**: Automatic/manual assignment with uniqueness validation
- **Document Tracking**: Track title, nominal value, and SPM (Surat Perintah Mengambil) numbers
- **Duration Setting**: Configure document retention period (1-5 days)
- **PDF Receipt Generation**: Professional receipts with Indonesian formatting

#### Document Retrieval (KELUAR)
- **Search Functionality**: Quick document lookup by FD number
- **Verification System**: Department and personnel verification
- **Pickup Registration**: Record pickup person details
- **Status Tracking**: Automatic status transition from IN to OUT
- **Reprint Support**: Generate duplicate receipts when needed

#### Data Management
- **SQLite Database**: Robust local data storage with FFI support
- **Historical Records**: Complete transaction history with date filtering
- **Daily Summaries**: View all transactions by date
- **Backup & Restore**: Full data export and import capabilities
- **Data Reset**: Clean database reset option

#### User Interface
- **Responsive Design**: Adapts to desktop and tablet screens
- **Theme Support**: Light and dark mode with professional styling
- **Indonesian Language**: Full localization with proper date/time formatting
- **Material Design 3**: Modern, intuitive interface
- **Tab-Based Navigation**: Easy switching between IN, OUT, and History

#### Print Integration
- **System Printer Support**: Automatic printer detection
- **Professional Layout**: 72mm × 200mm receipt format
- **Branded Receipts**: Institutional logo and formatting
- **Named Print Jobs**: Organized print queue with timestamps

---

## Screenshots

### Main Interface
- **MASUK Tab**: Document submission form with all required fields
- **KELUAR Tab**: Document retrieval with search and verification
- **History Tab**: Transaction history with date filtering

### Features
- Automatic FD number assignment
- Thousands separator for nominal values
- Receipt preview before printing
- Department-based organization

---

## Installation

### Prerequisites

- **Operating System**: Windows 10+ or Linux (Ubuntu 18.04+)
- **Memory**: Minimum 4GB RAM
- **Storage**: 100MB free space
- **Printer**: Thermal or inkjet printer for receipts (optional)

### Windows Installation

1. Download the latest `.exe` installer from [Releases](https://github.com/yourusername/sistem_antrean_satker/releases)
2. Run the installer as Administrator
3. Follow the installation wizard
4. Launch E-Tiket from the desktop shortcut

### Linux Installation

1. Download the latest `.deb` package from [Releases](https://github.com/yourusername/sistem_antrean_satker/releases)
2. Install using package manager:
   ```bash
   sudo dpkg -i etiket_<version>_amd64.deb
   sudo apt-get install -f  # Fix dependencies if needed
   ```
3. Launch E-Tiket from application menu

---

## Usage

### Quick Start Guide

#### 1. Submit Document (MASUK)

1. Open the application and navigate to **MASUK** tab
2. Enter visitor information (or use saved name)
3. Select department from dropdown
4. Fill document details (title, nominal, SPM number if applicable)
5. Set duration for document processing
6. Click **"Simpan"** to save and generate receipt
7. Print receipt for visitor

#### 2. Retrieve Document (KELUAR)

1. Navigate to **KELUAR** tab
2. Enter FD number or search by visitor name
3. Verify document details
4. Enter pickup person information
5. Confirm department
6. Click **"Proses KELUAR"** to complete retrieval
7. Print retrieval receipt

#### 3. View History

1. Navigate to **History** tab
2. Filter by date using date picker
3. View all transactions for selected date
4. Export data if needed

#### 4. Data Management

1. Access from settings menu
2. Choose:
   - **Backup**: Export database to file
   - **Restore**: Import from backup
   - **Reset**: Clear all data (use with caution)

---

## Technology Stack

### Frontend Framework
- **Flutter**: ^3.11.0 - Cross-platform UI framework
- **Dart**: Programming language

### State Management
- **Provider**: ^6.1.2 - State management solution

### Database
- **SQLite**: Local data storage
- **sqflite_common_ffi**: ^2.3.4+4 - Desktop SQLite support via FFI

### PDF & Printing
- **PDF**: ^3.11.2 - PDF generation
- **Printing**: ^5.13.4 - Print integration

### Localization
- **Intl**: ^0.20.2 - Internationalization and date formatting

### UI Components
- **Google Fonts**: ^6.2.1 - Poppins font family
- **Material Design 3**: Modern UI components

### File Handling
- **File Picker**: ^8.1.7 - File selection dialogs
- **Path Provider**: ^2.1.5 - File system paths

---

## Project Structure

```
lib/
├── main.dart                      # Application entry point
├── core/                          # Core utilities and configurations
│   ├── app_constants.dart        # Constants and enums (SubSatker, duration)
│   ├── app_theme.dart            # Theme configurations (light/dark)
│   └── database_helper.dart      # SQLite operations and migrations
├── models/                        # Data models
│   └── antrian_model.dart        # Queue record model
├── providers/                     # State management
│   └── antrian_provider.dart     # Main state provider for queue operations
├── pages/                         # Application pages
│   ├── splash_screen.dart        # Welcome/loading screen
│   └── history_page.dart         # Transaction history with filtering
└── widgets/                       # Reusable UI components
    ├── header_bar.dart           # Top navigation bar with tabs
    ├── input_form_section.dart   # IN process form (MASUK)
    ├── out_form_section.dart     # OUT process form (KELUAR)
    ├── preview_struk.dart        # Receipt preview dialog
    └── receipt_widget.dart       # Receipt display widget

assets/
├── images/                        # Image assets
│   └── siasat_logo.png           # Application logo
└── database/                      # Database reference files
```

### Architecture Pattern

- **Provider Pattern**: State management with ChangeNotifier
- **MVC Pattern**: Separation of Models, Views (widgets), and Controllers (providers)
- **Desktop-First**: Optimized for Windows and Linux environments
- **Responsive UI**: LayoutBuilder for adaptive layouts

---

## Development

### Environment Setup

1. **Install Flutter SDK** (3.11.0 or later)
   ```bash
   # Clone Flutter repository
   git clone https://github.com/flutter/flutter.git -b stable

   # Add to PATH
   export PATH="$PATH:/path/to/flutter/bin"
   ```

2. **Verify Installation**
   ```bash
   flutter doctor
   ```

3. **Enable Desktop Support**
   ```bash
   flutter config --enable-linux-desktop
   flutter config --enable-windows-desktop
   ```

4. **Install Platform Dependencies**

   **Linux (Ubuntu/Debian)**:
   ```bash
   sudo apt-get update
   sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev
   ```

   **Windows**:
   - Install Visual Studio 2019 or later with C++ desktop development tools

### Clone Repository

```bash
git clone https://github.com/yourusername/sistem_antrean_satker.git
cd sistem_antrean_satker
```

### Install Dependencies

```bash
flutter pub get
```

### Run Development Build

```bash
# Linux
flutter run -d linux

# Windows
flutter run -d windows
```

---

## Build Instructions

### Windows Build

```bash
# Build executable
flutter build windows --release

# Output: build/windows/runner/Release/
# Create installer using Inno Setup or similar tool
```

### Linux Build

```bash
# Build executable
flutter build linux --release

# Create .deb package
flutter pub run psyomics/msix:build deb \
  --build-files \
  --output build/linux/x64/release/

# Alternative: Using standard packaging
cd build/linux/x64/release/
tar czvf siasat-linux-x64.tar.gz *
```

### Release Checklist

- [ ] Update version in `pubspec.yaml`
- [ ] Update CHANGELOG.md
- [ ] Test on target platforms
- [ ] Create git tag
- [ ] Build release packages
- [ ] Upload to GitHub Releases

---

## Version History

### Version 2.0.0 (Current)
- Added "Keep Name" option for frequent visitors
- Implemented thousands separator for nominal values
- Updated receipt titles and formatting
- Enhanced FD number management with uniqueness checks
- Improved OUT process with reprint functionality
- Database schema upgrade to v3

### Version 1.0.7
- Introduced "SIASAT" branding with new logo
- Updated app titles and installer configurations
- Refined Linux packaging script

### Version 1.0.6
- Initial stable release
- Basic IN and OUT workflow
- PDF receipt generation
- SQLite database integration
- Print functionality

See [CHANGELOG.md](CHANGELOG.md) for complete version history.

---

## Contributing

We welcome contributions! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Development Guidelines

- Follow Flutter [effective dart](https://dart.dev/guides/language/effective-dart) guidelines
- Write clean, documented code
- Test on both Windows and Linux
- Update documentation for new features

---

## Troubleshooting

### Common Issues

**Printer not detected**
- Ensure printer drivers are installed
- Check printer is powered on and connected
- Test with system print dialog first

**Database errors**
- Check write permissions in application directory
- Ensure sufficient disk space
- Try database reset if corrupted

**Build failures**
- Run `flutter clean && flutter pub get`
- Verify all dependencies are installed
- Check Flutter version compatibility

---

## License

This project is proprietary software for government institution use.

Copyright © 2024-2025 Satuan Kerja. All rights reserved.

---

## Support

For issues, questions, or suggestions:
- Open an issue on GitHub
- Contact development team
- Check documentation

---

**Built with ❤️ for Indonesian Government Institutions**
