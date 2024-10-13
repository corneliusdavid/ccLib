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
 * Modified further by David Cornelius of Cornelius Concepts, LLC
 *)

{$TYPEINFO ON}

interface

uses
  SysUtils, Classes, Rtti, TypInfo, IniFiles;

type
  {=========================================}
  {   ATTRIBUTE CLASSES                     }
  {=========================================}
  ///	<summary>
  ///	  An Attribute class that should be applied at the class level to define the "Config Section"
  ///	</summary>
  ///	<remarks>
  ///	  This attribute class defines the [Section] of the .INI file for the class; all the properties
  ///   get saved as NAME=VALUE pairs within this section; the property names become the value names.
  ///	  Only one instance of a class with IniClassAttribute can be used.
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
  ///	  An Attribute class that can be optionally applied at the class level of a
  ///   descendant class from a bass class to override the "Config Section"
  ///	</summary>
  ///	<remarks>
  ///	  This attribute class overrides the [Section] of the .INI file for the class
  ///   that is defined for a base class. For example, more than one FileExportClass
  ///   may be defined in an application, one for customers and one for inventory.
  ///   If left at default, both would use the INI Section name of 'FileExport'
  ///   from the base class attribute; this way, each derivitive can store settings
  ///   in a custom section, e.g. CustFileExport and InvFileExport.
  ///	</remarks>
  IniSectionOverrideAttribute = class(TCustomAttribute)
  private
    FIniSection: string;
  public
    ///	<summary>
    ///	  The constructor simply establishes the one field of the class.
    ///	</summary>
    ///	<param name="NewIniSetion">
    ///	  <c>String. Required.</c> Establishes the [Section] of the .INI file for the class and its properties.
    ///	</param>
    constructor Create(const NewIniSection: string);
  published
    ///	<summary>
    ///	  The name of the [Section] in the .INI key for which this class is
    ///	  saved.
    ///	</summary>
    ///	<remarks>
    ///	  The property name should probably have been IniSection instead of
    ///	  IniKey.
    ///	</remarks>
    property IniSection: string read FIniSection write FIniSection;
  end;

  ///	<summary>
  ///	  This attribute class excludes a property from being loaded/saved.
  ///	</summary>
  /// <remarks>
  ///   This class doesn't have any properties or methods; it's mere existence in a class is a flag to the member
  /// </remarks>
  IniIgnoreAttribute = class(TCustomAttribute);

  ///	<summary>
  ///	  This attribute class provides an optional default value for a property
  ///	</summary>
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

  TGetIniValueFunc = reference to function (const SectionName, ValueName, DefaultValue: string): string;
  TPutIniValueProc = reference to procedure (const SectionName, ValueName, StrValue: string);

  {=========================================}
  {   IniPersist                            }
  {=========================================}
  ///	<summary>
  ///	  Descend your configuration classes from this class and define an IniClass attribute to define the section,
  ///   then call LoadFromIni/SaveToIni for very simple by loading and saving of all the property values of the
  ///   class to an .INI file; -OR- call LoadFromStr/SaveToStr to load and save the property values of the class
  ///   to a single string of NAME=VALUE pairs separated by semicolons (note that the LoadFromStr/SaveToStr methods
  ///   do not use a [Section] like the INI file methods do).
  ///	</summary>
  /// <example>
  ///  <code>
  ///  type
  ///    [MySection]
  ///    TMySettings = class(TIniPersist)
  ///      ...
  ///    end;
  ///  var MySettings: TMySettings;
  ///  MySettings := TMySettings.Create;
  ///  MySettings.LoadFromIni(MyIniFilename);
  ///  </code>
  /// </example>
  /// <remarks>
  ///   You might use LoadFromStr/SaveToStr when you're loading/storing configuration settings in a web service
  ///   or database instead of an .INI file as it provides flexibility where the names and values are stored.
  ///   Remember, an .INI file's NAME=VALUE pairs must be indexed with a [Section] while the String version does not.
  /// </remarks>
  TIniPersist = class (TObject)
  private
    const
       CLASS_SECTION_MISSING = '[IniClass(''SectionName'')] missing';
    procedure SetValue(const aData: string; var aValue : TValue);
    function GetValue(var aValue: TValue): string;
    function GetPropIgnoreAttribute(Obj: TRttiObject): IniIgnoreAttribute;
    function GetDefaultAttributeValue(Obj: TRttiObject): string;
    function GetClassAttribute(ObjTyp: TRttiType): IniClassAttribute;
    function GetSectionOverrideAttribute(ObjTyp: TRttiType): IniSectionOverrideAttribute;
  protected
    function GetClassSection(ClassType: TRttiType): string;
    function GetOverrideSection(ClassType: TRttiType): string;
    procedure LoadRttiClass(GetCfgValue: TGetIniValueFunc; const SectName: string = '');
    procedure SaveRttiClass(PutCfgValue: TPutIniValueProc; const SectName: string = '');
  public
    ///	<summary>
    ///	  LoadFromIni reads a configuration file and fills the given object with the settings found.
    ///	</summary>
    ///	<param name="FileName">
    ///	  <c>String. Required.</c> The name of the .INI file to read from.
    ///	</param>
    procedure LoadFromIni(const FileName: string; const OverrideSectionName: string = '');
    ///	<summary>
    ///	  SaveToIni writes a configuration file using the settings from the given object.
    ///	</summary>
    ///	<param name="FileName">
    ///	  <c>String. Required.</c> The name of the .INI file to write.
    ///	</param>
    procedure SaveToIni(const FileName: string; const OverrideSectionName: string = '');
    ///	<summary>
    ///	  Parse the given string and fill the configuration object with the settings found.
    ///	</summary>
    ///	<param name="ConfigStr">
    ///	  <c>String. Required.</c> A series of NAME=VALUE pairs separated by semicolons.
    ///	</param>
    procedure LoadFromStr(const ConfigStr: string);
    ///	<summary>
    ///	  Save a configuration object, concatentating the settings to a single string.
    ///	</summary>
    ///	<param name="ConfigStr">
    ///	  <c>String. Required.</c> The resultant configuration string of NAME=VALUE pairs separated by semicolons.
    ///	</param>
    procedure SaveToStr(var ConfigStr: string);
  end;


