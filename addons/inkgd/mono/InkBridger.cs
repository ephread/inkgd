// /////////////////////////////////////////////////////////////////////////// /
// Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
// Licensed under the MIT License.
// See LICENSE in the project root for license information.
// /////////////////////////////////////////////////////////////////////////// /

using Godot;
using System;
using System.Linq;
using System.Collections.Generic;
using Ink;

public partial class InkBridger : Node
{
	#region Imports
	private readonly GDScript InkChoice =
		(GDScript) ResourceLoader.Load("res://addons/inkgd/runtime/content/choices/ink_choice.gd");

	private readonly GDScript InkPath =
		(GDScript) ResourceLoader.Load("res://addons/inkgd/runtime/ink_path.gd");

	private readonly GDScript InkList =
		(GDScript) ResourceLoader.Load("res://addons/inkgd/runtime/lists/ink_list.gd");

	private readonly GDScript InkListDefinition =
		(GDScript) ResourceLoader.Load("res://addons/inkgd/runtime/lists/ink_list_definition.gd");

	private readonly GDScript InkListItem =
		(GDScript) ResourceLoader.Load("res://addons/inkgd/runtime/lists/structs/ink_list_item.gd");

	private readonly GDScript InkFunctionResult =
		(GDScript) ResourceLoader.Load("res://addons/inkgd/runtime/extra/ink_function_result.gd");
	#endregion

	#region Methods | Helpers
	public bool IsInkObjectOfType(GodotObject inkObject, string name)
	{
		return inkObject.HasMethod("is_ink_class") && (bool)inkObject.Call("is_ink_class", new Variant[] { name });
	}

	public GodotObject MakeFunctionResult(string textOutput, object returnValue)
	{
		var parameters = new Variant[] { textOutput ?? "", MakeGDVariant(returnValue) };
		return (GodotObject) InkFunctionResult.New(parameters);
	}

	public Variant[] MakeGDVariantArray(object[] values) {
		Variant[] gdValues = new Variant[values.Length];

		for(int i = 0; i < values.Length; i++) {
			gdValues[i] = MakeGDVariant(values[i]);
		}

		return gdValues;
	}

	public Godot.Collections.Array<Variant> MakeGDVariantCollection(object[] values) {
		Godot.Collections.Array<Variant> gdValues = new Godot.Collections.Array<Variant>();

		foreach(object value in values) {
			gdValues.Add(MakeGDVariant(value));
		}

		return gdValues;
	}

	public Variant MakeGDVariant(object value)
	{
		if (value is string gdStringValue) {
			return Variant.CreateFrom(gdStringValue);
		}

		if (value is bool gdBoolValue) {
			return Variant.CreateFrom(gdBoolValue);
		}

		if (value is int gdIntValue) {
			return Variant.CreateFrom(gdIntValue);
		}

		if (value is float gdFloatValue) {
			return Variant.CreateFrom(gdFloatValue);
		}

		if (value is double gdDoubleValue) {
			return Variant.CreateFrom(gdDoubleValue);
		}

		if (value is Ink.Runtime.Path gdPathValue) {
			return MakeGDInkPath(gdPathValue);
		}

		if (value is Ink.Runtime.InkList gdListValue) {
			return MakeGDInkList(gdListValue);
		}

		if (value is Godot.Collections.Array<Variant> gdArrayValue) {
			return gdArrayValue;
		}

		if (value == null) {
			return new Variant();
		}

		throw new ArgumentException(String.Format("{0} arguments are not supported.", value.GetType().FullName));
	}
	#endregion

	#region Methods | Conversion -> (GDScript -> C#)
	public GodotObject MakeGDInkPath(Ink.Runtime.Path path) {
		if (path == null) { return null; }

		var inkPath = (GodotObject) InkPath.New();
		inkPath.Call("_init_with_components_string", path.componentsString);
		return inkPath;
	}

	public GodotObject MakeGDInkChoice(Ink.Runtime.Choice choice) {
		var inkChoice = (GodotObject) InkChoice.New();

		Variant[] inkChoiceParams = new Variant[] {
			choice.text,
			choice.sourcePath,
			choice.index,
			MakeGDInkPath(choice.targetPath),
			choice.isInvisibleDefault,
			choice.tags != null ? new Godot.Collections.Array<string>(choice.tags) : null
		};

		inkChoice.Call("_init_from_csharp", inkChoiceParams);
		return inkChoice;
	}

