using Godot;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Xml.Linq;

[Tool]

public class InkCsProjValidator : Reference
{
	public bool is_valid(string xmlContent)
	{
		XElement root = XElement.Parse(xmlContent);
		IEnumerable<XElement> inkElement =
			from element in root.Elements("ItemGroup").Elements("Reference")
			where (string)element.Attribute("Include") == "Ink" && element.Parent.Name == "ItemGroup"
			select element;

		return inkElement.Count() == 1;
	}
}
