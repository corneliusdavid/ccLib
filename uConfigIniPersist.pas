unit uConfigIniPersist;
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
 * Modified by Retail Dimensions, Inc.
 *)

{$TYPEINFO ON}

interface

uses
  SysUtils, Classes, Rtti, TypInfo;

type
  {$REGION 'XMLDoc'}
  ///	<summary>
  ///	  An Attribute class that can be applied to a member of an object so that
  ///	  when the object is passed to the Load or Save methods of TIniPersist,
  ///	  the member will be loaded or saved to/from the .INI file.
  ///	</summary>
  {$ENDREGION}
  ConfigValueAttribute = class(TCustomAttribute)
  private
    FName: string;
    FDefaultValue: string;
  published
     {$REGION 'XMLDoc'}
     ///	<summary>
     ///	  The Constructor of IniValueAttribute simply establishes the field
     ///	  values used by TIniPersist.
     ///	</summary>
     ///	<param name="AName">
     ///	  <c>String. Required.</c> Is used as the Key name in the Name=Value
     ///	  pair in the .INI file.
     ///	</param>
     ///	<param name="ADefaultValue">
     ///	  <c>String. Optional.</c> Is used as the default value of the
     ///	  property is the Name=Value pair is not found in the .INI file.
     ///	</param>
     {$ENDREGION}
     constructor Create(const AName: string;
                        const ADefaultValue: string = '');
     {$REGION 'XMLDoc'}
     ///	<summary>
     ///	  This is the Name part of a Name=Value line in the .INI file.
     ///	</summary>
     {$ENDREGION}
     property Name : string read FName write FName;
     {$REGION 'XMLDoc'}
     ///	<summary>
     ///	  This is the default value of a Name=Value line of the .INI file.
     ///	</summary>
     {$ENDREGION}
     property DefaultValue : string read FDefaultValue write FDefaultValue;
  end;

  // allows one [Key] to be defined for the entire class; then the property names become the Value Names
  ConfigClassAttribute = class(TCustomAttribute)
  private
    FSectionName: string;
  public
    {$REGION 'XMLDoc'}
    ///	<summary>
    ///	  The constructor simply establishes the one field of the class.
    ///	</summary>
    ///	<param name="NewIniKey">
    ///	  <c>String. Required.</c> Establishes the [Section] of the .INI file for the class and its properties.
    ///	</param>
    {$ENDREGION}
    constructor Create(const NewSectionName: string);
  published
    {$REGION 'XMLDoc'}
    ///	<summary>
    ///	  The name of the [Section] in the .INI key for which this class is
    ///	  saved.
    ///	</summary>
    ///	<remarks>
    ///	  The property name should probably have been IniSection instead of
    ///	  IniKey.
    ///	</remarks>
    {$ENDREGION}
    property SectionName: string read FSectionName write FSectionName;
  end;

  {$REGION 'XMLDoc'}
  ///	<summary>
  ///	  When an IniClassAttribute is in use for a class, this attribute class
  ///	  will exclude a member from the INI file.
  ///	</summary>
  ///	<remarks>
  ///	  This class is intended to be used only in conjunction with
  ///	  IniClassAttribute.
  ///	</remarks>
  {$ENDREGION}
  IniIgnoreAttribute = class(TCustomAttribute);

  {$REGION 'XMLDoc'}
  ///	<summary>
  ///	  When an IniClassAttribute is in use for a class, this member-level
  ///	  attribute class provides optional INI value defaults
  ///	</summary>
  ///	<remarks>
  ///	  Is intended to be used only in conjunction with IniClassAttribute.
  ///	</remarks>
  {$ENDREGION}
  IniDefaultAttribute = class(TCustomAttribute)
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
    ///	  This field is used as a default value when reading a class member
    ///	  from an .Ini file.
    ///	</summary>
    {$ENDREGION}
    property DefaultValue: string read FDefaultValue write FDefaultValue;
  end;

  {$REGION 'XMLDoc'}
  ///	<summary>
  ///	  Special exception for use by the IniPersist class.
  ///	</summary>
  ///	<remarks>
  ///	  Simple descendant from the Exception class.
  ///	</remarks>
  {$ENDREGION}
  EIniPersist = class(Exception);

  {$REGION 'XMLDoc'}
  ///	<summary>
  ///	  A class for making reading/saving configuration settings very simple by
  ///	  passing in an object peppered with specific attributes.
  ///	</summary>
  {$ENDREGION}
  TIniPersist = class (TObject)
  private
    class procedure SetValue(aData: string; var aValue: TValue);
    class function GetValue(var aValue: TValue): string;
    class function GetValueAttribute(Obj: TRttiObject): ConfigValueAttribute;
    class function GetPropIgnoreAttribute(Obj: TRttiObject): IniIgnoreAttribute;
    class function GetDefaultAttributeValue(Obj: TRttiObject): string;
    class function GetClassAttribute(ObjTyp: TRttiType): ConfigClassAttribute;
  public
    {$REGION 'XMLDoc'}
    ///	<summary>
    ///	  Load reads a configuration file and fills the given object with the
    ///	  settings found.
    ///	</summary>
    ///	<param name="FileName">
    ///	  <c>String. Required.</c> The name of the .INI file to read from.
    ///	</param>
    ///	<param name="obj">
    ///	  The object with attributes applied that will be filled with the
    ///	  values read.
    ///	</param>
    ///	<param name="IgnoreBaseProperties">
    ///	  <c>Boolean. Optional.</c>  If the IniClass attribute is applied
    ///	  (which automatically reads all properties), this optional parameter
    ///	  (False by default) will ignore the properties in the base class of
    ///	  the object supplied.  This is useful when using the common
    ///	  TCustomSettings settings that have properties seldom used in
    ///	  applications.
    ///	</param>
    {$ENDREGION}
    class procedure Load(FileName: string; obj: TObject; IgnoreBaseProperties: Boolean = True);
    {$REGION 'XMLDoc'}
    ///	<summary>
    ///	  Save writes a configuration file using the settings from the given
    ///	  object.
    ///	</summary>
    ///	<param name="FileName">
    ///	  <c>String. Required.</c> The name of the .INI file to write.
    ///	</param>
    ///	<param name="obj">
    ///	  The object with attributes applied that contain the values to write.
    ///	</param>
    ///	<param name="IgnoreBaseProperties">
    ///	  <c>Boolean. Optional.</c>  If the IniClass attribute is applied
    ///	  (which automatically writes all properties), this optional parameter
    ///	  (False by default) will ignore the properties in the base class of
    ///	  the object supplied.  This is useful when using the common
    ///	  TCustomSettings settings that have properties seldom used in
    ///	  applications.
    ///	</param>
    {$ENDREGION}
    class procedure Save(FileName: string; obj: TObject; IgnoreBaseProperties: Boolean = True);
  end;


