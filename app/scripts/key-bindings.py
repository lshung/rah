import sys
import re
import subprocess
import json


class Table:
    def __init__(self):
        self.padding_size = 1
        self.border_horizontal = "-"
        self.border_vertical = "|"
        self.border_corner = "+"
        self.table_data = []
        self.row_count = 0
        self.column_widths = []

    def display(self, table_data):
        if not table_data:
            return

        self.table_data = table_data
        self.row_count = len(self.table_data)
        self.column_widths = [0] * len(self.table_data[0])

        self.calculate_width_of_all_columns()
        self.render()

    def calculate_width_of_all_columns(self):
        for row in self.table_data:
            self.process_single_row_to_calculate_column_widths(row)

    def process_single_row_to_calculate_column_widths(self, row):
        for i, cell in enumerate(row):
            if i < len(self.column_widths):
                self.column_widths[i] = max(self.column_widths[i], len(str(cell)))
            else:
                print(f"Error: Mismatched number of columns at row: {row}")
                sys.exit(1)

    def render(self):
        for i, row in enumerate(self.table_data):
            is_header = (i == 0)
            is_last = (i == self.row_count - 1)

            if is_header:
                self.draw_border()

            self.draw_row(row)

            if is_header or is_last:
                self.draw_border()

    def draw_border(self):
        print(self.border_corner, end="")
        for width in self.column_widths:
            border_length = width + (self.padding_size * 2)
            print(self.border_horizontal * border_length, end=self.border_corner)
        print()

    def draw_row(self, row_data):
        print(self.border_vertical, end="")
        for i, cell in enumerate(row_data):
            self.draw_cell(cell, self.column_widths[i])
        print()

    def draw_cell(self, cell_content, column_width):
        cell_text = str(cell_content)
        padding = " " * self.padding_size
        spaces = " " * (column_width - len(cell_text))
        print(padding + cell_text + spaces + padding, end=self.border_vertical)


class HyprlandTab:
    def __init__(self):
        self.table_data = []
        self.key_binding_text_max_width = 0

    def display(self, table_data):
        if not table_data:
            return

        self.table_data = table_data

        self.calculate_max_width_of_key_binding_text()
        self.render()

    def calculate_max_width_of_key_binding_text(self):
        for row in self.table_data:
            # If the submap is not empty, add 3 to the max width (for the parentheses and the space)
            if row[2]:
                self.key_binding_text_max_width = max(self.key_binding_text_max_width, len(str(row[1])) + len(str(row[2])) + 3)
            else:
                self.key_binding_text_max_width = max(self.key_binding_text_max_width, len(str(row[1])))

    def render(self):
        current_group = ""

        for row in self.table_data:
            group = row[0]

            if group != current_group:
                print(f"{group}")
                current_group = group

            self.draw_row(row)

    def draw_row(self, row_data):
        key_binding_text = row_data[1]
        submap = row_data[2]
        description = row_data[3]
        spaces = " " * (self.key_binding_text_max_width - len(row_data[1]))

        if submap:
            print(" " * 8 + key_binding_text + " (" + submap + ")" + spaces + " >> " + description)
        else:
            print(" " * 8 + key_binding_text + spaces + "   >>   " + description)


class ZshTab:
    def __init__(self):
        self.table_data = []
        self.key_max_width = 0
        self.converted_key_max_width = 0

    def display(self, table_data):
        if not table_data:
            return

        self.table_data = table_data

        self.calculate_max_width_of_key()
        self.calculate_max_width_of_converted_key()
        self.render()

    def calculate_max_width_of_key(self):
        for row in self.table_data:
            self.key_max_width = max(self.key_max_width, len(str(row[0])))

    def calculate_max_width_of_converted_key(self):
        for row in self.table_data:
            self.converted_key_max_width = max(self.converted_key_max_width, len(str(row[1])))

    def render(self):
        for row in self.table_data:
            key = row[0]
            converted_key = row[1]
            description = row[2]
            spaces1 = " " * (self.key_max_width - len(key))
            spaces2 = " " * (self.converted_key_max_width - len(converted_key))

            print(key + spaces1 + "   >>   " + converted_key + spaces2 + "   >>   " + description)


