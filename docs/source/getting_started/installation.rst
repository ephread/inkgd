Installation
============

Asset Library Installation
**************************

Open a Godot project, click on the to *AssetLib* tab, at the top of the screen,
then search for *inkgd*.

.. image:: img/introduction/asset_lib.png
    :align: center
    :alt: The AssetLib tab, inside Godot.

|

Select *inkgd* from author *ephread*.

.. image:: img/introduction/asset_lib_inkgd.png
    :align: center
    :alt: The AssetLib tab, showing an "inkgd" item.

|

In the popup window, click on *Download*.

.. image:: img/introduction/asset_lib_download.png
    :align: center
    :alt: An "inkgd" popup window, with the download button emphasized.

|

Once the plugin is downloaded, another window will pop up. This window displays
the new file expected to be added to the project. By default, all files should
selected. If this isn't the case, select all the files, then click on *Install*.

.. image:: img/introduction/asset_lib_file_section.png
    :align: center
    :alt: Pop up window displaying the file hierarchy of inkgd.

|

After the installation is completed, a confimation dialog should pop up.
Click on *OK* to close it.

.. image:: img/introduction/asset_lib_successful_installation.png
    :align: center
    :alt: Dialog confirming a successful installation of inkgd.

|

The new files should appear in the FileSystem dock, under the *addons* folder.

.. image:: img/introduction/file_system_dock.png
    :align: center
    :alt: FileSystem dock, containing "inkgd" under the "addons" folder.
    :scale: 50 %

|

*inkgd* also comes with an editor plugin to manage Ink stories. The plugin
should be enabled by default, but it can be disabled from the project settings.
(*Project > Project Settings > Plugins*).

.. image:: img/introduction/project_settings_plugin_tab.png
    :align: center
    :alt: inkgd's entry in the "Plugins" tab of the project settings.

|

The editor plugin is not required to use the runtime. Ink stories can be
compiled through ``inklecate`` directly or other editors, such as
Inky_. The resulting ``.ink.json`` file can be loaded in the project manually.

.. _Inky: https://github.com/inkle/inky/releases

.. warning::

    If you do not enable the plugin, you will not be able to import JSON files
    as Ink resources. Make sure to include a filter rule in the export settings
    to prevent JSON files from being discarded during export.

Manual Installation
*******************

Use Git to clone this repository:

.. code-block:: console

    $ git clone https://github.com/ephread/inkgd.git

Or download the latest `stable version`_ of *inkgd*, then extract the content
of the archive.

Once you have the content of the repository on your computer, copy the folder
``addons/inkgd`` to ``res://addons/`` in your project.

.. _`stable version`: https://github.com/ephread/inkgd/tags

----------

Well done, *inkgd* is installed. Next stop, basic configuration!