implementation

uses
  {$IFDEF UseCodeSite} CodeSiteLogging, {$ENDIF}
  IniFiles, uConfigBaseIni;

{ ConfigValueAttribute. }

constructor ConfigValueAttribute.Create(const AName: string; const ADefaultValue: string);
begin
  {$IFDEF UseCodeSite} CodeSite.EnterMethod(Self, 'Create'); {$ENDIF}
  {$IFDEF UseCodeSite} CodeSite.Send('name', AName); {$ENDIF}
  {$IFDEF UseCodeSite} CodeSite.Send('default', ADefaultValue); {$ENDIF}

  FName := aName;
  FDefaultValue := aDefaultValue;

  {$IFDEF UseCodeSite} CodeSite.ExitMethod(Self, 'Create'); {$ENDIF}
end;

{ TIniPersist }

class function TIniPersist.GetClassAttribute(ObjTyp: TRttiType): ConfigClassAttribute;
{ check to see if the IniClassAttribute is assigned }
var
  Attr: TCustomAttribute;
begin
  {$IFDEF UseCodeSite} CodeSite.EnterMethod('TIniPersist.GetClassAttribute'); {$ENDIF}

  Result := nil;

  for Attr in ObjTyp.GetAttributes do
    if Attr is ConfigClassAttribute then begin
      Result := ConfigClassAttribute(Attr);
      Break;
    end;

  {$IFDEF UseCodeSite} CodeSite.ExitMethod('TIniPersist.GetClassAttribute'); {$ENDIF}
