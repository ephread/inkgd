# ############################################################################ #
# Copyright © 2015-2021 inkle Ltd.
# Copyright © 2019-2023 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

class_name Ink

# ############################################################################ #

enum ErrorType {
	AUTHOR = 0,
	WARNING = 1,
	ERROR = 2
}

enum PushPopType {
	TUNNEL = 0,
	FUNCTION = 1,
	FUNCTION_EVALUATION_FROM_GAME = 2
}

enum ValueType {
	BOOL = -1,

	INT,
	FLOAT,
	LIST,
	STRING,

	DIVERT_TARGET,
	VARIABLE_POINTER
}
