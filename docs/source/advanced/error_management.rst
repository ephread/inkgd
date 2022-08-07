Error Management
================

C# Runtime
----------

The original implementation relies on two mechanisms to report issues: runtime exceptions and
story error/warnings.

Runtime Exceptions
******************

The runtime can raise three types of exceptions.

1. Regular System Exceptions, which are usually thrown when the runtime encountered an error it
   can't recover from. They result from a misconfiguration or the misuse of an API.
2. Argument exceptions, which are very similar to the ones above. They may occur when executing
   Ink functions from C# while providing unsupported arguments.
3. Story Exception, which are **ink** errors that can't be caught during the compilation and mean
   that the author made a mistake when writing the ink.

Story Error / Warnings
**********************

These errors are usually recoverable. Recent versions of the runtime allow hooking a handler to
receive the second kind of error in real-time. If no callbacks are provided, they are raised
as Story Exceptions.

GDScript Runtime
-----------------

GDscript doesn't use exceptions, thus *inkgd* can't map the C# runtime's behavior. In *inkgd*,
errors are split into two categories: *Exceptions* and *Errors*.

Vanilla **inkgd**
*****************

Exceptions
^^^^^^^^^^

Exceptions are reported through the ``exception_raised`` signal declared on  ``__InkRuntime``.
Depending on the build type the runtime will behave differently.

#. This is a debug build:

   * if the runtime is running in the editor (for instance, in an editor plugin), exceptions
     and their stack traces are printed to the console;

   * if the runtime is running in a standalone executable (a game), exceptions are pushed
     to the editor/terminal using ``push_error``;

   * if ``__InkRuntime.stop_execution_on_exception`` is ``true``, exceptions are reported using
     ``assert`` instead, which pauses the execution and makes them explicit.

#. This is a release build:

   * nothing happens; the error is ignored.

If a handler is connected to ``exception_raised``, the exception is also sent to the handler.

Errors
^^^^^^

Errors are reported through the ``on_error`` signal declared on  ``story.gd`` and stored in
``current_errors`` / ``current_warnings``. If no handlers are connected to ``on_error``,
errors are raised as exceptions and reported through ``__InkRuntime.exception_raised`` instead.

If the runtime is running in a debug build, there are no handlers connected to ``on_error``
and ``__InkRuntime.stop_execution_on_error`` is set to ``true``, the execution will pause each
time a warning/error is encountered.

InkPlayer
*********

Using ``InkPlayer`` simplifies error management. Errors and warnings can be observed through
``exception_raised``; while exceptions can be monitored through ``error_encountered``.
