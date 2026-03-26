# Apple Sign-In Setup Guide for TravelConnect

This guide walks you through configuring Apple Sign-In for the TravelConnect app. The app code is already in place — you only need to obtain credentials from the Apple Developer Portal and add them to your `.env` file.

---

## Prerequisites

- **Apple Developer Account** — Requires enrollment in the [Apple Developer Program](https://developer.apple.com/programs/) ($99/year).
- **App already registered** — You should have a Bundle ID for your app (e.g., `com.travelconnect.app`).
- **Laravel backend deployed** — You need a public URL for the callback (e.g., `https://your-domain.com`).

---

## Step 1: Get Your Team ID (`APPLE_TEAM_ID`)

1. Sign in to [Apple Developer](https://developer.apple.com/account).
2. In the top-right corner, click your name or go to **Membership details**.
3. Copy the **Team ID** — a 10-character alphanumeric string (e.g., `AB12CD34EF`).

> This maps to `APPLE_TEAM_ID` in your `.env`.

---

## Step 2: Register an App ID

If you haven't already registered an App ID for TravelConnect:

1. Go to [Certificates, Identifiers & Profiles](https://developer.apple.com/account/resources/identifiers/list).
2. Click the **+** button next to **Identifiers**.
3. Select **App IDs** → **App** → Continue.
4. Fill in:
   - **Description**: `TravelConnect`
   - **Bundle ID**: Select **Explicit** and enter your bundle ID (e.g., `com.travelconnect.app`)
5. Scroll down to the **Capabilities** list and check **Sign in with Apple**.
6. Click **Continue** → **Register**.

If the App ID already exists, edit it and make sure **Sign in with Apple** is enabled.

---

## Step 3: Create a Service ID (`APPLE_CLIENT_ID`)

The Service ID is used by your **Laravel backend** (via Socialite) to validate tokens from the iOS app.

1. Go to [Identifiers](https://developer.apple.com/account/resources/identifiers/list).
2. Click the **+** button → Select **Services IDs** → Continue.
3. Fill in:
   - **Description**: `TravelConnect Web Auth`
   - **Identifier**: Use a reverse-domain identifier, e.g., `com.travelconnect.auth` (this must be different from your App ID)
4. Click **Continue** → **Register**.
5. Back in the list, click on the Service ID you just created.
6. Check **Sign in with Apple** → click **Configure**.
7. In the configuration dialog:
   - **Primary App ID**: Select your TravelConnect App ID.
   - **Domains and Subdomains**: Enter your API domain (e.g., `your-domain.com`).
   - **Return URLs**: Enter your callback URL: `https://your-domain.com/api/auth/apple/callback`
8. Click **Next** → **Done** → **Continue** → **Save**.

> The **Identifier** you chose (e.g., `com.travelconnect.auth`) is your `APPLE_CLIENT_ID`.

---

## Step 4: Create a Private Key (`APPLE_KEY_ID` + `APPLE_PRIVATE_KEY`)

1. Go to [Keys](https://developer.apple.com/account/resources/authkeys/list).
2. Click the **+** button.
3. Fill in:
   - **Key Name**: `TravelConnect Sign In`
4. Check **Sign in with Apple** → click **Configure**.
5. Select your **Primary App ID** (TravelConnect) → **Save**.
6. Click **Continue** → **Register**.
7. **Important — Download the key file now!** You can only download it once.
   - The file is named `AuthKey_XXXXXXXXXX.p8` — the `XXXXXXXXXX` part is your **Key ID**.
   - Also note the **Key ID** displayed on the confirmation page.
8. Click **Done**.

### Extract the private key content

Open the `.p8` file in a text editor. It looks like this:

```
-----BEGIN PRIVATE KEY-----
MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQg...
(several lines of base64 text)
...
-----END PRIVATE KEY-----
```

You will paste the **entire content** (including the `BEGIN` and `END` lines) into your `.env` file.

> The **Key ID** maps to `APPLE_KEY_ID`.
> The **file contents** map to `APPLE_PRIVATE_KEY`.

---

