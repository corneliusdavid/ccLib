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
  // allows one [Key] to be defined for the entire class; then the property names become the Value Names
  IniSectionAttribute = class(TCustomAttribute)
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
    class function GetPropIgnoreAttribute(Obj: TRttiObject): IniIgnoreAttribute;
    class function GetClassSection(ObjType: TRttiType): string;
    class function GetIniSection(obj: TObject): string;
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
    class procedure Load(FileName: string; obj: TObject);
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
    class procedure Save(FileName: string; obj: TObject);
  end;


implementation

uses
  {$IFDEF UseCodeSite} CodeSiteLogging, {$ENDIF}
  IniFiles, uConfigBaseIni;

{ TIniPersist }

class function TIniPersist.GetClassSection(ObjType: TRttiType): string;
{ check to see if the IniClassAttribute is assigned }
var
  Attr: TCustomAttribute;
begin
  {$IFDEF UseCodeSite} CodeSite.EnterMethod('TIniPersist.GetClassAttribute'); {$ENDIF}

  Result := EmptyStr;

  for Attr in ObjType.GetAttributes do
    if Attr is IniSectionAttribute then begin
      Result := IniSectionAttribute(Attr).SectionName;
      Break;
    end;

  {$IFDEF UseCodeSite} CodeSite.ExitMethod('TIniPersist.GetClassAttribute'); {$ENDIF}
end;

class function TIniPersist.GetPropIgnoreAttribute(Obj: TRttiObject): IniIgnoreAttribute;
{ check to see if the IniIgnoreAttribute is assigned }
var
  Attr: TCustomAttribute;
begin
  Result := nil;

  for Attr in Obj.GetAttributes do
    if Attr is IniIgnoreAttribute then begin
      Result := IniIgnoreAttribute(Attr);
      Break;
    end;
end;

class function TIniPersist.GetIniSection(obj: TObject): string;
begin
  {$IFDEF UseCodeSite} CodeSite.EnterMethod('GetIniSection'); {$ENDIF}

  Result := (Obj as TCustomIniSettings).Section;

  {$IFDEF UseCodeSite} CodeSite.Send('Result', Result); {$ENDIF}
  {$IFDEF UseCodeSite} CodeSite.ExitMethod('GetIniSection'); {$ENDIF}
end;

class procedure TIniPersist.Load(FileName: String; obj: TObject);

  procedure CheckPropertyAttributes(AProp: TRttiProperty; var DefaultValue: string; var IgnoreProp: Boolean);
  var
    Attr: TCustomAttribute;
  begin
    DefaultValue := EmptyStr;
    IgnoreProp := False;

    if AProp.Visibility <> mvPublished then
      IgnoreProp := True
    else begin
      for Attr in AProp.GetAttributes do
        if Attr is IniIgnoreAttribute then
          IgnoreProp := True
        else if Attr is IniDefaultAttribute then
          DefaultValue := IniDefaultAttribute(Attr).DefaultValue;
    end;
  end;

var
  ctx: TRttiContext;
  objType: TRttiType;
  Prop: TRttiProperty;
  PropClass: TClass;
  Value: TValue;
  Ini: TIniFile;
  Data: String;
  Skip: Boolean;
  DefaultVal: string;
  IniSection: string;
begin
  {$IFDEF UseCodeSite} CodeSite.EnterMethod('TIniPersist.Load');  {$ENDIF}
  {$IFDEF UseCodeSite} CodeSite.Send('filename', FileName); {$ENDIF}

  ctx := TRttiContext.Create;
  Ini := TIniFile.Create(FileName);
  try
    objType := ctx.GetType(Obj.ClassInfo);

    IniSection := GetIniSection(obj);
    if Length(IniSection) = 0 then
      raise EProgrammerNotFound.Create('IniSection not set for class: ' + objType.ToString);

    // look at all the properties of the object
    for Prop in objType.GetProperties do begin
      // get the class to which the current property belongs
      PropClass := TRttiInstanceType(Prop.Parent).MetaclassType;

      // always ignore TCustomSettings properties
      if PropClass <> TCustomIniSettings then begin
        CheckPropertyAttributes(Prop, DefaultVal, Skip);

        if not skip then begin
          // read the data using the property name as the value name
          Data := Ini.ReadString(IniSection, Prop.Name, DefaultVal);
          {$IFDEF UseCodeSite} CodeSite.Send(csmLevel2, 'data read from .INI file', Data); {$ENDIF}

          // just before assigning, get the value from the object into a Value var
          Value := Prop.GetValue(Obj);
          // set the new value into the Value var
          SetValue(Data, Value);
          // and finally, write the Value into the object
          if prop.IsWritable then
            prop.SetValue(Obj, Value);
        end;
      end;
    end;
  finally
    Ini.Free;
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

class procedure TIniPersist.Save(FileName: String; obj: TObject);
var
  ctx: TRttiContext;
  objType: TRttiType;
  Prop: TRttiProperty;
  PropClass: TClass;
  Value: TValue;
  PropIgnoreAttr: IniIgnoreAttribute;
  Ini: TIniFile;
  Data: String;
  IniSection: string;
begin
  {$IFDEF UseCodeSite} CodeSite.EnterMethod('TIniPersist.Save'); {$ENDIF}
  {$IFDEF UseCodeSite} CodeSite.Send('filename', Filename); {$ENDIF}

  ctx := TRttiContext.Create;
  Ini := TIniFile.Create(FileName);
  try
    objType := ctx.GetType(Obj.ClassInfo);

    IniSection := GetIniSection(obj);

    // look at all the properties of the object
    for Prop in objType.GetProperties do begin
      // get the class to which the current property belongs
      PropClass := TRttiInstanceType(Prop.Parent).MetaclassType;

      // always ignore TCustomIniSettings properties
      if PropClass <> TCustomIniSettings then begin
        if Length(IniSection) > 0 then begin
          PropIgnoreAttr := GetPropIgnoreAttribute(Prop);
          if not Assigned(PropIgnoreAttr) then begin
            {$IFDEF UseCodeSite} CodeSite.Send(csmLevel1, 'checking property', Prop.Name); {$ENDIF}
            // get the value to be saved
            Value := Prop.GetValue(Obj);
            Data := GetValue(Value);

            // not ignored and the IniClassSection is set, write out the data using property name as value name
            Ini.WriteString(IniSection, Prop.Name, Data);
            {$IFDEF UseCodeSite} CodeSite.Send(csmLevel2, 'data written to .INI file', Data); {$ENDIF}
          end;
        end;
      end;
    end;
  finally
    Ini.Free;
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

{ IniSectionAttribute }

constructor IniSectionAttribute.Create(const NewSectionName: string);
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

