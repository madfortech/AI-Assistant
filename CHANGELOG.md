# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [1.1.0] - 2026-07-18
### Added
- API key authentication (Bearer Token) for all requests
- Settings dialog (gear icon) to configure Unique Key and API URL
- user credits and subscription plan system — fetches info from `/api/me` endpoint
- Live status bar showing name, plan, and remaining credits

### Changed
- Improved error messages with actual HTTP status codes
- Dynamic welcome message

### Removed
- Debug print statements

### Notes
- Existing users need to set their Unique Key in Settings before using the plugin

## [1.0.0] - 2026-07-11
### Added
- AI-powered assistant for the Godot Editor
- Ask Godot-related questions directly inside the editor
- Secure backend API integration
- Simple conversation interface
- Send and clear chat functionality
- Production-ready HTTP communication
- Compatible with Godot 4.7 Stable