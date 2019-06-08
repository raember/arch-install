#!/usr/bin/env python3
import logging
import os.path
import subprocess
from typing import List, Tuple, Dict, Any

import settings

logging.basicConfig(
    format='%(asctime)s %(levelname)-8s %(name)18s: %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S',
    level=logging.DEBUG
)


def main(sys: 'System'):
    screen = Screen()
    menu = InstallationGuide()
    menu.initialize()
    while menu is not None:
        try:
            menu = menu.run(screen, sys)
        except KeyboardInterrupt:
            screen.print_error("Received a keyboard interrupt")
            break


class Menu:
    title: str
    number: int
    hierarchy: List[int] = []
    submenus: List['Menu']
    parent: 'Menu' = None
    available = True
    visited = False
    log: logging.Logger

    def __init__(self, *submenus: 'Menu'):
        self.log = logging.getLogger(self.__class__.__name__)
        self.submenus = list(submenus)

    def initialize(self):
        self._populate_submenu_hierarchies()

    def _populate_submenu_hierarchies(self):
        index = 1
        for submenu in self.submenus:
            submenu.parent = self
            submenu.number = index
            submenu.hierarchy = self.hierarchy.copy()
            submenu.hierarchy.append(submenu.number)
            # self.log.debug(f"Hierarchy for {submenu.title} is {submenu.hierarchy}")
            submenu._populate_submenu_hierarchies()
            index += 1

    def hierarchy_to_str(self) -> str:
        if len(self.hierarchy) == 0:
            return ''
        if self.available:
            if self.visited:
                number_fmt = Format.NOT_IMPORTANT
            else:
                number_fmt = Format.PRIMARY
        else:
            number_fmt = Format.DISABLED
        number_str = f"{number_fmt}{self.number}{Format.RESET}"
        if len(self.hierarchy) > 1:
            higher_levels_fmt = Format.NOT_IMPORTANT
            str_hierarchy = f"{higher_levels_fmt}{'.'.join(map(str, self.hierarchy[:-1]))}.{number_str}"
        else:
            str_hierarchy = number_str
        return f"{str_hierarchy}"

    def run(self, screen: 'Screen', sys: 'System') -> 'Menu':
        self.log.debug(f"Running {'.'.join(map(str, self.hierarchy))} {self.title}")
        self.visited = True
        # screen.clear()
        # screen.print_title(self)
        return self._run(screen, sys)

    def _run(self, screen: 'Screen', sys: 'System') -> 'Menu':
        if len(self.submenus) == 0:
            self.log.warning("No sub menus.")
            return self.parent
        menu = MenuChoice(self).choose(self, screen)
        if menu is None:
            return self.parent
        return menu

    def get_choices(self) -> Tuple[Dict[str, str], str]:
        choices = {}
        recommendation = ''
        for menu in self.submenus:
            if menu.available:
                choices[str(menu.number)] = menu.to_formatted_str()
                if recommendation == '' and not menu.visited:
                    recommendation = str(menu.number)
        choices[Choice.KEY_RETURN] = f"{Format.PRIMARY}{Choice.KEY_RETURN}{Format.NOT_IMPORTANT} {Format.RESET}Return"
        if recommendation == '':
            recommendation = Choice.KEY_RETURN
        return choices, recommendation

    def to_formatted_str(self) -> str:
        if self.available:
            if self.visited:
                return f"{self.hierarchy_to_str()} {Format.NOT_IMPORTANT}{self.title}{Format.RESET}"
            else:
                return f"{self.hierarchy_to_str()} {self.title}"
        else:
            return f"{self.hierarchy_to_str()} {Format.DISABLED}{self.title}{Format.RESET}"


class InstallationGuide(Menu):
    title = "Installation Guide"

    def __init__(self):
        super().__init__(
            PreInstallation(
                VerifySignature(),
                BootLiveEnvironment(),
                SetKeyboardLayout(),
                VerifyBootMode(),
                ConnectToInternet(),
                UpdateSystemClock(),
                PartitionDisks(
                    ExampleLayouts()
                ),
                FormatPartitions(),
                MountFileSystems(),
            ),
            Installation(
                SelectMirrors(),
                InstallBasePackages(),
            ),
            ConfigureSystem(
                Fstab(),
                Chroot(),
                Timezone(),
                Localization(),
                NetworkConfiguration(),
                Initramfs(),
                RootPassword(),
                BootLoader(),
            ),
            Reboot(),
            PostInstallation(),
        )
        self.hierarchy = []  # Prevents presetting 0 for submenus
        self._populate_submenu_hierarchies()