implementation


{ IniClassAttribute }

constructor IniClassAttribute.Create(const NewIniKey: string);
begin
  FIniKey := NewIniKey;
end;

{ IniSectionOverrideAttribute }

constructor IniSectionOverrideAttribute.Create(const NewIniSection: string);
begin
  FIniSection := NewIniSection;
end;

{ IniDefaultAttribute }

constructor IniDefaultAttribute.Create(const NewDefaultValue: string);
begin
  FDefaultValue := NewDefaultValue;
end;

{ TIniPersist }

function TIniPersist.GetClassAttribute(ObjTyp: TRttiType): IniClassAttribute;
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

function TIniPersist.GetSectionOverrideAttribute(ObjTyp: TRttiType): IniSectionOverrideAttribute;
{ check to see if a descendant class added a section override attribute }
var
  Attr: TCustomAttribute;
begin
  Result := nil;

  for Attr in ObjTyp.GetAttributes do
    if Attr is IniSectionOverrideAttribute then begin
      Result := IniSectionOverrideAttribute(Attr);
      Break;
    end;
end;

function TIniPersist.GetClassSection(ClassType: TRttiType): string;
var
  IniClass: IniClassAttribute;
begin
  // ensure this class is using "class-level" keys
  IniClass := GetClassAttribute(ClassType);
  if Assigned(IniClass) then
    // if using class-level INI keys, this is the [INIKEY] for the class and the properties define themselves as Key Names
    Result := IniClass.IniKey
  else
    Result := EmptyStr;
end;

function TIniPersist.GetOverrideSection(ClassType: TRttiType): string;
var
  IniClass: IniSectionOverrideAttribute;
begin
  // ensure this class is using "class-level" keys
  IniClass := GetSectionOverrideAttribute(ClassType);
  if Assigned(IniClass) then
    // if using class-level INI keys, this is the [INIKEY] for the class and the properties define themselves as Key Names
    Result := IniClass.IniSection
  else
    Result := EmptyStr;
end;

function TIniPersist.GetDefaultAttributeValue(Obj: TRttiObject): string;
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

