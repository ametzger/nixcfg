c = get_config()  # type: ignore

c.TerminalIPythonApp.display_banner = False

# Enable C-x C-e to open `$EDITOR` with current cell
c.TerminalInteractiveShell.extra_open_editor_shortcuts = True

# uncomment to debug
#  c.InteractiveShellApp.exec_lines = ['print("asm cfg loaded")']
