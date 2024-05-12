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
 * Modified by David Cornelius of Retail Dimensions, Inc.
 * Used by permission from Kurt Beeken of RDi.
 *)

{$TYPEINFO ON}

interface

uses
  SysUtils, Classes, Rtti, TypInfo;

type
  ///	<summary>
  ///	  An Attribute class that can be applied to a member of an object so that
  ///	  when the object is passed to the Load or Save methods of TIniPersist,
  ///	  the member will be loaded or saved to/from the .INI file.
  ///	</summary>
  IniValueAttribute = class(TCustomAttribute)
  private
    FName: string;
    FDefaultValue: string;
  published
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
     constructor Create(const AName: string;
                        const ADefaultValue: string = '');
     ///	<summary>
     ///	  This is the Name part of a Name=Value line in the .INI file.
     ///	</summary>
     property Name : string read FName write FName;
     ///	<summary>
     ///	  This is the default value of a Name=Value line of the .INI file.
     ///	</summary>
     property DefaultValue : string read FDefaultValue write FDefaultValue;
  end;

  ///	<summary>
  ///	  An Attribute class that can be applied to a class so that when it is
  ///	  passed to the Load or Save methods of TIniPersist, the members will be
  ///	  loaded or saved to/from the .INI file.
  ///	</summary>
  ///	<remarks>
  ///	  This attribute class can be used instead of IniValueAttribute for
  ///	  convenience because all the properties get saved to the .INI file by
  ///	  default, but the [Section] of the .INI file for the class is determined
  ///	  at design-time and therefore only one instance of a class with
  ///	  IniClassAttribute can be used.
  ///	</remarks>
  IniClassAttribute = class(TCustomAttribute)
  private
    FIniKey: string;
  public
    ///	<summary>
    ///	  The constructor simply establishes the one field of the class.
    ///	</summary>
    ///	<param name="NewIniKey">
    ///	  <c>String. Required.</c> Establishes the [Section] of the .INI file for the class and its properties.
    ///	</param>
    constructor Create(const NewIniKey: string);
  published
    ///	<summary>
    ///	  The name of the [Section] in the .INI key for which this class is
    ///	  saved.
    ///	</summary>
    ///	<remarks>
    ///	  The property name should probably have been IniSection instead of
    ///	  IniKey.
    ///	</remarks>
    property IniKey: string read FIniKey write FIniKey;
  end;

  ///	<summary>
  ///	  When an IniClassAttribute is in use for a class, this attribute class
  ///	  will exclude a member from the INI file.
  ///	</summary>
  ///	<remarks>
  ///	  This class is intended to be used only in conjunction with
  ///	  IniClassAttribute.
  ///	</remarks>
  IniIgnoreAttribute = class(TCustomAttribute);

  ///	<summary>
  ///	  When an IniClassAttribute is in use for a class, this member-level
  ///	  attribute class provides optional INI value defaults
  ///	</summary>
  ///	<remarks>
  ///	  Is intended to be used only in conjunction with IniClassAttribute.
  ///	</remarks>
  IniDefaultAttribute = class(TCustomAttribute)
  private
    FDefaultValue: string;
  public
    ///	<summary>
    ///	  The constructor method simply initializes the DefaultValue field.
    ///	</summary>
    ///	<param name="NewDefaultValue">
    ///	  <c>String. Required.</c> This is the new Default Value of the class member to which this attribute is applied.
    ///	</param>
    constructor Create(const NewDefaultValue: string);
  published
    ///	<summary>
    ///	  This field is used as a default value when reading a class member
    ///	  from an .Ini file.
    ///	</summary>
    property DefaultValue: string read FDefaultValue write FDefaultValue;
  end;

  ///	<summary>
  ///	  Special exception for use by the IniPersist class.
  ///	</summary>
  ///	<remarks>
  ///	  Simple descendant from the Exception class.
  ///	</remarks>
  EIniPersist = class(Exception);

  ///	<summary>
  ///	  A class for making reading/saving configuration settings very simple by
  ///	  passing in an object peppered with specific attributes.
  ///	</summary>
  /// <example>
  ///  <code>
  ///  uses
  ///    uConfigIniPersist;
  ///  type
  ///    TMySettings = class(TIniPersist)
  ///      ...
  ///    end;
  ///  </code>
  /// </example>
  TIniPersist = class (TObject)
  private
    class procedure SetValue(aData : String;var aValue : TValue);
    class function GetValue(var aValue : TValue) : String;
    class function GetIniAttribute(Obj : TRttiObject) : IniValueAttribute;
    class function GetPropIgnoreAttribute(Obj: TRttiObject): IniIgnoreAttribute;
    class function GetDefaultAttributeValue(Obj: TRttiObject): string;
    class function GetClassAttribute(ObjTyp: TRttiType): IniClassAttribute;
  public
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
    ///	  <c>Boolean. Optional.</c> If the IniClass attribute is applied
    ///	  (which automatically reads all properties), this optional parameter
    ///	  (False by default) will ignore the properties in the base class of
    ///	  the object supplied. This is useful when using the common
    ///	  TCustomSettings settings that have properties seldom used in
    ///	  applications.
    ///	</param>
    class procedure Load(const FileName : String; obj: TObject; IgnoreBaseProperties: Boolean = True);
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
    ///	  <c>Boolean. Optional.</c> If the IniClass attribute is applied
    ///	  (which automatically writes all properties), this optional parameter
    ///	  (False by default) will ignore the properties in the base class of
    ///	  the object supplied. This is useful when using the common
    ///	  TCustomSettings settings that have properties seldom used in
    ///	  applications.
    ///	</param>
    class procedure Save(const FileName : String;obj : TObject; IgnoreBaseProperties: Boolean = True);
  end;


