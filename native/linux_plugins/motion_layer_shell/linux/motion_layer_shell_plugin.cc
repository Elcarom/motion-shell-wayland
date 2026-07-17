#include "include/motion_layer_shell/motion_layer_shell_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk-layer-shell.h>
#include <gtk/gtk.h>
#include <sys/utsname.h>

#include <cstring>
#include <string>

#include "motion_layer_shell_plugin_private.h"

#define MOTION_LAYER_SHELL_PLUGIN(obj) \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), motion_layer_shell_plugin_get_type(), \
                              MotionLayerShellPlugin))

struct _MotionLayerShellPlugin {
  GObject parent_instance;
};

G_DEFINE_TYPE(MotionLayerShellPlugin,
              motion_layer_shell_plugin,
              g_object_get_type())

namespace {

struct SurfaceSpec {
  const char* role;
  int width;
  int height;
  GtkLayerShellLayer layer;
  GtkLayerShellKeyboardMode keyboard_mode;
  bool top;
  bool right;
  bool bottom;
  bool left;
  int margin_top;
  int margin_right;
  int margin_bottom;
  int margin_left;
  bool auto_exclusive;
};

bool ReadSurfaceSpec(const char* role, SurfaceSpec* spec) {
  if (role == nullptr || role[0] == '\0' || spec == nullptr) {
    return false;
  }

  if (std::strcmp(role, "bar") == 0) {
    *spec = {
        "bar",
        0,
        64,
        GTK_LAYER_SHELL_LAYER_TOP,
        GTK_LAYER_SHELL_KEYBOARD_MODE_NONE,
        true,
        true,
        false,
        true,
        8,
        20,
        0,
        20,
        true,
    };
    return true;
  }

  if (std::strcmp(role, "quick-settings") == 0 ||
      std::strcmp(role, "notifications") == 0) {
    *spec = {
        role,
        440,
        640,
        GTK_LAYER_SHELL_LAYER_OVERLAY,
        GTK_LAYER_SHELL_KEYBOARD_MODE_ON_DEMAND,
        true,
        true,
        false,
        false,
        0,
        20,
        0,
        0,
        false,
    };
    return true;
  }

  if (std::strcmp(role, "launcher") == 0 ||
      std::strcmp(role, "search") == 0 ||
      std::strcmp(role, "overview") == 0) {
    *spec = {
        role,
        0,
        0,
        GTK_LAYER_SHELL_LAYER_OVERLAY,
        GTK_LAYER_SHELL_KEYBOARD_MODE_EXCLUSIVE,
        true,
        true,
        true,
        true,
        72,
        24,
        24,
        24,
        false,
    };
    return true;
  }

  if (std::strcmp(role, "osd") == 0) {
    *spec = {
        "osd",
        420,
        112,
        GTK_LAYER_SHELL_LAYER_OVERLAY,
        GTK_LAYER_SHELL_KEYBOARD_MODE_NONE,
        false,
        false,
        true,
        false,
        0,
        0,
        48,
        0,
        false,
    };
    return true;
  }

  return false;
}

void ConfigureLayerWindow(FlPluginRegistrar* registrar) {
  if (g_strcmp0(g_getenv("MOTION_LAYER_SHELL"), "1") != 0) {
    return;
  }

  const char* role = g_getenv("MOTION_SURFACE_ROLE");
  SurfaceSpec spec = {};

  if (!ReadSurfaceSpec(role, &spec)) {
    g_warning("Motion layer shell: unsupported or missing role '%s'",
              role == nullptr ? "" : role);
    return;
  }

  if (!gtk_layer_is_supported()) {
    g_warning("Motion layer shell: gtk-layer-shell is unsupported");
    return;
  }

  FlView* view = fl_plugin_registrar_get_view(registrar);
  if (view == nullptr) {
    g_warning("Motion layer shell: registrar has no Flutter view");
    return;
  }

  GtkWidget* top_level = gtk_widget_get_toplevel(GTK_WIDGET(view));
  if (!GTK_IS_WINDOW(top_level)) {
    g_warning("Motion layer shell: Flutter view has no GtkWindow");
    return;
  }

  if (gtk_widget_get_realized(top_level)) {
    g_warning("Motion layer shell: GtkWindow was realized too early");
    return;
  }

  GtkWindow* window = GTK_WINDOW(top_level);

  std::string namespace_name = "motion-shell-";
  namespace_name += spec.role;

  gtk_window_set_decorated(window, FALSE);

  gtk_widget_set_app_paintable(GTK_WIDGET(window), TRUE);

  gtk_layer_init_for_window(window);
  gtk_layer_set_namespace(window, namespace_name.c_str());
  gtk_layer_set_layer(window, spec.layer);
  gtk_layer_set_keyboard_mode(window, spec.keyboard_mode);

  gtk_layer_set_anchor(window, GTK_LAYER_SHELL_EDGE_TOP, spec.top);
  gtk_layer_set_anchor(window, GTK_LAYER_SHELL_EDGE_RIGHT, spec.right);
  gtk_layer_set_anchor(window, GTK_LAYER_SHELL_EDGE_BOTTOM, spec.bottom);
  gtk_layer_set_anchor(window, GTK_LAYER_SHELL_EDGE_LEFT, spec.left);

  gtk_layer_set_margin(window, GTK_LAYER_SHELL_EDGE_TOP, spec.margin_top);
  gtk_layer_set_margin(window, GTK_LAYER_SHELL_EDGE_RIGHT, spec.margin_right);
  gtk_layer_set_margin(window, GTK_LAYER_SHELL_EDGE_BOTTOM, spec.margin_bottom);
  gtk_layer_set_margin(window, GTK_LAYER_SHELL_EDGE_LEFT, spec.margin_left);

  // Configure anchors before forcing the window size. On an axis anchored to
  // opposite edges, gtk-layer-shell lets the compositor supply that dimension.
  // For the bar this means compositor-controlled width and a fixed 64 px height.
  gtk_widget_set_size_request(
      GTK_WIDGET(window),
      spec.width > 0 ? spec.width : -1,
      spec.height > 0 ? spec.height : -1);
  gtk_window_resize(window, 1, 1);

  if (spec.auto_exclusive) {
    gtk_layer_auto_exclusive_zone_enable(window);
  } else {
    gtk_layer_set_exclusive_zone(window, 0);
  }

  g_message("Motion layer shell configured role=%s namespace=%s",
            spec.role,
            namespace_name.c_str());
}

}  // namespace

