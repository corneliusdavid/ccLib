unit uConfigRegPersist;

// MIT License
//
// Copyright (c) 2009 - Robert Love
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE
//

(*
 * Modified by Cornelius Concepts to use the registry instead of an INI file
 *)

{$TYPEINFO ON}

interface

uses
  SysUtils, Classes, Rtti, TypInfo, Registry, Winapi.Windows;

type
  {$REGION 'XMLDoc'}
  ///	<summary>
  ///	  An Attribute class that can be applied to a member of an object so that
  ///	  when the object is passed to the Load or Save methods of a persist class,
  ///	  the member will be loaded or saved.
  ///	</summary>
  {$ENDREGION}
  ConfigValueAttribute = class(TCustomAttribute)
  private
    FName: string;
    FDefaultValue: string;
  published
     {$REGION 'XMLDoc'}
     ///	<summary>
     ///	  The Constructor of ConfigValueAttribute simply establishes the name and optionally a default value of the member.
     ///	</summary>
     ///	<param name="AName">
     ///	  <c>String. Required.</c> Is used as the name of the config setting.
     ///	</param>
     ///	<param name="ADefaultValue">
     ///	  <c>String. Optional.</c> Is used as the default value of the named config setting.
     ///	</param>
     {$ENDREGION}
     constructor Create(const AName: string;
                        const ADefaultValue: string = '');
     {$REGION 'XMLDoc'}
     ///	<summary>
     ///	  This is the Name of the config setting.
     ///	</summary>
     {$ENDREGION}
     property Name : string read FName write FName;
     {$REGION 'XMLDoc'}
     ///	<summary>
     ///	  This is the default value of named config setting if the value is not found when read.
     ///	</summary>
     {$ENDREGION}
     property DefaultValue : string read FDefaultValue write FDefaultValue;
  end;

  {$REGION 'XMLDoc'}
  ///	<summary>
  ///	  An Attribute class that can be applied to a class to automatically give it the Section name
  ///   needed by the persist class.
  ///	</summary>
  ///	<remarks>
  ///   Using this attribute at the class level automatically names the class as the section and the fields as the various named config settings in that section.
  ///   This means you don't have to apply ConfigValueAttribute[s] to each property as it's done for you through this attribute.
  ///	</remarks>
  {$ENDREGION}
  ConfigClassAttribute = class(TCustomAttribute)
  private
    FSectionName: string;
  public
    {$REGION 'XMLDoc'}
    ///	<summary>
    ///	  The constructor simply establishes the one field of the class, the section name.
    ///	</summary>
    ///	<param name="NewIniKey">
    ///	  <c>String. Required.</c> Establishes the [Section] of the .INI file for the class and its properties.
    ///	</param>
    {$ENDREGION}
    constructor Create(const NewSectionName: string);
  published
    {$REGION 'XMLDoc'}
    ///	<summary>
    ///	  The name of the section of config settings for the class
    ///	  saved.
    ///	</summary>
    {$ENDREGION}
    property SectionName: string read FSectionName write FSectionName;
  end;

  {$REGION 'XMLDoc'}
  ///	<summary>
  ///	  When an ConfigClassAttribute is in use for a class, this attribute class
  ///	  will exclude a member from the config settings.
  ///	</summary>
  ///	<remarks>
  ///	  This class is intended to be used only in conjunction with
  ///	  ConfigClassAttribute.
  ///	</remarks>
  {$ENDREGION}
  RegIgnoreAttribute = class(TCustomAttribute);

  {$REGION 'XMLDoc'}
  ///	<summary>
  ///	  When a ConfigClassAttribute is in use for a class, this member-level
  ///	  attribute provides optional default values
  ///	</summary>
  ///	<remarks>
  ///	  Is intended to be used only in conjunction with ConfigClassAttribute.
  ///	</remarks>
  {$ENDREGION}
  RegDefaultAttribute = class(TCustomAttribute)
  private
    FDefaultValue: string;
  public
    {$REGION 'XMLDoc'}
    ///	<summary>
    ///	  The constructor method simply initializes the DefaultValue field.
    ///	</summary>
    ///	<param name="NewDefaultValue">
    ///	  <c>String. Required.</c> This is the new Default Value of the class member to which this attribute is applied.
    ///	</param>
    {$ENDREGION}
    constructor Create(const NewDefaultValue: string);
  published
    {$REGION 'XMLDoc'}
    ///	<summary>
    ///	  This field is used as a default value when a field is not found during a read of the settings.
    ///	</summary>
    {$ENDREGION}
    property DefaultValue: string read FDefaultValue write FDefaultValue;
  end;

  {$REGION 'XMLDoc'}
  ///	<summary>
  ///	  Special exception for use by the persist class.
  ///	</summary>
  ///	<remarks>
  ///	  Simple descendant from the Exception class.
  ///	</remarks>
  {$ENDREGION}
  ERegPersist = class(Exception);

  {$REGION 'XMLDoc'}
  ///	<summary>
  ///	  A class for making reading/saving configuration settings from/to the registry very simple by
  ///	  passing in an object peppered with specific attributes.
  ///	</summary>
  {$ENDREGION}
  TRegPersist = class (TObject)
  private
    class procedure SetValue(aData: string; var aValue: TValue);
    class function GetValue(var aValue: TValue): string;
    class function GetValueAttribute(Obj: TRttiObject): ConfigValueAttribute;
    class function GetPropIgnoreAttribute(Obj: TRttiObject): RegIgnoreAttribute;
    class function GetDefaultAttributeValue(Obj: TRttiObject): string;
    class function GetClassAttribute(ObjTyp: TRttiType): ConfigClassAttribute;
  public
    {$REGION 'XMLDoc'}
    ///	<summary>
    ///	  Load reads the registry and fills the given object with the
    ///	  settings found.
    ///	</summary>
    ///	<param name="obj">
    ///	  The object with attributes applied that will be filled with values read.
    ///	</param>
    ///	<param name="IgnoreBaseProperties">
    ///	  <c>Boolean. Optional.</c>  If the ConfigClassAttribute attribute is applied
    ///	  (which automatically reads all properties), this optional parameter
    ///	  (True by default) will ignore the properties in the base class of
    ///	  the object supplied.  This is useful when using the common
    ///	  TCustomRegSettings class that have properties seldom used in
    ///	  applications.
    ///	</param>
    {$ENDREGION}
    class procedure Load(ARootKey: HKEY; ARootPath: string; obj: TObject; IgnoreBaseProperties: Boolean = True);
    {$REGION 'XMLDoc'}
    ///	<summary>
    ///	  Save writes to the registry using the settings from the given
    ///	  object.
    ///	</summary>
    ///	<param name="obj">
    ///	  The object with attributes applied that contain the values to write.
    ///	</param>
    ///	<param name="IgnoreBaseProperties">
    ///	  <c>Boolean. Optional.</c>  If the ConfigClassAttribute attribute is applied
    ///	  (which automatically writes all properties), this optional parameter
    ///	  (True by default) will ignore the properties in the base class of
    ///	  the object supplied.  This is useful when using the common
    ///	  TCustomRegSettings settings that have properties seldom used in
    ///	  applications.
    ///	</param>
    {$ENDREGION}
    class procedure Save(ARootKey: HKEY; ARootPath: string; obj: TObject; IgnoreBaseProperties: Boolean = True);
  end;