class PreInstallation(Menu):
    title = "Pre-installation"


class VerifySignature(Menu):
    title = "Verify signature"
    available = False


class BootLiveEnvironment(Menu):
    title = "Boot the live environment"
    available = False


class SetKeyboardLayout(Menu):
    title = "Set the keyboard layout"

    def _run(self, screen: 'Screen', sys: 'System') -> 'Menu':
        layout = settings.PreInstallation.KeyboardLayout.Layout
        font = settings.PreInstallation.KeyboardLayout.ConsoleFont
        # layout = ''
        # font = ''
        set_keyboard = False
        set_font = False
        while True:
            CHOICE_KEYBOARD = 'k'
            CHOICE_FONT = 'f'
            default = Choice.KEY_RETURN
            if not set_font:
                default = CHOICE_FONT
            if not set_keyboard:
                default = CHOICE_KEYBOARD
            choice = ChoiceWithReturn({
                CHOICE_KEYBOARD: "Set keyboard layout",
                CHOICE_FONT: "Set console font",
            }, default).choose(self, screen)
            if choice == Choice.KEY_RETURN:
                return self.parent
            elif choice == CHOICE_KEYBOARD:
                set_keyboard = self._set_keyboard_layout(screen, sys)
            elif choice == CHOICE_FONT:
                set_font = self._set_console_font(screen, sys)

    def _set_keyboard_layout(self, screen: 'Screen', sys: 'System') -> bool:
        layouts = self.get_keyboard_layouts(sys)
        layout = settings.PreInstallation.KeyboardLayout.Layout
        CHOICE_LIST = 'l'
        CHOICE_SET = 's'
        set_keyboard = False
        if layout not in layouts:
            while True:
                choice = ChoiceWithReturn({
                    CHOICE_LIST: "List avaliable fonts",
                    CHOICE_SET: "Set keyboard layout"
                }, CHOICE_SET).choose(self, screen)
                if choice == Choice.KEY_RETURN:
                    return set_keyboard
                elif choice == CHOICE_LIST:
                    screen.clear()
                    screen.print_title(self)
                    screen.print(f"{Format.NOT_IMPORTANT}, {Format.RESET}".join(layouts))
                screen.print("Please select a keyboard layout")
                layout = screen.read_line('> ')
                if layout not in layouts:
                    screen.print_error(f"Layout '{layout}' not in available layouts.")
                    screen.wait_for_enter()
                    continue
                if not self.set_keyboard_layout(sys, layout):
                    error_msg = f"Failed to set keyboard layout to '{layout}'"
                    self.log.error(error_msg)
                    screen.print_error(error_msg)
                    screen.wait_for_enter()
                    set_keyboard = False
                else:
                    screen.print(f"Set keyboard layout to {Format.META}{layout}{Format.RESET}")
                    screen.wait_for_enter()
                    set_keyboard = True

    @staticmethod
    def get_keyboard_layouts(sys: 'System') -> List[str]:
        proc = sys.run("ls /usr/share/kbd/keymaps/**/*.map.gz")
        proc.check_returncode()
        out = proc.stdout.decode('utf-8')
        layouts = []
        for path in out.split('\n'):
            filename_map_gz = os.path.basename(path)
            filename_map = os.path.splitext(filename_map_gz)[0]
            filename = os.path.splitext(filename_map)[0]
            layouts.append(filename)
        return layouts

    @staticmethod
    def set_keyboard_layout(sys: 'System', layout: str) -> bool:
        return sys.run(f"loadkeys {layout}").returncode == 0

    def _set_console_font(self, screen: 'Screen', sys: 'System') -> bool:
        fonts = SetKeyboardLayout.get_console_fonts(sys)
        font = settings.PreInstallation.KeyboardLayout.ConsoleFont
        CHOICE_LIST = 'l'
        CHOICE_SET = 's'
        CHOICE_TEST = 't'

    @staticmethod
    def get_console_fonts(sys: 'System') -> List[str]:
        proc = sys.run("ls /usr/share/kbd/consolefonts/*.gz")
        proc.check_returncode()
        out = proc.stdout.decode('utf-8')
        fonts = []
        for path in out.split('\n'):
            fonts.append(os.path.basename(path))
        return fonts

    @staticmethod
    def set_console_font(sys: 'System', font: str) -> bool:
        return sys.run(f"setfont {font}").returncode == 0