implementation

uses
  {$IFDEF UseCodeSite} CodeSiteLogging, {$ENDIF}
  IniFiles, uConfigBaseIni;

{ TIniValue }

constructor IniValueAttribute.Create(const AName: string; const ADefaultValue: string);
begin
  FName := aName;
  FDefaultValue := aDefaultValue;
end;

{ TIniPersist }

class function TIniPersist.GetClassAttribute(ObjTyp: TRttiType): IniClassAttribute;
{ check to see if the IniClassAttribute is assigned }
var
  Attr: TCustomAttribute;
begin
  Result := nil;

  for Attr in ObjTyp.GetAttributes do
    if Attr is IniClassAttribute then begin
      Result := IniClassAttribute(Attr);
      Break;
    end;
end;

class function TIniPersist.GetDefaultAttributeValue(Obj: TRttiObject): string;
{ check to see if the IniDefaultAttribute is assigned; if so, return the default string }
var
  Attr: TCustomAttribute;
begin
  Result := EmptyStr;

  for Attr in Obj.GetAttributes do
    if Attr is IniDefaultAttribute then begin
      Result := IniDefaultAttribute(Attr).DefaultValue;
      Break;
    end;
end;

class function TIniPersist.GetIniAttribute(Obj: TRttiObject): IniValueAttribute;
{ check to see if the IniValueAttribute is assigned }
var
  Attr: TCustomAttribute;
begin
  Result := nil;

  for Attr in Obj.GetAttributes do
    if Attr is IniValueAttribute then begin
      Result := IniValueAttribute(Attr);
      Break;
    end;
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

class procedure TIniPersist.Load(const FileName: String; obj: TObject; IgnoreBaseProperties: Boolean = True);
var
  ctx : TRttiContext;
  objType : TRttiType;
  Field : TRttiField;
  Prop  : TRttiProperty;
  PropClass: TClass;
  Value : TValue;
  IniValue: IniValueAttribute;
  IniClass: IniClassAttribute;
  IniPropIgnore: IniIgnoreAttribute;
  Ini : TIniFile;
  Data : String;
  ObjSection: string;

  IniClassSection: string;
  IniDefault: string;