implementation

uses
  {$IFDEF UseCodeSite} CodeSiteLogging, {$ENDIF}
  uConfigBaseReg;

{ ConfigValueAttribute }

constructor ConfigValueAttribute.Create(const AName: string; const ADefaultValue: string);
begin
  {$IFDEF UseCodeSite} CodeSite.EnterMethod(Self, 'Create'); {$ENDIF}
  {$IFDEF UseCodeSite} CodeSite.Send('name', AName); {$ENDIF}
  {$IFDEF UseCodeSite} CodeSite.Send('default', ADefaultValue); {$ENDIF}

  FName := aName;
  FDefaultValue := aDefaultValue;

  {$IFDEF UseCodeSite} CodeSite.ExitMethod(Self, 'Create'); {$ENDIF}
end;

{ TRegPersist }

class function TRegPersist.GetClassAttribute(ObjTyp: TRttiType): ConfigClassAttribute;
{ check to see if the ConfigClassAttribute is assigned }
var
  Attr: TCustomAttribute;
begin
  {$IFDEF UseCodeSite} CodeSite.EnterMethod('TRegPersist.GetClassAttribute'); {$ENDIF}

  Result := nil;

  for Attr in ObjTyp.GetAttributes do
    if Attr is ConfigClassAttribute then begin
      Result := ConfigClassAttribute(Attr);
      Break;
    end;

  {$IFDEF UseCodeSite} CodeSite.ExitMethod('TRegPersist.GetClassAttribute'); {$ENDIF}
