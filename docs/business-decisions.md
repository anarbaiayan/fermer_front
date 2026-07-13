# Business Decisions and Product Semantics

## Auth
- Drawer logout and profile account deletion are different actions.
- Deleted account can be restored from the login area using phone + password.

## Rations
- Opening rations from a cattle card is not the same as opening the general rations section.
- From cattle context, the app requests one ration for the selected animal.
- From standalone ration screen, the app shows all user rations.
- If the user has no available feeds, the app must show an empty state with a path to add feed stock.

## Feed Catalog / User Stock
- Feed names may come from backend in two languages (`name`, `nameKk`).
- Custom user feed can be created by the user and stored through backend API.

## Notifications
- Notifications are paginated.
- Unread state is based on `readAt == null`, not only status.
- Archive and read are separate backend actions.
- If a notification references cattle, tapping it should navigate to the cattle card.

## Cattle Events
- Event type semantics are centralized in `cattle_event_type.dart`.
- System event types are parsed but not presented the same way as manual business events.

## Support
- Support route uses WhatsApp deep linking.

## App Navigation
- The bottom navigation is fixed to Home, Herd, Events, Lactation, and More.
- More is the central directory for all modules, including shortcuts to the bottom-nav destinations.
- Farm management entries in More include rations, feed stock, pharmacy, and pharmacy requests.
- Account/support entries in More include profile, settings, notifications, and support.
- Pharmacy must be available from More but not from the sidebar drawer.

## Localization
- UI strings must exist in Russian and Kazakh.
- Backend translations should be used where available instead of duplicating text in frontend.