begin
  {$IFDEF UseCodeSite} CodeSite.EnterMethod('TIniPersist.Load');  {$ENDIF}
  {$IFDEF UseCodeSite} CodeSite.Send('filename', FileName); {$ENDIF}

  ctx := TRttiContext.Create;
  try
    Ini := TIniFile.Create(FileName);
    try
      objType := ctx.GetType(Obj.ClassInfo);

      // is this class using the "class-level" keys?
      IniClass := GetClassAttribute(ObjType);
      if Assigned(IniClass) then begin
        // if using class-level INI keys, this is the [INIKEY] for the class and the properties define themselves as Value Names
        IniClassSection := IniClass.IniKey;
        {$IFDEF UseCodeSite} CodeSite.Send('using class level [section] for ' + Obj.ClassName, IniClassSection); {$ENDIF}
      end else
        IniClassSection := EmptyStr;

      // look at all the properties of the object
      for Prop in objType.GetProperties do begin
        // get the class to which the current property belongs
        PropClass := TRttiInstanceType(Prop.Parent).MetaclassType;

        // always ignore TInterfacedObject properties
        if PropClass <> TInterfacedObject then begin
          // optionally ignore TCustomSettings properties
          if IgnoreBaseProperties and (PropClass = TBaseCustomConfigSettings) then
            continue
          else begin
            // look at each of the properties
            {$IFDEF UseCodeSite} CodeSite.Send(csmLevel1, 'checking property', Prop.Name); {$ENDIF}
            Data := EmptyStr;

            // if class-level keys are in use then these will override the class-level settings
            IniValue := GetIniAttribute(Prop);
            if Assigned(IniValue) then begin
              ObjSection := (Obj as TBaseCustomConfigSettings).Section;
              //Data := Ini.ReadString(ObjSection, IniValue.Name, IniValue.DefaultValue);
              Data :=  Ini.ReadString(ObjSection, IniValue.Name, IniValue.DefaultValue);
              {$IFDEF UseCodeSite} CodeSite.Send(Format('read "%s" from [%s] %s', [Data, ObjSection, IniValue.Name])); {$ENDIF}
            end else if Length(IniClassSection) > 0 then begin
              // if using class-level keys, check to see if this property is ignored in the INI file
              IniPropIgnore := GetPropIgnoreAttribute(Prop);
              if not Assigned(IniPropIgnore) then begin
                // not ignored, check to see if there's a default value
                IniDefault := GetDefaultAttributeValue(Prop);

                // finally, read the data using the property name as the value name
                Data := Ini.ReadString(IniClassSection, Prop.Name, IniDefault);
                {$IFDEF UseCodeSite} CodeSite.Send(Format('read "%s" from [%s] %s', [Data, IniClassSection, Prop.Name])); {$ENDIF}
              end;
            end;

            // whichever way we read in the data, if it's available, we can now assign it
            if Length(Data) > 0 then begin
              {$IFDEF UseCodeSite} CodeSite.Send(csmLevel2, 'data read from .INI file', Data); {$ENDIF}
              Value := Prop.GetValue(Obj);
              SetValue(Data, Value);
              if prop.IsWritable then
                prop.SetValue(Obj, Value);
            end;
          end;
        end;
      end;

      // this section is rarely used as the INI keys/names are typically defined at the Property level, not the Field level
      for Field in objType.GetFields do begin
        IniValue := GetIniAttribute(Field);
        if Assigned(IniValue) then begin
          Data := Ini.ReadString((Obj as TBaseCustomConfigSettings).Section, IniValue.Name, IniValue.DefaultValue);
          Value := Field.GetValue(Obj);
          SetValue(Data,Value);
          Field.SetValue(Obj,Value);
        end;
      end;
    finally
      Ini.Free;
    end;
  finally
    ctx.Free;
  end;

  {$IFDEF UseCodeSite} CodeSite.ExitMethodCollapse('TIniPersist.Load'); {$ENDIF}
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

class procedure TIniPersist.Save(const FileName: String; obj: TObject; IgnoreBaseProperties: Boolean = True);
var
  ctx : TRttiContext;
  objType : TRttiType;
  Field : TRttiField;
  Prop  : TRttiProperty;
  PropClass: TClass;
  Value : TValue;
  IniValue : IniValueAttribute;
  IniClass: IniClassAttribute;
  IniPropIgnore: IniIgnoreAttribute;
  Ini : TIniFile;
  ObjSection: string;
  Data : String;


  IniClassSection: string;