end;

class function TIniPersist.GetDefaultAttributeValue(Obj: TRttiObject): string;
{ check to see if the IniDefaultAttribute is assigned; if so, return the default string }
var
  Attr: TCustomAttribute;
begin
  {$IFDEF UseCodeSite} CodeSite.EnterMethod('TIniPersist.GetDefaultAttributeValue'); {$ENDIF}

  Result := EmptyStr;

  for Attr in Obj.GetAttributes do
    if Attr is IniDefaultAttribute then begin
      Result := IniDefaultAttribute(Attr).DefaultValue;
      Break;
    end;

  {$IFDEF UseCodeSite} CodeSite.Send('Result', Result); {$ENDIF}
  {$IFDEF UseCodeSite} CodeSite.ExitMethod('TIniPersist.GetDefaultAttributeValue'); {$ENDIF}
end;

class function TIniPersist.GetValueAttribute(Obj: TRttiObject): ConfigValueAttribute;
{ check to see if the IniValueAttribute is assigned }
var
  Attr: TCustomAttribute;
begin
  {$IFDEF UseCodeSite} CodeSite.EnterMethod('TIniPersist.ConfigValueAttribute '); {$ENDIF}

  Result := nil;

  for Attr in Obj.GetAttributes do
    if Attr is ConfigValueAttribute then begin
      Result := ConfigValueAttribute (Attr);
      Break;
    end;

  {$IFDEF UseCodeSite}
  if Assigned(Result) then
    CodeSite.Send('attribute.name', Result.Name);
  {$ENDIF}
  {$IFDEF UseCodeSite} CodeSite.ExitMethod('TIniPersist.ConfigValueAttribute '); {$ENDIF}
end;

class function TIniPersist.GetPropIgnoreAttribute(Obj: TRttiObject): IniIgnoreAttribute;
{ check to see if the IniIgnoreAttribute is assigned }
var
  Attr: TCustomAttribute;
begin
  {$IFDEF UseCodeSite} CodeSite.EnterMethod('TIniPersist.GetPropIgnoreAttribute'); {$ENDIF}

  Result := nil;

  for Attr in Obj.GetAttributes do
    if Attr is IniIgnoreAttribute then begin
      Result := IniIgnoreAttribute(Attr);
      Break;
    end;

  {$IFDEF UseCodeSite}
  if Assigned(Result) then
    CodeSite.Send('ignore attribute found');
  {$ENDIF}
  {$IFDEF UseCodeSite} CodeSite.ExitMethod('TIniPersist.GetPropIgnoreAttribute'); {$ENDIF}
end;

class procedure TIniPersist.Load(FileName: String; obj: TObject; IgnoreBaseProperties: Boolean = True);
var
  ctx: TRttiContext;
  objType: TRttiType;
  Prop: TRttiProperty;
  PropClass: TClass;
  Value: TValue;
  PropValueAttr: ConfigValueAttribute;
  IniClass: ConfigClassAttribute;
  PropIgnoreAttr: IniIgnoreAttribute;
  Ini: TIniFile;
  Data: String;

  IniClassSection: string;
  PropDefaultAttr: string;