class VerifyBootMode(Menu):
    title = "Verify the boot mode"

    def _run(self, screen: 'Screen', sys: 'System') -> 'Menu':
        if VerifyBootMode.isUefi():
            screen.print(f"System runs in {Format.META}UEFI{Format.RESET} mode")
        else:
            screen.print(f"System runs in {Format.META}BIOS/CSM{Format.RESET} mode")
        screen.wait_for_enter()
        return self.parent

    @staticmethod
    def isUefi():
        return not os.path.isfile('/sys/firmware/efi/efivars')


class ConnectToInternet(Menu):
    title = "Connect to the internet"

    def _run(self, screen: 'Screen', sys: 'System') -> 'Menu':
        pass


class UpdateSystemClock(Menu):
    title = "Update the system clock"


class PartitionDisks(Menu):
    title = "Partition the disks"


class ExampleLayouts(Menu):
    title = "Example layouts"
    available = False


class FormatPartitions(Menu):
    title = "Format the partitions"


class MountFileSystems(Menu):
    title = "Mount the file systems"


class Installation(Menu):
    title = "Installation"


class SelectMirrors(Menu):
    title = "Select the mirrors"


class InstallBasePackages(Menu):
    title = "Install the base packages"


class ConfigureSystem(Menu):
    title = "Configure the system"


class Fstab(Menu):
    title = "Fstab"


class Chroot(Menu):
    title = "Chroot"


class Timezone(Menu):
    title = "Time zone"


class Localization(Menu):
    title = "Localization"


class NetworkConfiguration(Menu):
    title = "Network configuration"


class Initramfs(Menu):
    title = "Initramfs"


class RootPassword(Menu):
    title = "Root password"


class BootLoader(Menu):
    title = "Boot loader"


class Reboot(Menu):
    title = "Reboot"


class PostInstallation(Menu):
    title = "Post-installation"


def apply_formats(*codes: int) -> str:
    return f"\033[{';'.join(map(str, codes))}m"


class Format:
    class Foreground:
        BLACK = 30
        RED = 31
        GREEN = 32
        YELLOW = 33
        BLUE = 34
        MAGENTA = 35
        CYAN = 36
        GRAY = 37
        DEFAULT = 39

    class Background:
        BLACK = 40
        RED = 41
        GREEN = 42
        YELLOW = 43
        BLUE = 44
        MAGENTA = 45
        CYAN = 46
        GRAY = 47
        DEFAULT = 49

    class Font:
        BOLD = 1
        DIM = 2
        ITALIC = 3
        UNDERLINE = 4
        BLINK = 5
        OVERLINE = 6
        REVERSE = 7
        HIDDEN = 8
        STRIKEOUT = 9

    class Special:
        SHIFT = 60
        NO = 20
        RESET = 0

    PRIMARY = apply_formats(Foreground.BLUE, Font.BOLD)
    NOT_IMPORTANT = apply_formats(Foreground.GRAY + Special.SHIFT)
    DISABLED = apply_formats(Foreground.RED)
    ERROR = apply_formats(Foreground.RED + Special.SHIFT, Font.BOLD)
    RESET = apply_formats(Special.RESET)
    META = apply_formats(Foreground.MAGENTA)


class Choice:
    choices: List[str]
    descriptions: List[str]
    descriptions_formatted: List[str]
    default: str

    KEY_RETURN = 'r'

    def __init__(self, choices: Dict[str, str], default: str):
        self.choices = list(choices.keys())
        self.descriptions = list(choices.values())
        self.default = default
        self._format_descriptions()

    def _format_descriptions(self):
        self.descriptions_formatted = []
        for key, value in zip(self.choices, self.descriptions):
            self.descriptions_formatted.append(f"{Format.PRIMARY}{key}{Format.RESET} {value}")

    def print(self, screen: 'Screen'):
        for string in self.descriptions_formatted:
            screen.print(string)

    def choose(self, menu: Menu, screen: 'Screen') -> str:
        error = ''
        while True:
            screen.clear()
            screen.print_title(menu)
            self.print(screen)
            if error != '':
                screen.print_error(error)
            choice = screen.read_line(f"[{Format.PRIMARY}{self.default}{Format.NOT_IMPORTANT}]> ").lower()
            if choice == '':
                choice = self.default
            if choice not in self.choices:
                error = f"Invalid choice: {choice} not in ({', '.join(self.choices)})"
                continue
            return choice


