// /////////////////////////////////////////////////////////////////////////// /
// Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
// Licensed under the MIT License.
// See LICENSE in the project root for license information.
// /////////////////////////////////////////////////////////////////////////// /

using Godot;
using System;
using System.Linq;
using System.Collections.Generic;
using System.ComponentModel;

public class InkBridger : Node
{
	#region Imports
	private readonly GDScript InkPath =
		(GDScript) ResourceLoader.Load("res://addons/inkgd/runtime/ink_path.gd");

	private readonly GDScript InkList =
		(GDScript) ResourceLoader.Load("res://addons/inkgd/runtime/lists/ink_list.gd");

	private readonly GDScript InkListDefinition =
		(GDScript) ResourceLoader.Load("res://addons/inkgd/runtime/lists/list_definition.gd");

	private readonly GDScript InkListItem =
		(GDScript) ResourceLoader.Load("res://addons/inkgd/runtime/lists/structs/ink_list_item.gd");

	private readonly GDScript InkFunctionResult =
		(GDScript) ResourceLoader.Load("res://addons/inkgd/runtime/extra/function_result.gd");
	#endregion

	#region Methods | Helpers
	public bool IsInkObjectOfType(Godot.Object inkObject, string name)
	{
		return inkObject.HasMethod("is_class") && (bool)inkObject.Call("is_class", new object[] { name });
	}

	public Godot.Object MakeFunctionResult(string textOutput, object returnValue)
	{
		var parameters = new object[] { textOutput ?? "", returnValue };
		return (Godot.Object) InkFunctionResult.New(parameters);
	}
	#endregion

	#region Methods | Conversion -> (GDScript -> C#)
	public Godot.Object MakeGDInkPath(Ink.Runtime.Path path) {
		var inkPath = (Godot.Object) InkPath.New();
		inkPath.Call("_init_with_components_string", path.componentsString);
		return inkPath;
	}

	public Godot.Object MakeGDInkList(Ink.Runtime.InkList list)
	{
		var inkListBase = new Godot.Collections.Dictionary<string, int>();

		foreach(KeyValuePair<Ink.Runtime.InkListItem, int> kv in list) {
			inkListBase.Add(MakeGDInkListItem(kv.Key).Call("serialized") as string, kv.Value);
		}

		object[] inkListParams = new object[] {
			inkListBase,
			list.originNames.ToArray(),
			MakeGDInkListOrigins(list.origins)
		};

		var inkList = (Godot.Object) InkList.New();
		inkList.Call("_init_from_csharp", inkListParams);

		return inkList;
	}

	public Ink.Runtime.Path MakeSharpInkPath(Godot.Object path) {
		if (!IsInkObjectOfType(path, "InkPath"))
		{
			throw new ArgumentException("Expected a 'Godot.Object' of class 'InkPath'");
		}

		return new Ink.Runtime.Path((string)path.Get("components_string"));
	}
	#endregion

	#region Methods | Conversion (GDScript -> C#)
	public Ink.Runtime.InkList MakeSharpInkList(Godot.Object list, Ink.Runtime.Story story)
	{
		if (!IsInkObjectOfType(list, "InkList"))
		{
			throw new ArgumentException("Expected a 'Godot.Object' of class 'InkList'");
		}

		var underlyingDictionary = new Godot.Collections.Dictionary<string, int>(
			(Godot.Collections.Dictionary)list.Get("_dictionary"));

		var originNames = new Godot.Collections.Array<string>(
			(Godot.Collections.Array)list.Get("origin_names"));

		var inkList = new Ink.Runtime.InkList();
		inkList.origins = new List<Ink.Runtime.ListDefinition>();

		inkList.SetInitialOriginNames(originNames.ToList());

		foreach(string originName in originNames)
		{
			if (story.listDefinitions.TryListGetDefinition (originName, out Ink.Runtime.ListDefinition definition))
			{
				if (!inkList.origins.Contains(definition)) {
					inkList.origins.Add(definition);
				}
			}
			else
			{
				throw new Exception (
					$"InkList origin could not be found in story when reconstructing list: {originName}"
				);
			}
		}

		foreach(KeyValuePair<string, int> kv in underlyingDictionary)
		{
			inkList[MakeSharpInkListItem(kv.Key)] = kv.Value;
		}

		return inkList;
	}
	#endregion

	#region Private Methods | Conversion (C# -> GDScript)
	private Godot.Collections.Array<Godot.Object> MakeGDInkListOrigins(
		List<Ink.Runtime.ListDefinition> listDefinitions)
	{
		var inkListDefinitions = new Godot.Collections.Array<Godot.Object>();

		foreach(Ink.Runtime.ListDefinition listDefinition in listDefinitions) {
			var inkListDefinition = MakeGDListDefinition(listDefinition);
			inkListDefinitions.Add(inkListDefinition);
		}

		return inkListDefinitions;
	}

	private Godot.Object MakeGDListDefinition(Ink.Runtime.ListDefinition listDefinition)
	{
		var items = new Godot.Collections.Dictionary<Godot.Object, int>();

		foreach(KeyValuePair<Ink.Runtime.InkListItem, int> kv in listDefinition.items) {
			var inkListItem = MakeGDInkListItem(kv.Key);
			items.Add(inkListItem, kv.Value);
		}

		var definitionParams = new object[] { listDefinition.name, items };
		var inkListDefinition = (Godot.Object) InkListDefinition.New(definitionParams);

		return inkListDefinition;
	}

	private Godot.Object MakeGDInkListItem(Ink.Runtime.InkListItem listItem)
	{
		object[] itemParams = new object[] { listItem.fullName };

		var inkListItem = (Godot.Object) InkListItem.New();
		inkListItem.Call("_init_with_full_name", itemParams);

		return inkListItem;
	}
	#endregion

	#region Private Methods | Conversion (GDScript -> C#)
	private Ink.Runtime.InkListItem MakeSharpInkListItem(string listItemKey)
	{

		var listItem = (Godot.Object) InkListItem.Call("from_serialized_key", new object[] { listItemKey });

		if (!IsInkObjectOfType(listItem, "InkListItem")) {
			throw new ArgumentException("Expected a 'Godot.Object' of class 'InkListItem'");
		}

		return new Ink.Runtime.InkListItem(
			listItem.Get("origin_name") as string,
			listItem.Get("item_name") as string
		);
	}
	#endregion
}