end;

class function TRegPersist.GetDefaultAttributeValue(Obj: TRttiObject): string;
{ check to see if the RegDefaultAttribute is assigned; if so, return the default string }
var
  Attr: TCustomAttribute;
begin
  {$IFDEF UseCodeSite} CodeSite.EnterMethod('TRegPersist.GetDefaultAttributeValue'); {$ENDIF}

  Result := EmptyStr;

  for Attr in Obj.GetAttributes do
    if Attr is RegDefaultAttribute then begin
      Result := RegDefaultAttribute(Attr).DefaultValue;
      Break;
    end;

  {$IFDEF UseCodeSite} CodeSite.Send('Result', Result); {$ENDIF}
  {$IFDEF UseCodeSite} CodeSite.ExitMethod('TRegPersist.GetDefaultAttributeValue'); {$ENDIF}
end;

class function TRegPersist.GetValueAttribute(Obj: TRttiObject): ConfigValueAttribute;
{ check to see if the ConfigValueAttribute is assigned }
var
  Attr: TCustomAttribute;
begin
  {$IFDEF UseCodeSite} CodeSite.EnterMethod('TRegPersist.GetValueAttribute'); {$ENDIF}

  Result := nil;

  for Attr in Obj.GetAttributes do
    if Attr is ConfigValueAttribute then begin
      Result := ConfigValueAttribute(Attr);
      Break;
    end;

  {$IFDEF UseCodeSite}
  if Assigned(Result) then
    CodeSite.Send('attribute.name', Result.Name);
  {$ENDIF}
  {$IFDEF UseCodeSite} CodeSite.ExitMethod('TRegPersist.GetValueAttribute'); {$ENDIF}
end;

class function TRegPersist.GetPropIgnoreAttribute(Obj: TRttiObject): RegIgnoreAttribute;
{ check to see if the RegIgnoreAttribute is assigned }
var
  Attr: TCustomAttribute;
begin
  {$IFDEF UseCodeSite} CodeSite.EnterMethod('TRegPersist.GetPropIgnoreAttribute'); {$ENDIF}

  Result := nil;

  for Attr in Obj.GetAttributes do
    if Attr is RegIgnoreAttribute then begin
      Result := RegIgnoreAttribute(Attr);
      Break;
    end;

  {$IFDEF UseCodeSite}
  if Assigned(Result) then
    CodeSite.Send('ignore attribute found');
  {$ENDIF}
  {$IFDEF UseCodeSite} CodeSite.ExitMethod('TRegPersist.GetPropIgnoreAttribute'); {$ENDIF}
end;