function TIniPersist.GetPropIgnoreAttribute(Obj: TRttiObject): IniIgnoreAttribute;
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

procedure TIniPersist.SetValue(const aData: string; var aValue: TValue);
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

function TIniPersist.GetValue(var aValue: TValue) : string;
begin
   if aValue.Kind in [tkWChar, tkLString, tkWString, tkString, tkChar, tkUString,
                      tkInteger, tkInt64, tkFloat, tkEnumeration, tkSet] then
     Result := aValue.ToString
   else
     raise EIniPersist.Create('GetValue - Type not supported');
end;

procedure TIniPersist.LoadRttiClass(GetCfgValue: TGetIniValueFunc; const SectName: string = '');
var
  ctx : TRttiContext;
  objType : TRttiType;
  Prop  : TRttiProperty;
  PropClass: TClass;
  Value : TValue;
  IniPropIgnore: IniIgnoreAttribute;
  Data : string;
  IniSection: string;
  IniDefault: string;
begin
  ctx := TRttiContext.Create;
  try
    objType := ctx.GetType(Self.ClassType);

    // Where does the INI [Section] come from?
    // 1. Parameter "SectName"
    // 2. Override attribute defined by a descendant class
    // 3. Class attribute
    IniSection := SectName;
    if IniSection.IsEmpty then begin
      IniSection := GetOverrideSection(ObjType);
      if IniSection.IsEmpty then
        IniSection := GetClassSection(ObjType);
    end;

    // look at all the properties of the object
    for Prop in objType.GetProperties do begin
      // get the class to which the current property belongs
      PropClass := TRttiInstanceType(Prop.Parent).MetaclassType;

      // always ignore TInterfacedObject properties
      if PropClass <> TInterfacedObject then begin
        // look at each of the properties
        {$IFDEF UseCodeSite} CodeSite.Send(csmLevel1, 'checking property', Prop.Name); {$ENDIF}
        Data := EmptyStr;

        // check to see if this property is ignored in the INI file
        IniPropIgnore := GetPropIgnoreAttribute(Prop);
        if not Assigned(IniPropIgnore) then begin
          // not ignored, check to see if there's a default value
          IniDefault := GetDefaultAttributeValue(Prop);

          // finally, read the data using the property name as the value name
          Data := GetCfgValue(IniSection, Prop.Name, IniDefault);
          {$IFDEF UseCodeSite} CodeSite.Send(Format('read "%s" from [%s] %s', [Data, IniSection, Prop.Name])); {$ENDIF}
        end;

        // if the data is available, we can now assign it
        if (Length(Data) > 0) and prop.IsWritable then begin
          {$IFDEF UseCodeSite} CodeSite.Send(csmLevel2, 'data read from .INI file', Data); {$ENDIF}
          Value := Prop.GetValue(Self);
          SetValue(Data, Value);
          prop.SetValue(Self, Value);
        end;
      end;
    end;
  finally
    ctx.Free;
  end;
end;

procedure TIniPersist.SaveRttiClass(PutCfgValue: TPutIniValueProc; const SectName: string = '');
var
  ctx : TRttiContext;
  objType : TRttiType;
  Prop  : TRttiProperty;
  PropClass: TClass;
  Value : TValue;
  IniPropIgnore: IniIgnoreAttribute;
  Data : String;
  IniSection: string;
begin
  ctx := TRttiContext.Create;
  try
    objType := ctx.GetType(self.ClassInfo);

    // Where does the INI [Section] come from?
    // 1. Parameter "SectName"
    // 2. Override attribute defined by a descendant class
    // 3. Class attribute
    IniSection := SectName;
    if IniSection.IsEmpty then begin
      IniSection := GetOverrideSection(ObjType);
      if IniSection.IsEmpty then
        IniSection := GetClassSection(ObjType);
    end;

    // look at all the properties of the object
    for Prop in objType.GetProperties do begin
      // get the class to which the current property belongs
      PropClass := TRttiInstanceType(Prop.Parent).MetaclassType;

      // always ignore TInterfacedObject properties
      if (PropClass <> TInterfacedObject) then begin
        {$IFDEF UseCodeSite} CodeSite.Send(csmLevel1, 'checking property', Prop.Name); {$ENDIF}
        // get the value to be saved
        Value := Prop.GetValue(Self);
        Data := GetValue(Value);

        // check to see if this property is ignored
        IniPropIgnore := GetPropIgnoreAttribute(Prop);
        if Assigned(IniPropIgnore) then
          continue
        else begin
          // not ignored and the IniSection is set, write out the data using property name as value name
          PutCfgValue(IniSection, Prop.Name, Data);
          {$IFDEF UseCodeSite} CodeSite.Send(csmLevel2, 'data written to .INI file', Data); {$ENDIF}
        end;
      end;
    end;
  finally
    ctx.Free;
  end;
