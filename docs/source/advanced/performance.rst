Performance
===========

*inkgd* is overall slow. The high number of allocations that Ink requires makes
GDScript choke.

For instance, loading The Intercept will create about 30,000 objects.
*ipsuminious 12* —a generated story based on The Intercept that contains about
90,000 words and 4,000 choices— will create a whopping 360,000 objects.

GDScript struggles to keep the performances at acceptable levels when allocating
such a large number of objects, making the creation of stories the major
bottleneck.

There's also a significant memory footprint. *ipsuminious 12* takes about
250 MB of RAM.


Benchmarks
----------

The time required to create and allocate a story is benchmarked below.

All benchmarks use variations of *ipsuminious*, a story based on the
Intercept, which can replicate itself to artifically increase the number
of words and constructs. The growth is linear. Size 12 is 12 times bigger than
size 1.

*ipsuminious* doesn't reflect real-world conditions, but should still give you
a rough idea of the time budget you need to consider.


Size 1
******

About the size of *The Intercept*.

.. list-table:: Statistics
   :header-rows: 1

   * - Bytecode
     - Words
     - Knots
     - Stitches
     - Functions
     - Choices
     - Gathers
     - Diverts
   * - 120 KB
     - 7,650
     - 34
     - 30
     - 3
     - 340
     - 95
     - 230

.. list-table:: Performances
   :header-rows: 1

   * - CPU
     - OS
     - Time
   * - AMD Ryzen 7 5800X (3.80 GHz)
     - Windows 11
     - 600 milliseconds
   * - Apple M1 (3.20 GHz)
     - macOS Monterey
     - 360 milliseconds
   * - Intel i5-6267U (2.90 GHz)
     - macOS Monterey
     - 1.52 seconds
   * - Apple A14 Bionic
     - iOS 15
     - 430 milliseconds
   * - Apple A9
     - iOS 13
     - 2.57 seconds

Size 6
******

.. list-table:: Statistics
   :header-rows: 1

   * - Bytecode
     - Words
     - Knots
     - Stitches
     - Functions
     - Choices
     - Gathers
     - Diverts
   * - 714 KB
     - 45,900
     - 199
     - 180
     - 18
     - 2040
     - 570
     - 1370

.. list-table:: Performances
   :header-rows: 1

   * - CPU
     - OS
     - Time
   * - AMD Ryzen 7 5800X (3.80 GHz)
     - Windows 11
     - 3.32 seconds
   * - Apple M1 (3.20 GHz)
     - macOS Monterey
     - 2.12 seconds
   * - Intel i5-6267U (2.90 GHz)
     - macOS Monterey
     - 8.91 seconds
   * - Apple A14 Bionic
     - iOS 15
     - 2.80 seconds
   * - Apple A9
     - iOS 13
     - 42.65 seconds

Size 12
*******

Average novels contain about 90,000 words.

.. list-table:: Statistics
   :header-rows: 1

   * - Bytecode
     - Words
     - Knots
     - Stitches
     - Functions
     - Choices
     - Gathers
     - Diverts
   * - 1.4 MB
     - 91,800
     - 397
     - 360
     - 36
     - 4,080
     - 1,140
     - 2,738

.. list-table:: Performances
   :header-rows: 1

   * - CPU
     - OS
     - Time
   * - AMD Ryzen 7 5800X (3.80 GHz)
     - Windows 11
     - 6.65 seconds
   * - Apple M1 (3.20 GHz)
     - macOS Monterey
     - 4.42 seconds
   * - Intel i5-6267U (2.90 GHz)
     - macOS Monterey
     - 17.64 seconds
   * - Apple A14 Bionic
     - iOS 15
     - 6.10 seconds
   * - Apple A9
     - iOS 13
     - 1 minute 44 seconds

Alternatives to *inkgd*
-----------------------

If *inkgd* proves too slow for you needs, the only other option is to migrate
to Godot Mono and use the official C# implementation through `godot-ink`_.

.. _`godot-ink`: https://github.com/paulloz/godot-ink