begin
  {$IFDEF UseCodeSite} CodeSite.EnterMethod('TIniPersist.Save'); {$ENDIF}
  {$IFDEF UseCodeSite} CodeSite.Send('filename', Filename); {$ENDIF}

  ctx := TRttiContext.Create;
  try
    Ini := TIniFile.Create(FileName);
    try
      objType := ctx.GetType(Obj.ClassInfo);

      // is this class using the new "class-level" keys?
      IniClass := GetClassAttribute(ObjType);
      if Assigned(IniClass) then begin
        // if using class-level INI keys, this is the [INIKEY] for the class and the properties define themselves as Key Names
        IniClassSection := IniClass.IniKey;
        {$IFDEF UseCodeSite} CodeSite.Send('using class level [section] for ' + Obj.ClassName, IniClassSection); {$ENDIF}
      end else
        IniClassSection := EmptyStr;

      // look at all the properties of the object
      for Prop in objType.GetProperties do begin
        // get the class to which the current property belongs
        PropClass := TRttiInstanceType(Prop.Parent).MetaclassType;

        // always ignore TInterfacedObject properties
        if (PropClass <> TInterfacedObject) { and (PropClass <> TCustomSettings) } then begin
          // optionally ignore TCustomSettings properties
          if IgnoreBaseProperties and (PropClass = TBaseCustomConfigSettings) then begin
            {$IFDEF UseCodeSite} CodeSite.Send(csmLevel1, 'ignoring base property', Prop.Name); {$ENDIF}
          end else begin
            {$IFDEF UseCodeSite} CodeSite.Send(csmLevel1, 'checking property', Prop.Name); {$ENDIF}
            // get the value to be saved
            Value := Prop.GetValue(Obj);
            Data := GetValue(Value);

            // if class-level keys are in use then these will override the class-level settings
            IniValue := GetIniAttribute(Prop);
            if Assigned(IniValue) then begin
              ObjSection := (Obj as TBaseCustomConfigSettings).Section;
              Ini.WriteString(ObjSection, IniValue.Name, Data);
              {$IFDEF UseCodeSite} CodeSite.Send(csmLevel2, Format('data written to .INI file under [%s]', [ObjSection]), Data); {$ENDIF}
            end else begin
              // if not using IniValue for the properties, check to see if this property is ignored
              IniPropIgnore := GetPropIgnoreAttribute(Prop);
              if Assigned(IniPropIgnore) then begin
                {$IFDEF UseCodeSite} CodeSite.Send('ignoring...'); {$ENDIF}
              end else begin
                // not ignored and the IniClassSection is set, write out the data using property name as value name
                if Length(IniClassSection) > 0 then begin
                  Ini.WriteString(IniClassSection, Prop.Name, Data);
                  {$IFDEF UseCodeSite} CodeSite.Send(csmLevel2, 'data written to .INI file', Data); {$ENDIF}
                end;
              end;
            end;
          end;
        end;
      end;

      // this section is rarely used as the INI keys/names are typically defined at the Property level, not the Field level
      for Field in objType.GetFields do begin
        {$IFDEF UseCodeSite} CodeSite.Send(csmLevel3, 'checking field', Field.Name); {$ENDIF}
        IniValue := GetIniAttribute(Field);
        if Assigned(IniValue) then begin
          Value := Field.GetValue(Obj);
          Data := GetValue(Value);
          Ini.WriteString((Obj as TBaseCustomConfigSettings).Section, IniValue.Name, Data);
          {$IFDEF UseCodeSite} CodeSite.Send(csmLevel4, 'data written to .INI file', Data); {$ENDIF}
        end;
      end;
    finally
      Ini.Free;
    end;
  finally
    ctx.Free;
  end;

  {$IFDEF UseCodeSite} CodeSite.ExitMethodCollapse('TIniPersist.Save');  {$ENDIF}
end;

class function TIniPersist.GetValue(var aValue: TValue) : string;
begin
   if aValue.Kind in [tkWChar, tkLString, tkWString, tkString, tkChar, tkUString,
                      tkInteger, tkInt64, tkFloat, tkEnumeration, tkSet] then
     result := aValue.ToString
   else
     raise EIniPersist.Create('GetValue - Type not supported');
end;

{ IniClassAttribute }

constructor IniClassAttribute.Create(const NewIniKey: string);
begin
  FIniKey := NewIniKey;
end;

{ IniDefaultAttribute }

constructor IniDefaultAttribute.Create(const NewDefaultValue: string);
begin
  FDefaultValue := NewDefaultValue;
end;

end.

