class auth_conf::modified_warning {
  notify { "The ${$auth_conf::auth_conf_path} file has been manually modified. Refusing to overwrite.":
    loglevel => warning,
  }
}