end;

{ TIniPersist }

procedure TIniPersist.LoadFromIni(const FileName: String; const OverrideSectionName: string = '');
var
  FIni : TIniFile;
begin
  {$IFDEF UseCodeSite} CodeSite.EnterMethod('TIniPersist.LoadFromIni');  {$ENDIF}
  {$IFDEF UseCodeSite} CodeSite.Send('filename', FileName); {$ENDIF}

  FIni := TIniFile.Create(FileName);
  try
    LoadRttiClass(
      function (const SectionName, ValueName, DefaultValue: string): string
      begin
        if Length(SectionName) = 0 then
          raise EProgrammerNotFound.Create(CLASS_SECTION_MISSING);
        Result := FIni.ReadString(SectionName, ValueName, DefaultValue);
      end,
      OverrideSectionName);
  finally
    FIni.Free;
  end;

  {$IFDEF UseCodeSite} CodeSite.ExitMethodCollapse('TIniPersist.LoadFromIni'); {$ENDIF}
end;

procedure TIniPersist.SaveToIni(const FileName: String; const OverrideSectionName: string = '');
var
  FIni : TIniFile;
begin
  {$IFDEF UseCodeSite} CodeSite.EnterMethod('TIniPersist.SaveToIni'); {$ENDIF}
  {$IFDEF UseCodeSite} CodeSite.Send('filename', Filename); {$ENDIF}

  FIni := TIniFile.Create(FileName);
  try
    SaveRttiClass(
      procedure (const SectionName, ValueName, StrValue: string)
      begin
        if Length(SectionName) = 0 then
          raise EProgrammerNotFound.Create(CLASS_SECTION_MISSING);
        FIni.WriteString(SectionName, ValueName, StrValue);
      end,
      OverrideSectionName);
  finally
    FIni.Free;
  end;

  {$IFDEF UseCodeSite} CodeSite.ExitMethodCollapse('TIniPersist.SaveToIni');  {$ENDIF}
end;

procedure TIniPersist.LoadFromStr(const ConfigStr: String);
var
  NameValueStrings: TStringList;
begin
  NameValueStrings := TStringList.Create;
  try
    NameValueStrings.Delimiter := ';';
    NameValueStrings.StrictDelimiter := True;
    NameValueStrings.DelimitedText := ConfigStr;

    LoadRttiClass(
      function(const SectionName, ValueName, DefaultValue: string): string
      begin
        // SectionName is not used in string configs
        {$if CompilerVersion >= 36.0} // Delphi 12 Athens
        if NameValueStrings.ContainsName(ValueName) then
        {$ELSE}
        if NameValueStrings.IndexOfName(ValueName) > -1 then
        {$IFEND}
          Result := NameValueStrings.Values[ValueName]
        else
          Result := DefaultValue;
      end
    );
  finally
    NameValueStrings.Free;
  end;
end;

procedure TIniPersist.SaveToStr(var ConfigStr: String);
var
  NameValueStrings: TStringList;
begin
  NameValueStrings := TStringList.Create;
  try
    NameValueStrings.Delimiter := ';';
    NameValueStrings.StrictDelimiter := True;

    SaveRttiClass(
      procedure (const SectionName, ValueName, StrValue: string)
      begin
        // SectionName is not used in string configs
        NameValueStrings.Values[ValueName] := StrValue;
      end);

    ConfigStr := NameValueStrings.DelimitedText;
  finally
    NameValueStrings.Free;
  end;
end;

end.

