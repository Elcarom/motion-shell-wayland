#include "include/motion_layer_shell/motion_layer_shell_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk-layer-shell.h>
#include <gtk/gtk.h>
#include <sys/utsname.h>

#include <cstring>

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

static void configure_layer_window(FlPluginRegistrar* registrar) {
  const gchar* enabled = g_getenv("MOTION_LAYER_SHELL");

  if (g_strcmp0(enabled, "1") != 0) {
    return;
  }

  FlView* view = fl_plugin_registrar_get_view(registrar);

  if (view == nullptr) {
    g_warning("Motion layer shell: registrar has no Flutter view");
    return;
  }

  GtkWidget* top_level =
      gtk_widget_get_toplevel(GTK_WIDGET(view));

  if (!GTK_IS_WINDOW(top_level)) {
    g_warning("Motion layer shell: Flutter view has no GtkWindow");
    return;
  }

  if (gtk_widget_get_realized(top_level)) {
    g_warning(
        "Motion layer shell: GtkWindow was realized too early");
    return;
  }

  GtkWindow* window = GTK_WINDOW(top_level);

  gtk_window_set_decorated(window, FALSE);
  gtk_window_set_resizable(window, FALSE);
  gtk_window_set_default_size(window, 520, 820);

  gtk_layer_init_for_window(window);
  gtk_layer_set_namespace(window, "motion-shell-probe");
  gtk_layer_set_layer(
      window,
      GTK_LAYER_SHELL_LAYER_OVERLAY);

  gtk_layer_set_anchor(
      window,
      GTK_LAYER_SHELL_EDGE_TOP,
      TRUE);
  gtk_layer_set_anchor(
      window,
      GTK_LAYER_SHELL_EDGE_RIGHT,
      TRUE);
  gtk_layer_set_anchor(
      window,
      GTK_LAYER_SHELL_EDGE_BOTTOM,
      FALSE);
  gtk_layer_set_anchor(
      window,
      GTK_LAYER_SHELL_EDGE_LEFT,
      FALSE);

  gtk_layer_set_margin(
      window,
      GTK_LAYER_SHELL_EDGE_TOP,
      76);
  gtk_layer_set_margin(
      window,
      GTK_LAYER_SHELL_EDGE_RIGHT,
      16);

  gtk_layer_set_exclusive_zone(window, 0);
  gtk_layer_set_keyboard_mode(
      window,
      GTK_LAYER_SHELL_KEYBOARD_MODE_ON_DEMAND);

  g_message(
      "Motion layer shell configured before window realization");
}

static void motion_layer_shell_plugin_handle_method_call(
    MotionLayerShellPlugin* self,
    FlMethodCall* method_call) {
  const gchar* method =
      fl_method_call_get_name(method_call);

  g_autoptr(FlMethodResponse) response = nullptr;

  if (strcmp(method, "getPlatformVersion") == 0) {
    response = get_platform_version();
  } else {
    response = FL_METHOD_RESPONSE(
        fl_method_not_implemented_response_new());
  }

  fl_method_call_respond(
      method_call,
      response,
      nullptr);
}

FlMethodResponse* get_platform_version() {
  struct utsname uname_data = {};
  uname(&uname_data);

  g_autofree gchar* version =
      g_strdup_printf(
          "Linux %s",
          uname_data.version);

  g_autoptr(FlValue) result =
      fl_value_new_string(version);

  return FL_METHOD_RESPONSE(
      fl_method_success_response_new(result));
}

static void motion_layer_shell_plugin_dispose(
    GObject* object) {
  G_OBJECT_CLASS(
      motion_layer_shell_plugin_parent_class)
      ->dispose(object);
}

static void motion_layer_shell_plugin_class_init(
    MotionLayerShellPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose =
      motion_layer_shell_plugin_dispose;
}

static void motion_layer_shell_plugin_init(
    MotionLayerShellPlugin* self) {}

static void method_call_cb(
    FlMethodChannel* channel,
    FlMethodCall* method_call,
    gpointer user_data) {
  MotionLayerShellPlugin* plugin =
      MOTION_LAYER_SHELL_PLUGIN(user_data);

  motion_layer_shell_plugin_handle_method_call(
      plugin,
      method_call);
}

void motion_layer_shell_plugin_register_with_registrar(
    FlPluginRegistrar* registrar) {
  configure_layer_window(registrar);

  MotionLayerShellPlugin* plugin =
      MOTION_LAYER_SHELL_PLUGIN(
          g_object_new(
              motion_layer_shell_plugin_get_type(),
              nullptr));

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