class KeyBindingUtil:
    @staticmethod
    def convert_hyprland_modmask_from_numeric_to_string(modmask):
        if modmask == 0:
            return ""

        parts = []

        if modmask & 64: parts.append("Super")
        if modmask & 4: parts.append("Ctrl")
        if modmask & 8: parts.append("Alt")
        if modmask & 1: parts.append("Shift")
        if modmask & 2: parts.append("Caps")
        if modmask & 16: parts.append("Mod2")
        if modmask & 32: parts.append("Mod3")
        if modmask & 128: parts.append("Mod5")

        return "+".join(parts)

    @staticmethod
    def extract_hyprland_group_and_description(description):
        cleaned_description = description
        group = ""

        if re.match(r'^\[(.*)\]\s*(.*)$', description):
            group = re.match(r'^\[(.*)\]\s*(.*)$', description).group(1)
            cleaned_description = re.match(r'^\[(.*)\]\s*(.*)$', description).group(2)
        else:
            group = ""
            cleaned_description = description

        return [group, cleaned_description]

    @staticmethod
    def convert_zsh_key_binding_to_string(key_binding):
        # Remove the double quotes, but not \"
        key_binding = re.sub(r'(?<!\\)"', "", key_binding)

        # Format: ^X or ^x
        pattern = r'^\^([A-Za-z])$'
        if re.match(pattern, key_binding):
            return f"Ctrl+{re.match(pattern, key_binding).group(1)}"

        # Format: ^s where s is a special character
        pattern = r'^\^([\_\?])$'
        if re.match(pattern, key_binding):
            return f"Ctrl+{re.match(pattern, key_binding).group(1)}"

        # Format: ^@ not Ctrl+Shift+2 but just Ctrl+2
        pattern = r'^\^@$'
        if re.match(pattern, key_binding):
            return "Ctrl+2"

        # Format: ^[X
        pattern = r'^\^\[([A-Z])$'
        if re.match(pattern, key_binding):
            return f"Alt+Shift+{re.match(pattern, key_binding).group(1)}"

        # Format: ^[s where s is a special character
        pattern = r'^\^\[([\.\<\>\?\!\_\-\'])$'
        if re.match(pattern, key_binding):
            return f"Alt+{re.match(pattern, key_binding).group(1)}"

        # Format: ^[space
        pattern = r'^\^\[([\ ])$'
        if re.match(pattern, key_binding):
            return f"Alt+Space"

        # Format: ^[\s where s is a special character
        pattern = r'^\^\[\\([\"])$'
        if re.match(pattern, key_binding):
            return f"Alt+{re.match(pattern, key_binding).group(1)}"

        # Format: ^[x
        pattern = r'^\^\[([a-z])$'
        if re.match(pattern, key_binding):
            return f"Alt+{re.match(pattern, key_binding).group(1).upper()}"

        # Format: ^[d
        pattern = r'^\^\[([0-9])$'
        if re.match(pattern, key_binding):
            return f"Alt+{re.match(pattern, key_binding).group(1)}"

        # Format: ^[s where s is a special character
        pattern = r'^\^\[([\|])$'
        if re.match(pattern, key_binding):
            return f"Alt+{re.match(pattern, key_binding).group(1)}"

        # Format: ^[\s where s is a special character
        pattern = r'^\^\[\\([\$])$'
        if re.match(pattern, key_binding):
            return f"Alt+{re.match(pattern, key_binding).group(1)}"

        # Format: ^[^X
        pattern = r'^\^\[\^([A-Z])$'
        if re.match(pattern, key_binding):
            return f"Ctrl+Alt+{re.match(pattern, key_binding).group(1)}"

        # Format: ^[^s where s is a special character
        pattern = r'^\^\[\^([\_\?])$'
        if re.match(pattern, key_binding):
            return f"Ctrl+Alt+{re.match(pattern, key_binding).group(1)}"

        # Format: ^X^X
        pattern = r'^\^([A-Z])\^([A-Z])$'
        if re.match(pattern, key_binding):
            return f"Ctrl+{re.match(pattern, key_binding).group(1)} Ctrl+{re.match(pattern, key_binding).group(2)}"

        # Format: ^XX
        pattern = r'^\^([A-Z])([A-Z])$'
        if re.match(pattern, key_binding):
            return f"Ctrl+{re.match(pattern, key_binding).group(1)} Shift+{re.match(pattern, key_binding).group(2)}"

        # Format: ^Xx
        pattern = r'^\^([A-Z])([a-z])$'
        if re.match(pattern, key_binding):
            return f"Ctrl+{re.match(pattern, key_binding).group(1)} {re.match(pattern, key_binding).group(2).upper()}"

        # Format: ^Xs where s is a special character
        pattern = r'^\^([A-Z])([\*\=])$'
        if re.match(pattern, key_binding):
            return f"Ctrl+{re.match(pattern, key_binding).group(1)} {re.match(pattern, key_binding).group(2).upper()}"

        # Format: Arrow keys
        if re.match(r'^\^\[([O|\[]A)$', key_binding):
            return "Up"
        if re.match(r'^\^\[([O|\[]B)$', key_binding):
            return "Down"
        if re.match(r'^\^\[([O|\[]C)$', key_binding):
            return "Right"
        if re.match(r'^\^\[([O|\[]D)$', key_binding):
            return "Left"

        return ""


