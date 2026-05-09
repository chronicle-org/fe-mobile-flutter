---
name: Implement Notifications Feature
about: Add notification system to mobile app to match web functionality
title: Implement Notifications Feature for Mobile App
labels: feature
assignees: ''
---

## Description
The mobile app currently has a placeholder for notifications ("Coming Soon"), while the web app (fe-next) has a fully implemented notification system. This issue tracks implementing feature parity for notifications on the mobile app.

## Current State
- **Web (fe-next)**: ✅ Full notification system with real-time WebSocket support
- **Mobile (fe-mobile-flutter)**: ❌ Placeholder only (shows "Coming Soon")

## Requirements
Implement the following notification features on mobile:

### 1. Real-Time Notifications
- [ ] WebSocket integration for real-time notification receiving
- [ ] Connection management and reconnection logic
- [ ] Token verification for WebSocket authentication

### 2. Notification Center
- [ ] Display list of notifications with infinite scroll
- [ ] Show notification types: Comments, Likes, Follows, Bookmarks, Replies, Posts from followed users
- [ ] Mark notifications as read
- [ ] Delete individual notifications
- [ ] Visual indicators for unread notifications

### 3. Notification Settings
- [ ] Settings page for notification preferences
- [ ] Toggle options for each notification type:
  - Notify me about comments
  - Notify me about likes
  - Notify me about follows
  - Notify me about bookmarks
  - Notify me about replies
  - Notify me about new posts from followed users
- [ ] API integration for fetching and updating notification settings

### 4. UI/UX
- [ ] Notification bell icon in navigation with unread count badge
- [ ] Notification detail view with action capabilities
- [ ] Toast/snack bar for immediate notification feedback
- [ ] Empty state when no notifications exist

## Reference
- **Web implementation**: `fe-next` repo
  - API: `src/lib/api/notification.ts`
  - Settings UI: `src/app/setting/page.tsx`
  - Navigation component: `src/components/ui/Navigation.tsx`
  - Store: `src/lib/stores/notification.store.ts`
  - WebSocket setup: `src/socket.ts`

## Acceptance Criteria
- [ ] Notifications appear in real-time via WebSocket
- [ ] User can view their notification history
- [ ] User can manage notification preferences
- [ ] Feature has parity with web implementation
- [ ] Mobile app navigation includes notifications tab (not placeholder)
- [ ] Unread notification count displays in UI

## Dependencies
- Backend notification API endpoints (from be-nest)
- WebSocket support in Flutter
