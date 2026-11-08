# Release requirements

This repository is not ready for a public binary release yet. CI builds debug Android and an unsigned iOS simulator app to verify code changes; neither is a distributable production package.

Before a release:

1. Rotate the Xquik credential that appeared in repository history. Keep the replacement on a server-side proxy. Test that the old credential no longer works.
2. Provide HTTPS `XQUIK_API_BASE_URL` and `APP_API_BASE_URL`, then verify all API routes and Firebase authentication in a release build. Confirm the server's TLS certificate and privacy policy.
3. Store Android upload signing files outside Git (`android/upload/key.properties` and its keystore). Verify the app ID, version/build number, signing certificate, and SHA-256 of the exact APK built from the release commit. Compare with Play App Signing's **app signing** certificate before claiming it can update a Play-installed app.
4. Verify iOS bundle ID, provisioning, capabilities, and matching Firebase configuration. Submit through the appropriate App Store Connect or TestFlight account.
5. Smoke-test startup, sign-in, sign-out, saved-post account switching, empty/error states, pagination, links, push notifications, and offline return on real Android and iOS devices.
6. Only after those checks, create a version tag on the validated commit, attach the signed Android APK and checksum if direct download is intended, and publish a GitHub Release. Add verified store and release links to the README and GitHub About.

No signing key, verified store listing, or real-device validation was available during this work. Do not repurpose an old APK or sign a public release with the debug certificate.