class KeyBinding:
    def __init__(self, type, style):
        self.key_binding_type = type
        self.output_style = style
        self.key_bindings_raw_data = []
        self.key_bindings_data = []

    def run(self):
        self.get_key_bindings_list()
        self.display_key_bindings_list()

    def get_key_bindings_list(self):
        if self.key_binding_type == "hyprland":
            self.get_hyprland_key_bindings_list()
        elif self.key_binding_type == "zsh":
            self.get_zsh_key_bindings_list()

    def get_hyprland_key_bindings_list(self):
        raw_data = subprocess.run(["hyprctl", "binds", "-j"], stdout=subprocess.PIPE, stderr=subprocess.PIPE).stdout.decode("utf-8")
        self.key_bindings_raw_data = json.loads(raw_data)

        self.process_hyprland_key_bindings_data()

    def process_hyprland_key_bindings_data(self):
        for key_binding in self.key_bindings_raw_data:
            converted_modmask = KeyBindingUtil.convert_hyprland_modmask_from_numeric_to_string(key_binding["modmask"])
            key_binding_text = f"{converted_modmask}+{key_binding['key']}" if converted_modmask else key_binding['key']
            group, cleaned_description= KeyBindingUtil.extract_hyprland_group_and_description(key_binding["description"])

            self.key_bindings_data.append([group, key_binding_text, key_binding["submap"], cleaned_description])

    def get_zsh_key_bindings_list(self):
        raw_data = subprocess.run(["zsh", "-c", "bindkey"], stdout=subprocess.PIPE, stderr=subprocess.PIPE).stdout.decode("utf-8")
        raw_data = raw_data.split("\n")
        for line in raw_data:
            if line and re.match(r'^(\".*\")\s+(.*)$', line):
                key_binding = re.match(r'^(\".*\")\s+(.*)$', line).group(1)
                description = re.match(r'^(\".*\")\s+(.*)$', line).group(2)
                self.key_bindings_raw_data.append([key_binding, description])

        self.process_zsh_key_bindings_data()
        self.remove_empty_zsh_converted_key_bindings()
        self.sort_zsh_key_bindings_data_by_converted_key_binding()

    def process_zsh_key_bindings_data(self):
        for key_binding in self.key_bindings_raw_data:
            converted_key_binding = KeyBindingUtil.convert_zsh_key_binding_to_string(key_binding[0])
            description = key_binding[1].replace("-", " ").capitalize()

            self.key_bindings_data.append([key_binding[0], converted_key_binding, description])

    def remove_empty_zsh_converted_key_bindings(self):
        self.key_bindings_data = [x for x in self.key_bindings_data if x[1]]

    def sort_zsh_key_bindings_data_by_converted_key_binding(self):
        self.key_bindings_data.sort(key=lambda x: x[1])

    def display_key_bindings_list(self):
        if self.output_style == "table":
            if self.key_binding_type == "hyprland":
                self.add_header_to_hyprland_key_bindings_data()
            elif self.key_binding_type == "zsh":
                self.add_header_to_zsh_key_bindings_data()

            Table().display(self.key_bindings_data)

        elif self.output_style in ["tab", "rofi"]:
            if self.key_binding_type == "hyprland":
                HyprlandTab().display(self.key_bindings_data)
            elif self.key_binding_type == "zsh":
                ZshTab().display(self.key_bindings_data)

    def add_header_to_hyprland_key_bindings_data(self):
        self.key_bindings_data.insert(0, ["Group", "Key", "Submap", "Description"])

    def add_header_to_zsh_key_bindings_data(self):
        self.key_bindings_data.insert(0, ["Key", "Converted key", "Description"])


if __name__ == "__main__":
    kb = KeyBinding(sys.argv[1], sys.argv[2])
    kb.run()