begin
  {$IFDEF UseCodeSite} CodeSite.EnterMethod('TIniPersist.Load');  {$ENDIF}
  {$IFDEF UseCodeSite} CodeSite.Send('filename', FileName); {$ENDIF}

  ctx := TRttiContext.Create;
  try
    Ini := TIniFile.Create(FileName);
    try
      objType := ctx.GetType(Obj.ClassInfo);

      {$REGION 'get the "section" from either the class or the Section property in the object'}
      // is this class using the "class-level" keys?
      IniClass := GetClassAttribute(ObjType);
      if Assigned(IniClass) then begin
        // if using class-level INI keys, this is the [INIKEY] for the class and the properties define themselves as Value Names
        IniClassSection := IniClass.SectionName;
        {$IFDEF UseCodeSite} CodeSite.Send('using class level [section] for ' + Obj.ClassName, IniClassSection); {$ENDIF}
      end else
        IniClassSection := (Obj as TCustomIniSettings).Section;
      {$ENDREGION}

      // look at all the properties of the object
      for Prop in objType.GetProperties do begin
        // get the class to which the current property belongs
        PropClass := TRttiInstanceType(Prop.Parent).MetaclassType;

        // always ignore TInterfacedObject properties
        if PropClass <> TInterfacedObject then begin
          // optionally ignore TCustomSettings properties
          if IgnoreBaseProperties and (PropClass = TCustomIniSettings) then begin
            {$IFDEF UseCodeSite} CodeSite.Send(csmLevel1, 'ignoring base property', Prop.Name); {$ENDIF}
          end else begin
            // look at each of the properties
            {$IFDEF UseCodeSite} CodeSite.Send(csmLevel1, 'checking property', Prop.Name); {$ENDIF}
            Data := EmptyStr;

            {$REGION 'read the value for the property from the registry'}
            // if class-level keys are in use then these will override the class-level settings
            PropValueAttr := GetValueAttribute(Prop);
            if Assigned(PropValueAttr) then begin
              Data := Ini.ReadString((Obj as TCustomIniSettings).Section, PropValueAttr.Name, PropValueAttr.DefaultValue);
              {$IFDEF UseCodeSite} CodeSite.Send('property-specific data', Data); {$ENDIF}
            end else if Length(IniClassSection) > 0 then begin
              // if using class-level keys, check to see if this property is ignored in the INI file
              PropIgnoreAttr := GetPropIgnoreAttribute(Prop);
              if not Assigned(PropIgnoreAttr) then begin
                // not ignored, check to see if there's a default value
                PropDefaultAttr := GetDefaultAttributeValue(Prop);

                // finally, read the data using the property name as the value name
                Data := Ini.ReadString(IniClassSection, Prop.Name, PropDefaultAttr);
                {$IFDEF UseCodeSite} CodeSite.Send('class-level data', Data); {$ENDIF}
              end;
            end;
            {$ENDREGION}

            {$REGION 'assign the value to the property in the object'}
            // whichever way we read in the data, if it's available, we can now assign it
            if Length(Data) > 0 then begin
              {$IFDEF UseCodeSite} CodeSite.Send(csmLevel2, 'data read from .INI file', Data); {$ENDIF}
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
      Ini.Free;
    end;
  finally
    ctx.Free;
  end;

  {$IFDEF UseCodeSite} CodeSite.ExitMethod('TIniPersist.Load'); {$ENDIF}
end;

class procedure TIniPersist.SetValue(aData: String;var aValue: TValue);
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
    raise EIniPersist.Create('SetValue - Type not supported');
  end;
end;

class procedure TIniPersist.Save(FileName: String; obj: TObject; IgnoreBaseProperties: Boolean = True);
var
  ctx: TRttiContext;
  objType: TRttiType;
  Prop: TRttiProperty;
  PropClass: TClass;
  Value: TValue;
  PropValueAttr: ConfigValueAttribute;
  IniClass: ConfigClassAttribute;
  PropIgnoreAttr: IniIgnoreAttribute;
  Ini: TMemIniFile;
  Data: String;

  IniClassSection: string;
