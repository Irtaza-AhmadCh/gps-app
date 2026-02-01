---
trigger: always_on
---

always use statless and statfull widgets for  screen 
🌍 LOCALIZATION (STRICT)

NO hardcoded strings

Use:

AppStrings.appName.tr


Even if text is minimal, it must come from AppStrings

🎨 CONFIG USAGE (MANDATORY)

You MUST use:

AppColors → background, theme colors

AppAssets → logo image

AppStrings → text

AppRoutes → navigation

AppTextStyle → text styles

🚫 Never hardcode colors, strings, routes, or assets

📐 UI EXTENSIONS (STRICT)

You MUST use spacing & layout extensions:

✅ Allowed:

16.height
8.width
widget.paddingAll(16)


🚫 Forbidden:

SizedBox(height: 16)
EdgeInsets.all(16)

🧭 NAVIGATION (GETX ONLY)

Named routes only

Example:

Get.offAllNamed(AppRoutes.homeView);



use flutter font awesom for icons 


USE SCREENUTILE TO MAKE THINGS resp 




🚫 Do NOT use Navigator
🚫 Do NOT use MaterialPageRoute