class procedure TRegPersist.Load(ARootKey: HKEY; ARootPath: string; obj: TObject; IgnoreBaseProperties: Boolean = True);
var
  ctx: TRttiContext;
  objType: TRttiType;
  Prop: TRttiProperty;
  PropClass: TClass;
  Value: TValue;
  PropValueAttr: ConfigValueAttribute;
  RegClass: ConfigClassAttribute;
  PropIgnoreAttr: RegIgnoreAttribute;
  Reg: TRegistry;
  Data: String;

  RegClassSection: string;
  PropDefaultAttr: string;
begin
  {$IFDEF UseCodeSite} CodeSite.EnterMethod('TRegPersist.Load');  {$ENDIF}
  {$IFDEF UseCodeSite} CodeSite.Send('root path', ARootPath); {$ENDIF}

  ctx := TRttiContext.Create;
  try
    Reg := TRegistry.Create;
    try
      Reg.RootKey := ARootKey;
      Reg.OpenKey(ARootPath, False);
      {$IFDEF UseCodeSite} CodeSite.Send('registry opened to root path', ARootPath);  {$ENDIF}

      objType := ctx.GetType(Obj.ClassInfo);

      {$REGION 'get the "section" from either the class or the Section property in the object'}
      // is this class using the "class-level" keys?
      RegClass := GetClassAttribute(ObjType);
      if Assigned(RegClass) then begin
        // if using class-level keys, this is the KEY for the class and the properties define themselves as Value Names
        RegClassSection := RegClass.SectionName;
        {$IFDEF UseCodeSite} CodeSite.Send('using class level [section] for ' + Obj.ClassName, RegClassSection); {$ENDIF}
      end else
        RegClassSection := (Obj as TCustomRegSettings).Section;
      {$ENDREGION}

      Reg.OpenKey(RegClassSection, False);
      {$IFDEF UseCodeSite} CodeSite.Send('opened section', RegClassSection); {$ENDIF}

      // look at all the properties of the object
      for Prop in objType.GetProperties do begin
        // get the class to which the current property belongs
        PropClass := TRttiInstanceType(Prop.Parent).MetaclassType;

        // always ignore TInterfacedObject properties
        if PropClass <> TInterfacedObject then begin
          // optionally ignore TCustomSettings properties
          if IgnoreBaseProperties and (PropClass = TCustomRegSettings) then begin
            {$IFDEF UseCodeSite} CodeSite.Send(csmLevel1, 'ignoring base property', Prop.Name); {$ENDIF}
          end else begin
            // look at each of the properties
            {$IFDEF UseCodeSite} CodeSite.Send(csmLevel1, 'checking property', Prop.Name); {$ENDIF}
            Data := EmptyStr;

            {$REGION 'read the value for the property from the registry'}
            // if class-level keys are in use then these will override the class-level settings
            PropValueAttr := GetValueAttribute(Prop);
            if Assigned(PropValueAttr) then begin
              if Reg.ValueExists(PropValueAttr.Name) then
                Data := Reg.ReadString(PropValueAttr.Name)
              else
                Data := PropValueAttr.DefaultValue;
              {$IFDEF UseCodeSite} CodeSite.Send('property-specific data', Data); {$ENDIF}
            end else begin
              // if using class-level keys, check to see if this property is ignored in the INI file
              PropIgnoreAttr := GetPropIgnoreAttribute(Prop);
              if not Assigned(PropIgnoreAttr) then begin
                // not ignored, check to see if there's a default value
                PropDefaultAttr := GetDefaultAttributeValue(Prop);

                // finally, read the data using the property name as the value name
                if Reg.ValueExists(Prop.Name) then
                  Data := Reg.ReadString(Prop.Name)
                else
                  Data := PropDefaultAttr;
                {$IFDEF UseCodeSite} CodeSite.Send('class-level data', Data); {$ENDIF}
              end;
            end;
            {$ENDREGION}

            {$REGION 'assign the value to the property in the object'}
            // whichever way we read in the data, if it's available, we can now assign it
            if Length(Data) > 0 then begin
              {$IFDEF UseCodeSite} CodeSite.Send(csmLevel2, 'data read from registry', Data); {$ENDIF}
              // just before assigning, get the value from the object into a Value var
              Value := Prop.GetValue(Obj);
              // set the new value into the Value var
              SetValue(Data, Value);
              // and finally, write the Value into the object
              if prop.IsWritable then
                prop.SetValue(Obj, Value);
            end;
            {$ENDREGION}
          end;
        end;
      end;

    finally
      Reg.Free;
    end;
  finally
    ctx.Free;
  end;

  {$IFDEF UseCodeSite} CodeSite.ExitMethod('TRegPersist.Load'); {$ENDIF}
