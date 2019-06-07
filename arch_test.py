import unittest
from arch import *


class MenuTest(unittest.TestCase):
    def test_menu_attributes(self):
        menu = InstallationGuide()
        self.assertEqual("Installation Guide", menu.title)
        submenus = menu.submenus
        self.assertEqual(5, len(submenus))
        self.assertEqual(4, submenus[3].number)
        self.assertListEqual([4], submenus[3].hierarchy)


class ChoicesTest(unittest.TestCase):
    def test_simple(self):
        choice = Choice({
            '1': 'One',
            'f': ' respecc'
        }, '1')
        self.assertListEqual(['1', 'f'], choice.choices)
        self.assertListEqual(['One', ' respecc'], choice.descriptions)
        self.assertTrue('One' in choice.descriptions_formatted[0])
        self.assertEqual('1', choice.default)

    def test_with_return(self):
        choice = ChoiceWithReturn({
            '1': 'One',
            'f': ' respecc'
        }, 'r')
        self.assertListEqual(['1', 'f', 'r'], choice.choices)
        self.assertListEqual(['One', ' respecc', 'Return'], choice.descriptions)
        self.assertTrue('One' in choice.descriptions_formatted[0])
        self.assertEqual('r', choice.default)

    def test_menu(self):
        choice = MenuChoice(InstallationGuide())
        self.assertListEqual(['1', '2', '3', '4', '5', 'r'], choice.choices)
        self.assertListEqual([
            'Pre-installation',
            'Installation',
            'Configure the system',
            'Reboot',
            'Post-installation',
            'Return'
        ], choice.descriptions)


if __name__ == '__main__':
    unittest.main()
