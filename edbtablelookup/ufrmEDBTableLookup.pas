unit ufrmEDBTableLookup;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Mask, Db, Grids, DBGrids, Buttons, DBCtrls,
  DBCGrids, edbcomps, ActnList;

type
  TLookupIndexChangedEvent = procedure (const NewIndexName: string) of Object;

  TfrmEDBTableLookup = class(TForm)
    {$REGION 'form controls'}
    SearchCharacterLabel: TLabel;
    lblSearchBy: TLabel;
    dbCtrlGrid: TDBCtrlGrid;
    edtMemo: TDBMemo;
    Label1: TLabel;
    srcLookup: TDataSource;
    tmrKeystroke: TTimer;
    edtSearchChars: TEdit;
    dbgLookup: TDBGrid;
    cmbSearchBy: TComboBox;
    btn1: TBitBtn;
    btn2: TBitBtn;
    btn3: TBitBtn;
    btn4: TBitBtn;
    btnOK: TBitBtn;
    btnCancel: TBitBtn;
    {$ENDREGION}
    procedure cmbSearchByChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure edtSearchCharsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edtSearchCharsChange(Sender: TObject);
    procedure dbgLookupDblClick(Sender: TObject);
    procedure dbCtrlGridDblClick(Sender: TObject);
    procedure edtMemoDblClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure tmrKeystrokeTimer(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
  strict private
    {$REGION 'fields'}
    FirstTime: Boolean;
    FIndexFieldNames: string;
    FfrmAutoCalcFormWidth: Boolean;
    FfrmShowIndexList: Boolean;
    FfrmPageRows: Integer;
    FfrmUseCtrlGrid: Boolean;
    FfrmGridDblClickSelects: Boolean;
    FfrmGridAllowMultiSelect: Boolean;
    FfrmHideIndexNames: string;
    FfrmMisMatchMsg: string;
    FfrmMatchExact: Boolean;
    FfrmMatchPartial: Boolean;
    FfrmMisMatchBeep: Boolean;
    FfrmOnIndexChanged: TLookupIndexChangedEvent;
    FfrmOnLookupOK: TNotifyEvent;
    FfrmOnLookupCancel: TNotifyEvent;
    {$ENDREGION}
    procedure ResetColumns;
    procedure CalcFormWidth;
    procedure FillIndexList;
    procedure HideIndexList;
    procedure SetIndexFieldNames;
    procedure IncrementalSearch;
    procedure SetAutoCalcFormWidth(const Value: Boolean);
    procedure SetUseCtrlGrid(const Value: Boolean);
    procedure DoIndexChangedEvent;
    procedure SetAllowMultiSelect(const Value: Boolean);
  public
    procedure SetCaption(NewCaption: string);
    property frmAutoCalcFormWidth: Boolean read FfrmAutoCalcFormWidth write SetAutoCalcFormWidth default True;
    property frmGridDblClickSelects: Boolean read FfrmGridDblClickSelects write FfrmGridDblClickSelects default True;
    property frmGridAllowMultiSelect: Boolean read FfrmGridAllowMultiSelect write SetAllowMultiSelect;
    property frmHideIndexNames: string read FfrmHideIndexNames write FfrmHideIndexNames;
    property frmPageRows: Integer read FfrmPageRows write FfrmPageRows default 10;
    property frmShowIndexList: Boolean read FfrmShowIndexList write FfrmShowIndexList default True;
    property frmUseCtrlGrid: Boolean read FfrmUseCtrlGrid write SetUseCtrlGrid default False;
    property frmMatchExact: Boolean read FfrmMatchExact write FfrmMatchExact;
    property frmMatchPartial: Boolean read FfrmMatchPartial write FfrmMatchPartial;
    property frmMisMatchBeep: Boolean read FfrmMisMatchBeep write FfrmMisMatchBeep;
    property frmMisMatchMsg: string read FfrmMisMatchMsg write FfrmMisMatchMsg;
    property frmOnIndexChanged: TLookupIndexChangedEvent read FfrmOnIndexChanged write FfrmOnIndexChanged;
    property frmOnLookupOK: TNotifyEvent read FfrmOnLookupOK write FfrmOnLookupOK;
    property frmOnLookupCancel: TNotifyEvent read FfrmOnLookupCancel write FfrmOnLookupCancel;
  end;

  {$REGION 'XMLDoc'}
  ///	<summary>
  ///	  Lookup component for ElevateDB tables with Incremental search,
  ///	  user-defined buttons, and selectable indexes.
  ///	</summary>
  ///	<remarks>
  ///	  Ideas from Woll2Woll's InfoPower component
  ///	</remarks>
  {$ENDREGION}
  TccEDBLookup = class(TComponent)
  strict private
    {$REGION 'fields'}
    FAutoCalcFormWidth: Boolean;
    FCaption: string;
    FLookupTable: TEDBTable;
    FShowIndexList: Boolean;
    FPageRows: Integer;
    FUseCtrlGrid: Boolean;
    FButton1Visible: Boolean;
    FButton1Caption: string;
    FButton1Click: TNotifyEvent;
    FButton2Visible: Boolean;
    FButton2Caption: string;
    FButton3Visible: Boolean;
    FButton3Caption: string;
    FButton2Click: TNotifyEvent;
    FButton3Click: TNotifyEvent;
    FButton1Enabled: Boolean;
    FButton2Enabled: Boolean;
    FButton3Enabled: Boolean;
    FButton4Enabled: Boolean;
    FButton4Visible: Boolean;
    FButton4Caption: string;
    FButton4Click: TNotifyEvent;
    FButtonCancelCaption: string;
    FButtonOKCaption: string;
    FButtonOKHidden: Boolean;
    FMemoFieldName: string;
    FShowCloseBox: Boolean;
    FButtonCancelHidden: Boolean;
    FGridDblClickSelects: Boolean;
    FHideIndexNames: string;
    FMatchExact: Boolean;
    FMisMatchBeep: Boolean;
    FMisMatchMsg: string;
    FOnIndexChanged: TLookupIndexChangedEvent;
    {$ENDREGION}
  private
    FfrmTableLookup: TfrmEDBTableLookup;
    FMatchPartial: Boolean;
    FAllowMultiSelect: Boolean;
    procedure SetMatchExact(const Value: Boolean);
    procedure SetMisMatchBeep(const Value: Boolean);
    procedure SetMisMatchMsg(const Value: string);
    procedure SetCaption(const Value: string);
    procedure SetMatchPartial(const Value: Boolean);
    function GetSelectedRows: TBookmarkList;
  public
    {$REGION 'XMLDoc'}
    ///	<summary>
    ///	  The constructor simply initializes a bunch of fields.
    ///	</summary>
    {$ENDREGION}
    constructor Create(AOwner: TComponent); override;
    {$REGION 'XMLDoc'}
    ///	<summary>
    ///	  The Execute method is the meat of the entire component.  Call Execute
    ///	  after all the properties and event-handlers are setup.
    ///	</summary>
    ///	<returns>
    ///	  Returns True if OK is the ModalResult of the form.
    ///	</returns>
    ///	<remarks>
    ///	  <para>
    ///	    This function creates the form and all the controls, sets up the
    ///	    properties, hooks up event handlers, does some error checking, then
    ///	    calls ShowModal.
    ///	  </para>
    ///	  <para>
    ///	    The ElevateDB table is assumed to be open before making this call.
    ///	  </para>
    ///	</remarks>
    {$ENDREGION}
    function Execute: Boolean;
    {$REGION 'XMLDoc'}
    ///	<summary>
    ///	  The SelectedRows property returns the list of rows selected if
    ///	  AllowMultiSelect is True.
    ///	</summary>
    {$ENDREGION}
    property SelectedRows: TBookmarkList read GetSelectedRows;
  published
    {$REGION 'XMLDoc'}
    ///	<summary>
    ///	  This property determines whether or not the component should
    ///	  automatically calculate the form's width based on the fields in the
    ///	  grid.
    ///	</summary>
    ///	<remarks>
    ///	  This property is actually a surfaced property of frmAutoCalcFormWidth
    ///	  on the embedded form.  When Execute is called, frmAutoCalcFormWidth
    ///	  gets a copy of this property and if True, calls CalcFormWidth.
    ///	</remarks>
    {$ENDREGION}
    property AutoCalcFormWidth: Boolean read FAutoCalcFormWidth write FAutoCalcFormWidth default True;
    {$REGION 'XMLDoc'}
    ///	<summary>
    ///	  AllowMultiSelect determines whether the Grid allows multiple records
    ///	  to be selected using the Ctrl key.
    ///	</summary>
    ///	<remarks>
    ///	  This property is ignored if UseCtrlGrid is True.
    ///	</remarks>
    {$ENDREGION}
    property AllowMultiSelect: Boolean read FAllowMultiSelect write FAllowMultiSelect;
    {$REGION 'XMLDoc'}
    ///	<summary>
    ///	  The caption for Button1
    ///	</summary>
    {$ENDREGION}
    property Button1Caption: string read FButton1Caption write FButton1Caption;
    {$REGION 'XMLDoc'}
    ///	<summary>
    ///	  Controls whether Button1 is Enabled.
    ///	</summary>
    {$ENDREGION}
    property Button1Enabled: Boolean read FButton1Enabled write FButton1Enabled default True;
    {$REGION 'XMLDoc'}
    ///	<summary>
    ///	  Controls whether Button1 is Visible.
    ///	</summary>
    {$ENDREGION}
    property Button1Visible: Boolean read FButton1Visible write FButton1Visible default False;
    {$REGION 'XMLDoc'}
    ///	<summary>
    ///	  This is the event handler for Button1.
    ///	</summary>
    {$ENDREGION}
    property Button1Click: TNotifyEvent read FButton1Click write FButton1Click;
    {$REGION 'XMLDoc'}
    ///	<summary>
    ///	  The caption for Button2.
    ///	</summary>
    {$ENDREGION}
    property Button2Caption: string read FButton2Caption write FButton2Caption;
    {$REGION 'XMLDoc'}
    ///	<summary>
    ///	  Controls whether Button2 is Enabled.
    ///	</summary>
    {$ENDREGION}
    property Button2Enabled: Boolean read FButton2Enabled write FButton2Enabled default True;
    {$REGION 'XMLDoc'}
    ///	<summary>
    ///	  Controls whether Button2 is Visible.
    ///	</summary>
    {$ENDREGION}
    property Button2Visible: Boolean read FButton2Visible write FButton2Visible default False;
    {$REGION 'XMLDoc'}
    ///	<summary>
    ///	  This is the event handler for Button2.
    ///	</summary>
    {$ENDREGION}
    property Button2Click: TNotifyEvent read FButton2Click write FButton2Click;
    {$REGION 'XMLDoc'}
    ///	<summary>
    ///	  The caption for Button3.
    ///	</summary>
    {$ENDREGION}
    property Button3Caption: string read FButton3Caption write FButton3Caption;
    {$REGION 'XMLDoc'}
    ///	<summary>
    ///	  Controls whether Button3 is Enabled.
    ///	</summary>
    {$ENDREGION}
    property Button3Enabled: Boolean read FButton3Enabled write FButton3Enabled default True;
    {$REGION 'XMLDoc'}
    ///	<summary>
    ///	  Controls whether Button3 is Visibile.
    ///	</summary>
    {$ENDREGION}
    property Button3Visible: Boolean read FButton3Visible write FButton3Visible default False;
    {$REGION 'XMLDoc'}
    ///	<summary>
    ///	  This is the event handler for Button3.
    ///	</summary>
    {$ENDREGION}
    property Button3Click: TNotifyEvent read FButton3Click write FButton3Click;
    {$REGION 'XMLDoc'}
    ///	<summary>
    ///	  The caption for Button4.
    ///	</summary>
    {$ENDREGION}
    property Button4Caption: string read FButton4Caption write FButton4Caption;
    {$REGION 'XMLDoc'}
    ///	<summary>
    ///	  Controls whether Button4 is Enabled.
    ///	</summary>
    {$ENDREGION}
    property Button4Enabled: Boolean read FButton4Enabled write FButton4Enabled default True;
    {$REGION 'XMLDoc'}
    ///	<summary>
    ///	  Controls whether Button4 is Visible.
    ///	</summary>
    {$ENDREGION}
    property Button4Visible: Boolean read FButton4Visible write FButton4Visible default False;
    {$REGION 'XMLDoc'}
    ///	<summary>
    ///	  This is the event handler for Button4.
    ///	</summary>
    {$ENDREGION}
    property Button4Click: TNotifyEvent read FButton4Click write FButton4Click;
    {$REGION 'XMLDoc'}
    ///	<summary>
    ///	  Allows the Cancel button's caption to be overridden.
    ///	</summary>
    ///	<remarks>
    ///	  Default is 'Caption'.
    ///	</remarks>
    {$ENDREGION}
    property ButtonCancelCaption: string read FButtonCancelCaption write FButtonCancelCaption;
    {$REGION 'XMLDoc'}
    ///	<summary>
    ///	  Controls whether the CancelButton is hidden.
    ///	</summary>
    ///	<remarks>
    ///	  Default is False.
    ///	</remarks>
    {$ENDREGION}
    property ButtonCancelHidden: Boolean read FButtonCancelHidden write FButtonCancelHidden default False;
    {$REGION 'XMLDoc'}
    ///	<summary>
    ///	  Allows the OK button's caption to be overridden.
    ///	</summary>
    ///	<remarks>
    ///	  Default is 'OK'.
    ///	</remarks>
    {$ENDREGION}
    property ButtonOKCaption: string read FButtonOKCaption write FButtonOKCaption;
    {$REGION 'XMLDoc'}
    ///	<summary>
    ///	  Controls whether the OKButton is hidden.
    ///	</summary>
    ///	<remarks>
    ///	  Default is False.
    ///	</remarks>
    {$ENDREGION}
    property ButtonOKHidden: Boolean read FButtonOKHidden write FButtonOKHidden default False;
    {$REGION 'XMLDoc'}
    ///	<summary>
    ///	  The Caption property specifies the caption of the form.
    ///	</summary>
    ///	<remarks>
    ///	  This property is used in the form's call to SetCaption.
    ///	</remarks>
    {$ENDREGION}
    property Caption: string read FCaption write SetCaption;
    {$REGION 'XMLDoc'}
    ///	<summary>
    ///	  This is the ElevateDB table being searched and displayed in the grid.
    ///	</summary>
    {$ENDREGION}
    property LookupTable: TEDBTable read FLookupTable write FLookupTable;
    property GridDblClickSelects: Boolean read FGridDblClickSelects write FGridDblClickSelects default True;
    property HideIndexNames: string read FHideIndexNames write FHideIndexNames;
    property MatchExact: Boolean read FMatchExact write SetMatchExact;
    property MatchPartial: Boolean read FMatchPartial write SetMatchPartial;
    property MisMatchBeep: Boolean read FMisMatchBeep write SetMisMatchBeep;
    property MisMatchMsg: string read FMisMatchMsg write SetMisMatchMsg;
    property MemoFieldName: string read FMemoFieldName write FMemoFieldName;
    property PageRows: Integer read FPageRows write FPageRows default 10;
    {$REGION 'XMLDoc'}
    ///	<summary>
    ///	  This property controls whether the indexes of the associated table
    ///	  are listed.
    ///	</summary>
    ///	<remarks>
    ///	  This property is actually a surfaced property of frmShowIndexList on
    ///	  the embedded form. When execute is called, frmShowIndexList gets a
    ///	  copy of this property and shows or hides the index list.
    ///	</remarks>
    {$ENDREGION}
    property ShowIndexList: Boolean read FShowIndexList write FShowIndexList default True;
    property ShowCloseBox: Boolean read FShowCloseBox write FShowCloseBox default False;
    {$REGION 'XMLDoc'}
    ///	<summary>
    ///	  UseCtrlGrid determines whether a ControlGrid or a regular DBGride is
    ///	  used.
    ///	</summary>
    ///	<remarks>
    ///	  Default is False.
    ///	</remarks>
    {$ENDREGION}
    property UseCtrlGrid: Boolean read FUseCtrlGrid write FUseCtrlGrid default False;
    property OnIndexChanged: TLookupIndexChangedEvent read FOnIndexChanged write FOnIndexChanged;
  end;

implementation

{$R *.dfm}

uses
  {$IFDEF UseCodeSite} CodeSiteLogging, {$ENDIF}
  StrUtils;

procedure TfrmEDBTableLookup.FormActivate(Sender: TObject);
begin
  {$IFDEF UseCodeSite}CodeSite.EnterMethod( Self, 'FormActivate' );{$ENDIF}
  Assert(Assigned(srcLookup.DataSet));
  Assert(srcLookup.DataSet is TEDBTable);

  if FirstTime then begin
    ResetColumns;

    if FfrmUseCtrlGrid then begin
      dbCtrlGrid.BringToFront;
    end else begin
      dbCtrlGrid.SendToBack;
      if FfrmAutoCalcFormWidth then
        CalcFormWidth;
    end;

    if FfrmShowIndexList then
      FillIndexList
    else
      HideIndexList;

    SetIndexFieldNames;
  end;
  edtSearchChars.SetFocus;
  edtSearchChars.SelectAll;
  {$IFDEF UseCodeSite} CodeSite.ExitMethod(self, 'FormActivate'); {$ENDIF}
end;

procedure TfrmEDBTableLookup.FormCreate(Sender: TObject);
begin
  {$IFDEF UseCodeSite} CodeSite.EnterMethod(self, 'FormCreate'); {$ENDIF}
  FfrmGridDblClickSelects := True;
  FfrmGridAllowMultiSelect := False;
  FirstTime := True;
  {$IFDEF UseCodeSite} CodeSite.ExitMethod(self, 'FormCreate'); {$ENDIF}
end;

procedure TfrmEDBTableLookup.btnOKClick(Sender: TObject);

  function FirstIndexField: string;
  var
    i: Integer;
  begin
    {$IFDEF UseCodeSite}CodeSite.EnterMethod( Self, 'FirstIndexField' );{$ENDIF}
    i := Pos(';', FIndexFieldNames);
    if i = 0 then
      Result := FIndexFieldNames
    else
      Result := Copy(FIndexFieldNames, 1, i-1);
    {$IFDEF UseCodeSite}CodeSite.ExitMethod( Self, 'FirstIndexField' );{$ENDIF}
  end;

begin
  {$IFDEF UseCodeSite}CodeSite.EnterMethod( Self, 'btnOKClick' );{$ENDIF}

  if frmMatchExact then begin
    if not SameText(srcLookup.DataSet.FieldByName(FirstIndexField).AsString,
                   Trim(edtSearchChars.Text)) then begin
      ModalResult := mrNone;
      if frmMisMatchBeep then
        MessageBeep(MB_ICONASTERISK);
      if Length(frmMisMatchMsg) > 0 then
        MessageDlg(frmMisMatchMsg, mtWarning, [mbOk], 0);
    end;
  end else if frmMatchPartial then begin
    if not SameText(LeftStr(srcLookup.DataSet.FieldByName(FirstIndexField).AsString, Length(edtSearchChars.Text)),
                        edtSearchChars.Text) then begin
      ModalResult := mrNone;
      if frmMisMatchBeep then
        MessageBeep(MB_ICONASTERISK);
      if Length(frmMisMatchMsg) > 0 then
        MessageDlg(frmMisMatchMsg, mtWarning, [mbOk], 0);
    end;
  end;

  {$IFDEF UseCodeSite}CodeSite.ExitMethod( Self, 'btnOKClick' );{$ENDIF}
end;

procedure TfrmEDBTableLookup.CalcFormWidth;
var
  f, w: Integer;
begin
  {$IFDEF UseCodeSite}CodeSite.EnterMethod( Self, 'CalcFormWidth' );{$ENDIF}

  if btn4.Visible then
    Constraints.MinWidth := 510
  else
    constraints.MinWidth := 432;

  w := self.Width - dbgLookup.Width;

  if Assigned(srcLookup.DataSet) then begin
    for f := 0 to srcLookup.DataSet.Fields.Count - 1 do
      if srcLookup.DataSet.Fields[f].Visible then
        w := w + dbgLookup.Columns[f].Width + 1;
    self.Width := w + GetSystemMetrics(SM_CXVSCROLL) +
                      GetSystemMetrics(SM_CXEDGE) +
                      GetSystemMetrics(SM_CXFIXEDFRAME);
    if Application.MainForm <> nil then
      self.Left := (Screen.Width - self.Width) div 2;
  end;

  Constraints.MinWidth := Width;
  Constraints.MaxWidth := Width;
  {$IFDEF UseCodeSite}CodeSite.ExitMethod( Self, 'CalcFormWidth' );{$ENDIF}
end;

procedure TfrmEDBTableLookup.FillIndexList;
var
  HideIndexList: TStringList;
  i, p: Integer;
begin
  {$IFDEF UseCodeSite}CodeSite.EnterMethod( Self, 'FillIndexList' );{$ENDIF}
  if Assigned(srcLookup.DataSet) then begin
    (srcLookup.DataSet as TEDBTable).IndexDefs.GetItemNames(cmbSearchBy.Items);

    // remove ones we want hidden
    HideIndexList := TStringList.Create;
    try
      HideIndexList.CommaText := FfrmHideIndexNames;
      for i := 0 to HideIndexList.Count - 1 do begin
        p := cmbSearchBy.Items.IndexOf(HideIndexList[i]);
        if p >= 0 then
          cmbSearchBy.Items.Delete(p);
      end;
    finally
      HideIndexList.Free;
    end;

    if Length((srcLookup.DataSet as TEDBTable).IndexName) > 0 then
      cmbSearchBy.ItemIndex := cmbSearchBy.Items.IndexOf((srcLookup.DataSet as TEDBTable).IndexName)
    else
      cmbSearchBy.ItemIndex := cmbSearchBy.Items.IndexOf((srcLookup.DataSet as TEDBTable).IndexFieldNames);
  end;
  {$IFDEF UseCodeSite}CodeSite.ExitMethod( Self, 'FillIndexList' );{$ENDIF}
end;

procedure TfrmEDBTableLookup.HideIndexList;
begin
  {$IFDEF UseCodeSite}CodeSite.EnterMethod( Self, 'HideIndexList' );{$ENDIF}
  cmbSearchBy.Visible := False;
  lblSearchBy.Visible := False;
  if FfrmUseCtrlGrid then
    dbCtrlGrid.Height := dbCtrlGrid.Height + 30
  else
    dbgLookup.Height := dbgLookup.Height + 30;
  {$IFDEF UseCodeSite}CodeSite.ExitMethod( Self, 'HideIndexList' );{$ENDIF}
end;

procedure TfrmEDBTableLookup.SetAllowMultiSelect(const Value: Boolean);
begin
  if Value then
    dbgLookup.Options := dbgLookup.Options + [dgMultiSelect]
  else
    dbgLookup.Options := dbgLookup.Options - [dgMultiSelect];
  FfrmGridAllowMultiSelect := Value;
end;

procedure TfrmEDBTableLookup.SetAutoCalcFormWidth(const Value: Boolean);
begin
  {$IFDEF UseCodeSite}CodeSite.EnterMethod( Self, 'SetAutoCalcFormWidth' );{$ENDIF}
  FfrmAutoCalcFormWidth := Value;
  if FfrmAutoCalcFormWidth then
    FfrmUseCtrlGrid := False;
  {$IFDEF UseCodeSite}CodeSite.ExitMethod( Self, 'SetAutoCalcFormWidth' );{$ENDIF}
end;

procedure TfrmEDBTableLookup.SetCaption(NewCaption: string);
begin
  {$IFDEF UseCodeSite}CodeSite.EnterMethod( Self, 'SetCaption' );{$ENDIF}

  if FfrmGridAllowMultiSelect then
    Caption := NewCaption + ' (Ctrl+Click to select multiple records)'
  else
    Caption := NewCaption;

  {$IFDEF UseCodeSite}CodeSite.ExitMethod( Self, 'SetCaption' );{$ENDIF}
end;

procedure TfrmEDBTableLookup.IncrementalSearch;
var
  SearchLen: Integer;
begin
  {$IFDEF UseCodeSite} CodeSite.EnterMethod(Self, 'IncrementalSearch'); {$ENDIF}

  srcLookup.DataSet.DisableControls;
  try
    srcLookup.DataSet.Locate(FIndexFieldNames, VarArrayOf([edtSearchChars.Text]), [loCaseInsensitive, loPartialKey]);
    if Pos(';', FIndexFieldNames) = 0 then begin
      // this is a single-field index, so let's make sure we have the first indexed match, not the first physical match
      SearchLen := Length(edtSearchChars.Text);
      {$IFDEF UseCodeSite} CodeSite.Send('incremental search on single-field index'); {$ENDIF}
      {$IFDEF UseCodeSite} CodeSite.Send('search length', SearchLen); {$ENDIF}
      {$IFDEF UseCodeSite} CodeSite.ResetCheckPoint; {$ENDIF}
      if SameText(edtSearchChars.Text, LeftStr(srcLookup.DataSet.FieldByName(FIndexFieldNames).AsString, SearchLen)) then
        // if we found one, go backwards in the dataset...
        repeat
          {$IFDEF UseCodeSite} CodeSite.AddCheckPoint; {$ENDIF}
          srcLookup.DataSet.Prior;
          if not SameText(edtSearchChars.Text, LeftStr(srcLookup.DataSet.FieldByName(FIndexFieldNames).AsString, SearchLen)) then begin
            // ... until we have a match, at which point, we're done
            srcLookup.DataSet.Next;
            Break;
          end;
          // ... or until we got to the beginning of the dataset
        until srcLookup.DataSet.Bof;
    end;
  finally
    srcLookup.DataSet.EnableControls;
  end;

  {$IFDEF UseCodeSite} CodeSite.ExitMethod(Self, 'IncrementalSearch');  {$ENDIF}
end;

procedure TfrmEDBTableLookup.ResetColumns;
var
  i: Integer;
begin
  dbgLookup.Columns.RebuildColumns;

  for i := 0 to dbgLookup.DataSource.DataSet.Fields.Count - 1 do
    dbgLookup.Columns[i].Visible := dbgLookup.DataSource.DataSet.Fields[i].Visible;
end;

procedure TfrmEDBTableLookup.SetIndexFieldNames;
var
  i: Integer;
begin
  {$IFDEF UseCodeSite}CodeSite.EnterMethod( Self, 'SetIndexFieldNames' );{$ENDIF}
  FIndexFieldNames := EmptyStr;
  for i := 0 to (srcLookup.DataSet as TEDBTable).IndexDefs.Count - 1 do
    if TEDBTable(srcLookup.DataSet).IndexDefs[i].Name = TEDBTable(srcLookup.DataSet).IndexName then begin
      FIndexFieldNames := TEDBTable(srcLookup.DataSet).IndexDefs[i].Fields;
      Break;
    end;

  i := Pos(';', FIndexFieldNames);
  if i > 0 then
    FIndexFieldNames := Copy(FIndexFieldNames, 1, i-1);

  Assert(Length(FIndexFieldNames) > 0);
  {$IFDEF UseCodeSite}CodeSite.ExitMethod( Self, 'SetIndexFieldNames' );{$ENDIF}
end;

procedure TfrmEDBTableLookup.SetUseCtrlGrid(const Value: Boolean);
begin
  {$IFDEF UseCodeSite}CodeSite.EnterMethod( Self, 'SetUseCtrlGrid' );{$ENDIF}
  FfrmUseCtrlGrid := Value;
  if FfrmUseCtrlGrid then
    FfrmAutoCalcFormWidth := False;
  {$IFDEF UseCodeSite}CodeSite.ExitMethod( Self, 'SetUseCtrlGrid' );{$ENDIF}
end;

procedure TfrmEDBTableLookup.tmrKeystrokeTimer(Sender: TObject);
begin
  tmrKeystroke.Enabled := False;
  IncrementalSearch;
end;

procedure TfrmEDBTableLookup.edtMemoDblClick(Sender: TObject);
begin
  {$IFDEF UseCodeSite}CodeSite.EnterMethod( Self, 'edtMemoDblClick' );{$ENDIF}
  if FfrmGridDblClickSelects then
    ModalResult := mrOK;
  {$IFDEF UseCodeSite}CodeSite.ExitMethod( Self, 'edtMemoDblClick' );{$ENDIF}
end;

procedure TfrmEDBTableLookup.edtSearchCharsChange(Sender: TObject);
begin
  {$IFDEF UseCodeSite}CodeSite.EnterMethod( Self, 'edtSearchCharsChange' );{$ENDIF}

  if Assigned(srcLookup.DataSet) then begin
    // reset the keystroke timer so it doesn't start searching until you stop typing
    tmrKeystroke.Enabled := False;
    tmrKeystroke.Enabled := True;
  end;

  {$IFDEF UseCodeSite}CodeSite.ExitMethod( Self, 'edtSearchCharsChange' );{$ENDIF}
end;

procedure TfrmEDBTableLookup.edtSearchCharsKeyDown(Sender: TObject; var Key: Word;  Shift: TShiftState);
var
  i: Integer;
begin
  {$IFDEF UseCodeSite}CodeSite.EnterMethod( Self, 'edtSearchCharsKeyDown' );{$ENDIF}
  if Assigned(srcLookup.DataSet) then
    case Key of
      VK_DOWN: begin
        srcLookup.DataSet.Next;
      end;
      VK_UP: begin
        srcLookup.DataSet.Prior;
      end;
      VK_HOME: begin
        srcLookup.DataSet.First;
      end;
      VK_END: begin
        srcLookup.DataSet.Last;
      end;
      VK_PRIOR: begin
        for i := 1 to FfrmPageRows do
          srcLookup.DataSet.Prior;
      end;
      VK_NEXT: begin
        for i := 1 to FfrmPageRows do
          srcLookup.DataSet.Next;
      end;
      VK_ESCAPE:
        if btnCancel.Visible and Assigned(btnCancel.Action) then
          btnCancel.Action.Execute
        else
          Close;
    end;
  {$IFDEF UseCodeSite}CodeSite.ExitMethod( Self, 'edtSearchCharsKeyDown' );{$ENDIF}
end;

procedure TfrmEDBTableLookup.cmbSearchByChange(Sender: TObject);
begin
  {$IFDEF UseCodeSite}CodeSite.EnterMethod( Self, 'cmbSearchByChange' );{$ENDIF}

  edtSearchChars.Text := EmptyStr;
  (srcLookup.DataSet as TEDBTable).IndexName := cmbSearchBy.Text;
  srcLookup.DataSet.First;
  SetIndexFieldNames;
  edtSearchChars.SetFocus;
  DoIndexChangedEvent;

  {$IFDEF UseCodeSite}CodeSite.ExitMethod( Self, 'cmbSearchByChange' );{$ENDIF}
end;

procedure TfrmEDBTableLookup.dbCtrlGridDblClick(Sender: TObject);
begin
  {$IFDEF UseCodeSite}CodeSite.EnterMethod( Self, 'dbCtrlGridDblClick' );{$ENDIF}
  if FfrmGridDblClickSelects then
    ModalResult := mrOK;
  {$IFDEF UseCodeSite}CodeSite.ExitMethod( Self, 'dbCtrlGridDblClick' );{$ENDIF}
end;

procedure TfrmEDBTableLookup.dbgLookupDblClick(Sender: TObject);
begin
  {$IFDEF UseCodeSite}CodeSite.EnterMethod( Self, 'dbgLookupDblClick' );{$ENDIF}
  if FfrmGridDblClickSelects then
    ModalResult := mrOK;
  {$IFDEF UseCodeSite}CodeSite.ExitMethod( Self, 'dbgLookupDblClick' );{$ENDIF}
end;

procedure TfrmEDBTableLookup.DoIndexChangedEvent;
begin
  {$IFDEF UseCodeSite}CodeSite.EnterMethod( Self, 'DoIndexChangedEvent' );{$ENDIF}
  if (not (csDesigning in ComponentState)) and Assigned(FfrmOnIndexChanged) then begin
    {$IFDEF UseCodeSite} CodeSite.Send('launching index-changed event', cmbSearchBy.Text); {$ENDIF}
    FfrmOnIndexChanged(cmbSearchBy.Text);
  end;
  {$IFDEF UseCodeSite}CodeSite.ExitMethod( Self, 'DoIndexChangedEvent' );{$ENDIF}
end;

{ TccEDBLookup }

constructor TccEDBLookup.Create(AOwner: TComponent);
begin
  {$IFDEF UseCodeSite}CodeSite.EnterMethod( 'TccEDBLookup.Create' );{$ENDIF}
  inherited;
  {$IFDEF UseCodeSite} CodeSite.Send('name', Name); {$ENDIF}

  FAutoCalcFormWidth := True;
  FGridDblClickSelects := True;
  FPageRows := 3;
  FShowIndexList := True;
  FShowCloseBox := False;
  FUseCtrlGrid := False;
  FAllowMultiSelect := False;

  FButton1Visible := False;
  FButton2Visible := False;
  FButton3Visible := False;
  FButton4Visible := False;

  FButton1Enabled := True;
  FButton2Enabled := True;
  FButton3Enabled := True;
  FButton4Enabled := True;

  FButtonOKCaption := 'O&K';
  FButtonOKHidden := False;
  FButtonCancelCaption := 'Cancel';
  FButtonCancelHidden := False;

  FMatchExact := False;
  FMisMatchBeep := False;
  FMisMatchMsg := EmptyStr;
  {$IFDEF UseCodeSite}CodeSite.ExitMethod( 'TccEDBLookup.Create' );{$ENDIF}
end;

function TccEDBLookup.Execute: Boolean;
begin
  {$IFDEF UseCodeSite} CodeSite.EnterMethod(self, 'TccEDBLookup.Execute'); {$ENDIF}

  Result := False;

  FfrmTableLookup := TfrmEDBTableLookup.Create(nil);
  try
    with FfrmTableLookup do begin
      frmGridDblClickSelects := FGridDblClickSelects;
      frmHideIndexNames := FHideIndexNames;
      frmShowIndexList := FShowIndexList;
      frmPageRows := FPageRows;
      frmUseCtrlGrid := FUseCtrlGrid;
      frmAutoCalcFormWidth := FAutoCalcFormWidth;
      frmMatchExact := FMatchExact;
      frmMatchPartial := FMatchPartial;
      frmMisMatchBeep := FMisMatchBeep;
      frmMisMatchMsg := FMisMatchMsg;

      if (not (csDesigning in ComponentState)) and Assigned(FOnIndexChanged) then begin
        frmOnIndexChanged := FOnIndexchanged;
        {$IFDEF UseCodeSite} CodeSite.Send('assigning index-changed event'); {$ENDIF}
      end;

      if FShowCloseBox then
        BorderIcons := [biSystemMenu];

      btn1.Caption := FButton1Caption;
      btn2.Caption := FButton2Caption;
      btn3.Caption := FButton3Caption;
      btn4.Caption := FButton4Caption;

      btn1.Enabled := FButton1Enabled;
      btn2.Enabled := FButton2Enabled;
      btn3.Enabled := FButton3Enabled;
      btn4.Enabled := FButton4Enabled;

      btn1.Visible := FButton1Visible;
      btn2.Visible := FButton2Visible;
      btn3.Visible := FButton3Visible;
      btn4.Visible := FButton4Visible;

      btn1.OnClick := FButton1Click;
      btn2.OnClick := FButton2Click;
      btn3.OnClick := FButton3Click;
      btn4.OnClick := FButton4Click;

      btnOK.Caption := FButtonOKCaption;
      btnOK.Visible := not FButtonOKHidden;
      btnCancel.Caption := FButtonCancelCaption;
      btnCancel.Visible := not FButtonCancelHidden;

      srcLookup.DataSet := FLookupTable;

      if frmUseCtrlGrid then
        edtMemo.DataField := Trim(FMemoFieldName)
      else
        // if not using the CtrlGrid, then using the DBGrid; this option only applies to DBGrid
        if FAllowMultiSelect then
          // default is false, so don't need to change unless turning on
          frmGridAllowMultiSelect := FAllowMultiSelect;

      if not Assigned(srcLookup.DataSet) then
        raise Exception.Create('LookupTable not set in ' + Name);
      if btn1.Visible and (not Assigned(btn1.OnClick)) then
        raise Exception.Create('OnClick not assigned for Button1 in ' + Name);
      if btn2.Visible and (not Assigned(btn2.OnClick)) then
        raise Exception.Create('OnClick not assigned for Button2 in ' + Name);
      if btn3.Visible and (not Assigned(btn3.OnClick)) then
        raise Exception.Create('OnClick not assgiend for Button3 in ' + Name);
      if btn4.Visible and (not Assigned(btn4.OnClick)) then
        raise Exception.Create('OnClick not assgiend for Button4 in ' + Name);
      if frmUseCtrlGrid and (Length(edtMemo.Field.FieldName) = 0) then
        raise Exception.Create('Memo field name on Control Grid not set in ' + Name);

      SetCaption(FCaption);

      Result := ShowModal = mrOK;
    end;
  finally
    FreeAndNil(FfrmTableLookup);
  end;
  
  {$IFDEF UseCodeSite}CodeSite.ExitMethod( 'TccEDBLookup.Execute' );{$ENDIF}
end;

function TccEDBLookup.GetSelectedRows: TBookmarkList;
begin
  Result := FfrmTableLookup.dbgLookup.SelectedRows;
end;

procedure TccEDBLookup.SetCaption(const Value: string);
begin
  FCaption := Value;
  if Assigned(FfrmTableLookup) then
    FfrmTableLookup.SetCaption(Value);
end;

procedure TccEDBLookup.SetMatchExact(const Value: Boolean);
begin
  FMatchExact := Value;
  if Assigned(FfrmTableLookup) then
    FfrmTableLookup.frmMatchExact := Value;
end;

procedure TccEDBLookup.SetMatchPartial(const Value: Boolean);
begin
  FMatchPartial := Value;
  if Assigned(FfrmTableLookup) then
    FfrmTableLookup.frmMatchPartial := Value;
end;

procedure TccEDBLookup.SetMisMatchBeep(const Value: Boolean);
begin
  FMisMatchBeep := Value;
  if Assigned(FfrmTableLookup) then
    FfrmTableLookup.frmMisMatchBeep := Value;
end;

procedure TccEDBLookup.SetMisMatchMsg(const Value: string);
begin
  FMisMatchMsg := Value;
  if Assigned(FfrmTableLookup) then
    FfrmTableLookup.frmMisMatchMsg := Value;
end;

end.