static void motion_layer_shell_plugin_handle_method_call(
    MotionLayerShellPlugin* self,
    FlMethodCall* method_call) {
  const gchar* method = fl_method_call_get_name(method_call);
  g_autoptr(FlMethodResponse) response = nullptr;

  if (std::strcmp(method, "getPlatformVersion") == 0) {
    response = get_platform_version();
  } else {
    response =
        FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }

  fl_method_call_respond(method_call, response, nullptr);
}

FlMethodResponse* get_platform_version() {
  struct utsname uname_data = {};
  uname(&uname_data);

  g_autofree gchar* version =
      g_strdup_printf("Linux %s", uname_data.version);
  g_autoptr(FlValue) result = fl_value_new_string(version);

  return FL_METHOD_RESPONSE(fl_method_success_response_new(result));
}

static void motion_layer_shell_plugin_dispose(GObject* object) {
  G_OBJECT_CLASS(motion_layer_shell_plugin_parent_class)->dispose(object);
}

static void motion_layer_shell_plugin_class_init(
    MotionLayerShellPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = motion_layer_shell_plugin_dispose;
}

static void motion_layer_shell_plugin_init(
    MotionLayerShellPlugin* self) {}

static void method_call_cb(FlMethodChannel* channel,
                           FlMethodCall* method_call,
                           gpointer user_data) {
  MotionLayerShellPlugin* plugin =
      MOTION_LAYER_SHELL_PLUGIN(user_data);
  motion_layer_shell_plugin_handle_method_call(plugin, method_call);
}

void motion_layer_shell_plugin_register_with_registrar(
    FlPluginRegistrar* registrar) {
  ConfigureLayerWindow(registrar);

  MotionLayerShellPlugin* plugin =
      MOTION_LAYER_SHELL_PLUGIN(
          g_object_new(motion_layer_shell_plugin_get_type(), nullptr));

  g_autoptr(FlStandardMethodCodec) codec =
      fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel =
      fl_method_channel_new(
          fl_plugin_registrar_get_messenger(registrar),
          "motion_layer_shell",
          FL_METHOD_CODEC(codec));

  fl_method_channel_set_method_call_handler(
      channel,
      method_call_cb,
      g_object_ref(plugin),
      g_object_unref);

  g_object_unref(plugin);
}