	public GodotObject MakeGDInkList(Ink.Runtime.InkList list)
	{
		var inkListBase = new Godot.Collections.Dictionary<string, int>();

		foreach(KeyValuePair<Ink.Runtime.InkListItem, int> kv in list) {
			inkListBase.Add(MakeGDInkListItem(kv.Key).Call("serialized").As<string>(), kv.Value);
		}

		Variant[] inkListParams = new Variant[] {
			inkListBase,
			list.originNames.ToArray(),
			MakeGDInkListOrigins(list.origins)
		};

		var inkList = (GodotObject) InkList.New();
		inkList.Call("_init_from_csharp", inkListParams);

		return inkList;
	}

	public Variant MakeGDErrorType(Ink.ErrorType type) {
		switch(type) {
			case ErrorType.Author: return 0;
			case ErrorType.Warning: return 1;
			case ErrorType.Error: return 2;
			default: return 1;
		}
	}
	#endregion

	#region Methods | Conversion (GDScript -> C#)
	public Ink.Runtime.Path MakeSharpInkPath(GodotObject path) {
		if (!IsInkObjectOfType(path, "InkPath"))
		{
			throw new ArgumentException("Expected a 'ObGodotObjectof class 'InkPath'");
		}

		return new Ink.Runtime.Path((string)path.Get("components_string"));
	}

	public Ink.Runtime.InkList MakeSharpInkList(GodotObject list, Ink.Runtime.Story story)
	{
		if (!IsInkObjectOfType(list, "InkList"))
		{
			throw new ArgumentException("Expected a 'ObGodotObjectof class 'InkList'");
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

	public object MakeSharpObject(Variant variant, Ink.Runtime.Story story)
	{
		if (variant.VariantType == Variant.Type.Nil) {
			return null;
		}

		if (variant.VariantType == Variant.Type.String) {
			return variant.As<string>();
		}

		if (variant.VariantType == Variant.Type.Bool) {
			return variant.As<bool>();
		}

		if (variant.VariantType == Variant.Type.Int) {
			return variant.As<int>();
		}

		if (variant.VariantType == Variant.Type.Float) {
			return variant.As<double>();
		}

		if (variant.VariantType == Variant.Type.Object) {
			var godotObject = variant.As<GodotObject>();

			if (IsInkObjectOfType(godotObject, "InkPath")) {
				return MakeSharpInkPath(godotObject);
			}

			if (IsInkObjectOfType(godotObject, "InkList")) {
				return MakeSharpInkList(godotObject, story);
			}
		}

		if (variant.VariantType == Variant.Type.Array) {
			var godotArray = variant.AsGodotArray<Variant>();

			object[] objects = new object[godotArray.Count];
			for (int i = 0; i < godotArray.Count; i++)
			{
				objects[i] = MakeSharpObject(godotArray[i], story);
			}
		}

		throw new ArgumentException(String.Format("Variant of type ({0}) are not supported.", variant.VariantType));
	}
	#endregion

	#region Private Methods | Conversion (C# -> GDScript)
	private Godot.Collections.Array<GodotObject> MakeGDInkListOrigins(
		List<Ink.Runtime.ListDefinition> listDefinitions)
	{
		var inkListDefinitions = new Godot.Collections.Array<GodotObject>();

		foreach(Ink.Runtime.ListDefinition listDefinition in listDefinitions) {
			var inkListDefinition = MakeGDListDefinition(listDefinition);
			inkListDefinitions.Add(inkListDefinition);
		}

		return inkListDefinitions;
	}

	private GodotObject MakeGDListDefinition(Ink.Runtime.ListDefinition listDefinition)
	{
		var items = new Godot.Collections.Dictionary<GodotObject, int>();

		foreach(KeyValuePair<Ink.Runtime.InkListItem, int> kv in listDefinition.items) {
			var inkListItem = MakeGDInkListItem(kv.Key);
			items.Add(inkListItem, kv.Value);
		}

		var definitionParams = new Variant[] { listDefinition.name, items };
		var inkListDefinition = (GodotObject) InkListDefinition.New(definitionParams);

		return inkListDefinition;
	}

	private GodotObject MakeGDInkListItem(Ink.Runtime.InkListItem listItem)
	{
		Variant[] itemParams = new Variant[] { listItem.fullName };

		var inkListItem = (GodotObject) InkListItem.New();
		inkListItem.Call("_init_with_full_name", itemParams);

		return inkListItem;
	}
	#endregion

	#region Private Methods | Conversion (GDScript -> C#)
	private Ink.Runtime.InkListItem MakeSharpInkListItem(string listItemKey)
	{

		var listItem = (GodotObject) InkListItem.Call("from_serialized_key", new Variant[] { listItemKey });

		if (!IsInkObjectOfType(listItem, "InkListItem")) {
			throw new ArgumentException("Expected a 'ObGodotObjectof class 'InkListItem'");
		}

		return new Ink.Runtime.InkListItem(
			listItem.Get("origin_name").As<string>(),
			listItem.Get("item_name").As<string>()
		);
	}
	#endregion
}
