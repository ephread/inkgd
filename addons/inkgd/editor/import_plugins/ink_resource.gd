# ############################################################################ #
# Copyright © 2019-present Frédéric Maquin <fred@ephread.com>
# Licensed under the MIT License.
# See LICENSE in the project root for license information.
# ############################################################################ #

tool
extends Resource

# A very simple resource to store the content of a json file, as a string.
class_name InkResource

# ############################################################################ #
# Properties
# ############################################################################ #

export(String) var json: String = ""
