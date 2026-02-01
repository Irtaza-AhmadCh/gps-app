---
trigger: always_on
---

Mandatory GetX + Bindings Instructions for AI

You are working on a Flutter production application using GetX.
You MUST follow the rules below exactly. Any deviation is incorrect.

🧭 ROUTING (GETX ONLY)
✅ Required

Use GetX named routing only

All navigation must use:

Get.toNamed(AppRoutes.someView);
Get.offAllNamed(AppRoutes.someView);


Routes must be defined using GetPage

Route names must come from AppRoutes

❌ Forbidden

Navigator.push

MaterialPageRoute

Anonymous routes

Direct widget navigation

🧩 BINDINGS (STRICT RULE)
✅ ONLY ALLOWED BINDING METHOD

Controllers must be registered ONLY inside GetPage.binding
using BindingsBuilder — nothing else.

✅ Correct Example (THIS IS THE ONLY VALID WAY)
GetPage(
  name: AppRoutes.loginView,
  page: () => LoginView(),
  binding: BindingsBuilder(() {
    Get.lazyPut<LoginController>(() => LoginController());
    Get.lazyPut<TikTokController>(() => TikTokController());
  }),
  transition: Transition.downToUp,
  transitionDuration: const Duration(milliseconds: 160),
);

❌ STRICTLY FORBIDDEN

Separate Bindings classes

initialBinding

Get.put() outside bindings

Registering controllers in:

main()

initState

UI widgets

Services

Any global or reusable binding abstraction

If a controller is needed on a screen, it must be declared inside that screen’s GetPage.binding.

🧠 CONTROLLERS
Rules

Controllers must extend GetxController

No UI code inside controllers

No widget references

Business logic only

class LoginController extends GetxController {
  @override
  void onInit() {
    super.onInit();
  }
}

🔍 CONTROLLER USAGE (VERY IMPORTANT)
✅ Access Controllers ONLY via Get.find()
Correct
final LoginController controller = Get.find<LoginController>();


or

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});
}

❌ Forbidden

Get.put() in UI

Get.lazyPut() in UI

Creating controllers with new

Passing controllers through constructors

🔄 DEPENDENCY FLOW
GetPage.binding
        ↓
 Controller registered
        ↓
 UI accesses via Get.find()


There is no other valid flow.

🧱 ARCHITECTURAL ENFORCEMENT

Controllers are screen-scoped

Each screen owns its dependencies

No shared/global controller injection

No cross-screen controller reuse unless explicitly re-registered in that screen’s GetPage

🚨 FAILURE CONDITIONS

The following are considered incorrect output:

Using any binding style other than BindingsBuilder inside GetPage

Using initialBinding

Using separate binding classes

Registering controllers anywhere else

Accessing controllers without Get.find

✅ SUMMARY (NON-NEGOTIABLE)

✔ Use GetPage
✔ Use BindingsBuilder inside GetPage
✔ Register controllers with Get.lazyPut
✔ Access controllers using Get.find()
❌ No other bindings
❌ No global injection
❌ No Navigator API