begin
  {$IFDEF UseCodeSite} CodeSite.EnterMethod('TIniPersist.Save'); {$ENDIF}
  {$IFDEF UseCodeSite} CodeSite.Send('filename', Filename); {$ENDIF}

  ctx := TRttiContext.Create;
  try
    Ini := TMemIniFile.Create(FileName);
    try
      objType := ctx.GetType(Obj.ClassInfo);

      {$REGION 'get the "section" from either the class or the Section property in the object'}
      // is this class using the new "class-level" keys?
      IniClass := GetClassAttribute(ObjType);
      if Assigned(IniClass) then begin
        // if using class-level INI keys, this is the [INIKEY] for the class and the properties define themselves as Key Names
        IniClassSection := IniClass.SectionName;
        {$IFDEF UseCodeSite} CodeSite.Send('using class level [section] for ' + Obj.ClassName, IniClassSection); {$ENDIF}
      end else
        IniClassSection := (Obj as TCustomIniSettings).Section;
      {$ENDREGION}

      // look at all the properties of the object
      for Prop in objType.GetProperties do begin
        // get the class to which the current property belongs
        PropClass := TRttiInstanceType(Prop.Parent).MetaclassType;

        // always ignore TInterfacedObject properties
        if (PropClass <> TInterfacedObject) { and (PropClass <> TCustomSettings) } then begin
          // optionally ignore TCustomSettings properties
          if IgnoreBaseProperties and (PropClass = TCustomIniSettings) then begin
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
              {$IFDEF UseCodeSite} CodeSite.Send('IniValue.Name', PropValueAttr.Name); {$ENDIF}
              Ini.WriteString(IniClassSection, PropValueAttr.Name, Data);
              {$IFDEF UseCodeSite} CodeSite.Send(csmLevel2, 'data written to .INI file', Data); {$ENDIF}
            end else begin
              // if not using IniValue for the properties, check to see if this property is ignored
              PropIgnoreAttr := GetPropIgnoreAttribute(Prop);
              if Assigned(PropIgnoreAttr) then begin
                {$IFDEF UseCodeSite} CodeSite.Send('ignoring...'); {$ENDIF}
              end else begin
                // not ignored and the IniClassSection is set, write out the data using property name as value name
                Ini.WriteString(IniClassSection, Prop.Name, Data);
                {$IFDEF UseCodeSite} CodeSite.Send(csmLevel2, 'data written to .INI file', Data); {$ENDIF}
              end;
            end;
            {$ENDREGION}
          end;
        end;
      end;
    finally
      Ini.UpdateFile;
      Ini.Free;
    end;
  finally
    ctx.Free;
  end;

  {$IFDEF UseCodeSite} CodeSite.ExitMethod('TIniPersist.Save');  {$ENDIF}
end;

class function TIniPersist.GetValue(var aValue: TValue) : string;
begin
  {$IFDEF UseCodeSite} CodeSite.EnterMethod( 'TIniPersist.GetValue'); {$ENDIF}
  {$IFDEF UseCodeSite} CodeSite.Send('aValue', aValue.ToString); {$ENDIF}

  if aValue.Kind in [tkWChar, tkLString, tkWString, tkString, tkChar, tkUString,
                     tkInteger, tkInt64, tkFloat, tkEnumeration, tkSet] then
    result := aValue.ToString
  else
    raise EIniPersist.Create('GetValue - Type not supported');

  {$IFDEF UseCodeSite} CodeSite.Send('Result', Result); {$ENDIF}
  {$IFDEF UseCodeSite} CodeSite.ExitMethod('TIniPersist.GetValue'); {$ENDIF}
end;

{ ConfigClassAttribute }

constructor ConfigClassAttribute.Create(const NewSectionName: string);
begin
  {$IFDEF UseCodeSite} CodeSite.EnterMethod(Self, 'Create'); {$ENDIF}
  {$IFDEF UseCodeSite} CodeSite.Send('new section name', NewSectionName); {$ENDIF}

  FSectionName := NewSectionName;

  {$IFDEF UseCodeSite} CodeSite.ExitMethod(Self, 'Create'); {$ENDIF}
end;

{ IniDefaultAttribute }

constructor IniDefaultAttribute.Create(const NewDefaultValue: string);
begin
  {$IFDEF UseCodeSite} CodeSite.EnterMethod(Self, 'Create'); {$ENDIF}
  {$IFDEF UseCodeSite} CodeSite.Send('new default value', NewDefaultValue); {$ENDIF}

  FDefaultValue := NewDefaultValue;

  {$IFDEF UseCodeSite} CodeSite.ExitMethod(Self, 'Create'); {$ENDIF}
end;

end.

