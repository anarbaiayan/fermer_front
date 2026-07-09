# Fermer+ Frontend Overview

## Product
Fermer+ is a Flutter mobile app for cattle and farm operations management.

## Main User Tasks
- authenticate and manage account
- manage herd and animal cards
- create and complete cattle events
- track lactation and milk data
- manage feed stock and rations
- view notifications and navigate to relevant animals
- use localized UI in Russian or Kazakh

## Tech Stack
- Flutter / Dart
- Riverpod / hooks_riverpod
- GoRouter
- Dio
- Flutter Secure Storage
- SharedPreferences
- ARB localization

## Feature Modules
- `auth`
- `herd`
- `cattle_events`
- `lactation`
- `rations`
- `notifications`
- `profile`
- `settings`
- `home`
- `splash`

## Backend Integration
- Base API URL in current code: `https://fer-mer-plus.ru/api`
- Local backend repository is stored alongside the mobile app in sibling folder `../fp-backend`.
- Networking uses Dio with auth interceptor and token refresh flow.
- DTOs and API datasources are feature-scoped.

## Current Product Languages
- Russian (`ru`)
- Kazakh (`kk`)

## Release Notes
- Android package id: `kz.fermerplus.app`
- Play release uses signed `.aab`
- Release behavior must be checked separately from debug