end;

class procedure TRegPersist.SetValue(aData: String; var aValue: TValue);
var
  I: Integer;
  x: Double;
begin
  case aValue.Kind of
    tkWChar, tkLString, tkWString, tkString, tkChar, tkUString:
      aValue := aData;
    tkInteger, tkInt64: begin
      if not TryStrToInt(aData, i) then
        i := 0;
      aValue := i;
    end;
    tkFloat: begin
      if not TryStrToFloat(aData, x) then
        x := 0.0;
      aValue := x;
    end;
    tkEnumeration:
      aValue := TValue.FromOrdinal(aValue.TypeInfo,GetEnumValue(aValue.TypeInfo,aData));
    tkSet: begin
      i :=  StringToSet(aValue.TypeInfo,aData);
      TValue.Make(@i, aValue.TypeInfo, aValue);
    end;
  else
    raise ERegPersist.Create('SetValue - Type not supported');
  end;
end;

class procedure TRegPersist.Save(ARootKey: HKEY; ARootPath: string; obj: TObject; IgnoreBaseProperties: Boolean = True);
var
  ctx: TRttiContext;
  objType: TRttiType;
  Prop: TRttiProperty;
  PropClass: TClass;
  Value: TValue;
  PropValueAttr: ConfigValueAttribute;
  RegClass: ConfigClassAttribute;
  PropIgnoreAttr: RegIgnoreAttribute;
  Reg: TRegistry;
  Data: String;

  RegClassSection: string;