class ChoiceWithReturn(Choice):
    def _format_descriptions(self):
        self.choices.append(Choice.KEY_RETURN)
        self.descriptions.append("Return")
        super()._format_descriptions()


class MenuChoice(ChoiceWithReturn):
    menu: Menu

    def __init__(self, menu: Menu):
        self.menu = menu
        choices = {}
        default = ''
        for menu in menu.submenus:
            if menu.available:
                choices[str(menu.number)] = menu.title
                if default == '' and not menu.visited:
                    default = str(menu.number)
        if default == '':
            default = Choice.KEY_RETURN
        super().__init__(choices, default)

    def _format_descriptions(self):
        self.choices.append(Choice.KEY_RETURN)
        self.descriptions.append("Return")
        self.descriptions_formatted = []
        for menu in self.menu.submenus:
            self.descriptions_formatted.append(menu.to_formatted_str())
        self.descriptions_formatted.append(f"{Format.PRIMARY}{Choice.KEY_RETURN}{Format.RESET} Return")

    def choose(self, menu: Menu, screen: 'Screen') -> Menu:
        choice = super().choose(menu, screen)
        if choice == 'r':
            return self.menu.parent
        return self.menu.submenus[int(choice) - 1]


class Screen:
    def clear(self):
        subprocess.run('clear')

    def print(self, *values: Any):
        print(*values)

    def print_title(self, menu: Menu):
        self.print(f"  {menu.hierarchy_to_str()} {Format.PRIMARY}{menu.title}{Format.RESET}")

    def print_menu(self, menu: Menu):
        raise NotImplementedError

    def read_line(self, prompt: str) -> str:
        return input(f"{Format.NOT_IMPORTANT}{prompt}{Format.RESET}")

    def print_choices(self, choices: Dict[str, str]):
        for key in choices:
            self.print(choices[key])

    def choose_menu(self, menu: Menu) -> Menu:
        choices, default = menu.get_choices()
        for submenu in menu.submenus:
            self.print(submenu.to_formatted_str())
        self.print(f"{Format.PRIMARY}r{Format.RESET} Return")
        while True:
            choice = self.choose(menu, choices, default)
            if choice == Choice.KEY_RETURN:
                return menu.parent
            index = int(choice) - 1
            if 0 <= index < len(menu.submenus):
                menu = menu.submenus[index]
                if menu.available:
                    return menu

    def choose(self, menu: Menu, choices: Dict[str, str], default: str) -> str:
        error = ''
        while True:
            self.clear()
            self.print_title(menu)
            self.print_choices(choices)
            if error != '':
                self.print_error(error)
            choice = self.read_line(f"[{Format.PRIMARY}{default}{Format.NOT_IMPORTANT}]> ").lower()
            if choice == '':
                choice = default
            if choice not in choices:
                error = f"Invalid choice: {choice} not in ({', '.join(choices)})"
                continue
            return choice

    def format_choices(self, choices: Dict[str, str]) -> Dict[str, str]:
        for key in choices:
            choices[key] = f"{Format.PRIMARY}{key}{Format.RESET} {choices[key]}"
        return choices

    def choose_with_return(self, menu: Menu, choices: Dict[str, str], default: str) -> str:
        choices[Choice.KEY_RETURN] = f"{Format.PRIMARY}r{Format.NOT_IMPORTANT} {Format.RESET}Return"
        return self.choose(menu, choices, default)

    def print_error(self, err: str):
        self.print(f"{Format.ERROR}{err}{Format.RESET}")

    def wait_for_enter(self):
        if settings.General.WaitAfterExecution:
            self.read_line("(hit Enter to continue)")


class System:
    log: logging.Logger

    def __init__(self):
        self.log = logging.getLogger(self.__class__.__name__)

    def run(self, cmd: str, input=None, muted=False) -> subprocess.CompletedProcess:
        self.log.info(f"Calling {cmd}")
        if muted:
            proc = subprocess.run(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, input=input)
        else:
            proc = subprocess.run(cmd, shell=True, input=input)
        self.log.info(f"Command returned with code {proc.returncode}")
        return proc


if __name__ == "__main__":
    main(System())