begin
  {$IFDEF UseCodeSite} CodeSite.EnterMethod('TRegPersist.Save'); {$ENDIF}
  {$IFDEF UseCodeSite} CodeSite.Send('root path', ARootPath); {$ENDIF}

  ctx := TRttiContext.Create;
  try
    Reg := TRegistry.Create;
    try
      Reg.RootKey := ARootKey;
      Reg.OpenKey(ARootPath, True);
      {$IFDEF UseCodeSite} CodeSite.Send('registry opened to root path', ARootPath);  {$ENDIF}

      objType := ctx.GetType(Obj.ClassInfo);

      {$REGION 'get the "section" from either the class or the Section property in the object'}
      // is this class using the "class-level" keys?
      RegClass := GetClassAttribute(ObjType);
      if Assigned(RegClass) then begin
        // if using class-level keys, this is the KEY for the class and the properties define themselves as Value Names
        RegClassSection := RegClass.SectionName;
        {$IFDEF UseCodeSite} CodeSite.Send('using class level [section] for ' + Obj.ClassName, RegClassSection); {$ENDIF}
      end else
        RegClassSection := (Obj as TCustomRegSettings).Section;
      {$ENDREGION}

      Reg.OpenKey(RegClassSection, True);
      {$IFDEF UseCodeSite} CodeSite.Send('opened section', RegClassSection); {$ENDIF}

      // look at all the properties of the object
      for Prop in objType.GetProperties do begin
        // get the class to which the current property belongs
        PropClass := TRttiInstanceType(Prop.Parent).MetaclassType;

        // always ignore TInterfacedObject properties
        if (PropClass <> TInterfacedObject) { and (PropClass <> TCustomSettings) } then begin
          // optionally ignore TCustomSettings properties
          if IgnoreBaseProperties and (PropClass = TCustomRegSettings) then begin
            {$IFDEF UseCodeSite} CodeSite.Send(csmLevel1, 'ignoring base property', Prop.Name); {$ENDIF}
          end else begin
            {$IFDEF UseCodeSite} CodeSite.Send(csmLevel1, 'checking property', Prop.Name); {$ENDIF}
            // get the value to be saved
            Value := Prop.GetValue(Obj);
            Data := GetValue(Value);

            {$REGION 'write the value for the property to the registry'}
            // if class-level keys are in use then these will override the class-level settings
            PropValueAttr := GetValueAttribute(Prop);
            if Assigned(PropValueAttr) then begin
              {$IFDEF UseCodeSite} CodeSite.Send('data to write', data); {$ENDIF}
              {$IFDEF UseCodeSite} CodeSite.Send('RegValue.Name', PropValueAttr.Name); {$ENDIF}
              Reg.WriteString(PropValueAttr.Name, Data);
              {$IFDEF UseCodeSite} CodeSite.Send(csmLevel2, 'data written to registry', Data); {$ENDIF}
            end else begin
              // if not using RegValue for the properties, check to see if this property is ignored
              PropIgnoreAttr := GetPropIgnoreAttribute(Prop);
              if Assigned(PropIgnoreAttr) then begin
                {$IFDEF UseCodeSite} CodeSite.Send('ignoring...'); {$ENDIF}
              end else begin
                // not ignored and the RegClassSection is set, write out the data using property name as value name
                Reg.WriteString(Prop.Name, Data);
                {$IFDEF UseCodeSite} CodeSite.Send(csmLevel2, 'data written to registry', Data); {$ENDIF}
              end;
            end;
            {$ENDREGION}
          end;
        end;
      end;
    finally
      Reg.Free;
    end;
  finally
    ctx.Free;
  end;

  {$IFDEF UseCodeSite} CodeSite.ExitMethod('TRegPersist.Save');  {$ENDIF}
end;

class function TRegPersist.GetValue(var aValue: TValue) : string;
begin
  {$IFDEF UseCodeSite} CodeSite.EnterMethod( 'TRegPersist.GetValue'); {$ENDIF}
  {$IFDEF UseCodeSite} CodeSite.Send('aValue', aValue.ToString); {$ENDIF}

  if aValue.Kind in [tkWChar, tkLString, tkWString, tkString, tkChar, tkUString,
                     tkInteger, tkInt64, tkFloat, tkEnumeration, tkSet] then
    result := aValue.ToString
  else
    raise ERegPersist.Create('GetValue - Type not supported');

  {$IFDEF UseCodeSite} CodeSite.Send('Result', Result); {$ENDIF}
  {$IFDEF UseCodeSite} CodeSite.ExitMethod('TRegPersist.GetValue'); {$ENDIF}
end;

{ ConfigClassAttribute }

constructor ConfigClassAttribute.Create(const NewSectionName: string);
begin
  {$IFDEF UseCodeSite} CodeSite.EnterMethod(Self, 'Create'); {$ENDIF}
  {$IFDEF UseCodeSite} CodeSite.Send('new section name', NewSectionName); {$ENDIF}

  FSectionName := NewSectionName;

  {$IFDEF UseCodeSite} CodeSite.ExitMethod(Self, 'Create'); {$ENDIF}
end;

{ RegDefaultAttribute }

constructor RegDefaultAttribute.Create(const NewDefaultValue: string);
begin
  {$IFDEF UseCodeSite} CodeSite.EnterMethod(Self, 'Create'); {$ENDIF}
  {$IFDEF UseCodeSite} CodeSite.Send('new default value', NewDefaultValue); {$ENDIF}

  FDefaultValue := NewDefaultValue;

  {$IFDEF UseCodeSite} CodeSite.ExitMethod(Self, 'Create'); {$ENDIF}
end;

end.

