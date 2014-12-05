unit ufrmDBISAMTableLookup;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Mask, Db, Grids, DBGrids, Buttons, DBCtrls,
  {$IFDEF UseCodeSite} CodeSiteLogging, {$ENDIF}
  DBCGrids, DBISAMtb, RzEdit, RzCmboBx, RzDBGrid, RzCommon, RzPanel, RzDlgBtn, RzButton,
  ActnList;

type
  TLookupIndexChangedEvent = procedure (const NewIndexName: string) of Object;

  TfrmTableLookup = class(TForm)
    SearchCharacterLabel: TLabel;
    lblSearchBy: TLabel;
    dbCtrlGrid: TDBCtrlGrid;
    edtMemo: TDBMemo;
    Label1: TLabel;
    btn1: TRzBitBtn;
    btn2: TRzBitBtn;
    btn3: TRzBitBtn;
    RzDialogBtns: TRzDialogButtons;
    cmbSearchBy: TRzComboBox;
    edtSearchChars: TRzEdit;
    srcLookup: TDataSource;
    dbgLookup: TRzDBGrid;
    btn4: TRzBitBtn;
    procedure cmbSearchByChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure edtSearchCharsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edtSearchCharsChange(Sender: TObject);
    procedure dbgLookupDblClick(Sender: TObject);
    procedure dbCtrlGridDblClick(Sender: TObject);
    procedure edtMemoDblClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure RzDialogBtnsClickOk(Sender: TObject);
  strict private
    FirstTime: Boolean;
    FIndexFieldNames: string;
    FfrmAutoCalcFormWidth: Boolean;
    FfrmShowIndexList: Boolean;
    FfrmPageRows: Integer;
    FfrmUseCtrlGrid: Boolean;
    FfrmGridDblClickSelects: Boolean;
    FFrameController: TRzFrameController;
    FfrmMisMatchMsg: string;
    FfrmMatchExact: Boolean;
    FfrmMisMatchBeep: Boolean;
    FfrmOnIndexChanged: TLookupIndexChangedEvent;
    FfrmOnLookupOK: TNotifyEvent;
    FfrmOnLookupCancel: TNotifyEvent;
    procedure CalcFormWidth;
    procedure FillIndexList;
    procedure HideIndexList;
    procedure SetIndexFieldNames;
    procedure SetAutoCalcFormWidth(const Value: Boolean);
    procedure SetUseCtrlGrid(const Value: Boolean);
    procedure SetFrameController(const Value: TRzFrameController);
    procedure DoIndexChangedEvent;
  public
    procedure SetCaption(NewCaption: string);
    property frmAutoCalcFormWidth: Boolean read FfrmAutoCalcFormWidth write SetAutoCalcFormWidth default True;
    property frmGridDblClickSelects: Boolean read FfrmGridDblClickSelects write FfrmGridDblClickSelects default True;
    property frmPageRows: Integer read FfrmPageRows write FfrmPageRows default 10;
    property frmShowIndexList: Boolean read FfrmShowIndexList write FfrmShowIndexList default True;
    property frmUseCtrlGrid: Boolean read FfrmUseCtrlGrid write SetUseCtrlGrid default False;
    property FrameController: TRzFrameController read FFrameController write SetFrameController;
    property frmMatchExact: Boolean read FfrmMatchExact write FfrmMatchExact;
    property frmMisMatchBeep: Boolean read FfrmMisMatchBeep write FfrmMisMatchBeep;
    property frmMisMatchMsg: string read FfrmMisMatchMsg write FfrmMisMatchMsg;
    property frmOnIndexChanged: TLookupIndexChangedEvent read FfrmOnIndexChanged write FfrmOnIndexChanged;
    property frmOnLookupOK: TNotifyEvent read FfrmOnLookupOK write FfrmOnLookupOK;
    property frmOnLookupCancel: TNotifyEvent read FfrmOnLookupCancel write FfrmOnLookupCancel;
  end;

  TccDBISAMLookup = class(TComponent)
  strict private
    FAutoCalcFormWidth: Boolean;
    FCaption: string;
    FLookupTable: TDBISAMTable;
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
    FMatchExact: Boolean;
    FMisMatchBeep: Boolean;
    FMisMatchMsg: string;
    FOnIndexChanged: TLookupIndexChangedEvent;
  private
    FfrmTableLookup: TfrmTableLookup;
    procedure SetMatchExact(const Value: Boolean);
    procedure SetMisMatchBeep(const Value: Boolean);
    procedure SetMisMatchMsg(const Value: string);
    procedure SetCaption(const Value: string);
  public
    constructor Create(AOwner: TComponent); override;
    function Execute: Boolean;
  published
    property AutoCalcFormWidth: Boolean read FAutoCalcFormWidth write FAutoCalcFormWidth default True;
    property Button1Caption: string read FButton1Caption write FButton1Caption;
    property Button1Enabled: Boolean read FButton1Enabled write FButton1Enabled default True;
    property Button1Visible: Boolean read FButton1Visible write FButton1Visible default False;
    property Button1Click: TNotifyEvent read FButton1Click write FButton1Click;
    property Button2Caption: string read FButton2Caption write FButton2Caption;
    property Button2Enabled: Boolean read FButton2Enabled write FButton2Enabled default True;
    property Button2Visible: Boolean read FButton2Visible write FButton2Visible default False;
    property Button2Click: TNotifyEvent read FButton2Click write FButton2Click;
    property Button3Caption: string read FButton3Caption write FButton3Caption;
    property Button3Enabled: Boolean read FButton3Enabled write FButton3Enabled default True;
    property Button3Visible: Boolean read FButton3Visible write FButton3Visible default False;
    property Button3Click: TNotifyEvent read FButton3Click write FButton3Click;
    property Button4Caption: string read FButton4Caption write FButton4Caption;
    property Button4Enabled: Boolean read FButton4Enabled write FButton4Enabled default True;
    property Button4Visible: Boolean read FButton4Visible write FButton4Visible default False;
    property Button4Click: TNotifyEvent read FButton4Click write FButton4Click;
    property ButtonCancelCaption: string read FButtonCancelCaption write FButtonCancelCaption;
    property ButtonCancelHidden: Boolean read FButtonCancelHidden write FButtonCancelHidden default False;
    property ButtonOKCaption: string read FButtonOKCaption write FButtonOKCaption;
    property ButtonOKHidden: Boolean read FButtonOKHidden write FButtonOKHidden default False;
    property Caption: string read FCaption write SetCaption;
    property LookupTable: TDBISAMTable read FLookupTable write FLookupTable;
    property GridDblClickSelects: Boolean read FGridDblClickSelects write FGridDblClickSelects default True;
    property MatchExact: Boolean read FMatchExact write SetMatchExact;
    property MisMatchBeep: Boolean read FMisMatchBeep write SetMisMatchBeep;
    property MisMatchMsg: string read FMisMatchMsg write SetMisMatchMsg;
    property MemoFieldName: string read FMemoFieldName write FMemoFieldName;
    property PageRows: Integer read FPageRows write FPageRows default 10;
    property ShowIndexList: Boolean read FShowIndexList write FShowIndexList default True;
    property ShowCloseBox: Boolean read FShowCloseBox write FShowCloseBox default False;
    property UseCtrlGrid: Boolean read FUseCtrlGrid write FUseCtrlGrid default False;
    property OnIndexChanged: TLookupIndexChangedEvent read FOnIndexChanged write FOnIndexChanged;
  end;

implementation

{$R *.dfm}

procedure TfrmTableLookup.FormActivate(Sender: TObject);
begin
  {$IFDEF UseCodeSite}CodeSite.EnterMethod( Self, 'FormActivate' );{$ENDIF}
  Assert(Assigned(srcLookup.DataSet));
  Assert(srcLookup.DataSet is TDBISAMTable);

  if FirstTime then begin
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
  {$IFDEF UseCodeSite}CodeSite.ExitMethod( Self, 'FormActivate' );{$ENDIF}
end;

procedure TfrmTableLookup.FormCreate(Sender: TObject);
begin
  {$IFDEF UseCodeSite}CodeSite.EnterMethod( Self, 'FormCreate' );{$ENDIF}
  FfrmGridDblClickSelects := True;
  FirstTime := True;
  {$IFDEF UseCodeSite}CodeSite.ExitMethod( Self, 'FormCreate' );{$ENDIF}
end;

procedure TfrmTableLookup.CalcFormWidth;
var
  f, c, w: Integer;
begin
  {$IFDEF UseCodeSite}CodeSite.EnterMethod( Self, 'CalcFormWidth' );{$ENDIF}

  if btn4.Visible then
    Constraints.MinWidth := 510
  else 
    constraints.MinWidth := 432;

  w := self.Width - dbgLookup.Width;
  c := 0;

  if Assigned(srcLookup.DataSet) then begin
    for f := 0 to srcLookup.DataSet.Fields.Count - 1 do
      if srcLookup.DataSet.Fields[f].Visible then begin
        w := w + dbgLookup.Columns[c].Width + 1;
        Inc(c);
      end;
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

procedure TfrmTableLookup.FillIndexList;
begin
  {$IFDEF UseCodeSite}CodeSite.EnterMethod( Self, 'FillIndexList' );{$ENDIF}
  if Assigned(srcLookup.DataSet) then begin
    (srcLookup.DataSet as TDBISAMTable).IndexDefs.GetItemNames(cmbSearchBy.Items);
    if Length((srcLookup.DataSet as TDBISAMTable).IndexName) > 0 then
      cmbSearchBy.ItemIndex := cmbSearchBy.Items.IndexOf((srcLookup.DataSet as TDBISAMTable).IndexName)
    else
      cmbSearchBy.ItemIndex := cmbSearchBy.Items.IndexOf((srcLookup.DataSet as TDBISAMTable).IndexFieldNames);
  end;
  {$IFDEF UseCodeSite}CodeSite.ExitMethod( Self, 'FillIndexList' );{$ENDIF}
end;

procedure TfrmTableLookup.HideIndexList;
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

procedure TfrmTableLookup.RzDialogBtnsClickOk(Sender: TObject);

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
  {$IFDEF UseCodeSite}CodeSite.EnterMethod( Self, 'RzDialogBtnsClickOk' );{$ENDIF}
  if frmMatchExact then
    if UpperCase(srcLookup.DataSet.FieldByName(FirstIndexField).AsString) <>
                   UpperCase(Trim(edtSearchChars.Text)) then begin
      ModalResult := mrNone;
      if frmMisMatchBeep then
        MessageBeep(MB_ICONASTERISK);
      if Length(frmMisMatchMsg) > 0 then
        MessageDlg(frmMisMatchMsg, mtWarning, [mbOk], 0);
    end;
  {$IFDEF UseCodeSite}CodeSite.ExitMethod( Self, 'RzDialogBtnsClickOk' );{$ENDIF}
end;

procedure TfrmTableLookup.SetAutoCalcFormWidth(const Value: Boolean);
begin
  {$IFDEF UseCodeSite}CodeSite.EnterMethod( Self, 'SetAutoCalcFormWidth' );{$ENDIF}
  FfrmAutoCalcFormWidth := Value;
  if FfrmAutoCalcFormWidth then
    FfrmUseCtrlGrid := False;
  {$IFDEF UseCodeSite}CodeSite.ExitMethod( Self, 'SetAutoCalcFormWidth' );{$ENDIF}
end;

procedure TfrmTableLookup.SetCaption(NewCaption: string);
begin
  {$IFDEF UseCodeSite}CodeSite.EnterMethod( Self, 'SetCaption' );{$ENDIF}
  Caption := NewCaption;
  {$IFDEF UseCodeSite}CodeSite.ExitMethod( Self, 'SetCaption' );{$ENDIF}
end;

procedure TfrmTableLookup.SetFrameController(const Value: TRzFrameController);
begin
  {$IFDEF UseCodeSite}CodeSite.EnterMethod( Self, 'SetFrameController' );{$ENDIF}
  FFrameController := Value;
  edtSearchChars.FrameController := FFramecontroller;
  dbgLookup.FrameController := FFrameController;
  cmbSearchBy.FrameController := FFrameController;
  {$IFDEF UseCodeSite}CodeSite.ExitMethod( Self, 'SetFrameController' );{$ENDIF}
end;

procedure TfrmTableLookup.SetIndexFieldNames;
var
  i: Integer;
begin
  {$IFDEF UseCodeSite}CodeSite.EnterMethod( Self, 'SetIndexFieldNames' );{$ENDIF}
  FIndexFieldNames := EmptyStr;
  for i := 0 to (srcLookup.DataSet as TDBISAMTable).IndexDefs.Count - 1 do
    if TDBISAMTable(srcLookup.DataSet).IndexDefs[i].Name = TDBISAMTable(srcLookup.DataSet).IndexName then begin
      FIndexFieldNames := TDBISAMTable(srcLookup.DataSet).IndexDefs[i].Fields;
      Break;
    end;

  i := Pos(';', FIndexFieldNames);
  if i > 0 then
    FIndexFieldNames := Copy(FIndexFieldNames, 1, i-1);

  Assert(Length(FIndexFieldNames) > 0);
  {$IFDEF UseCodeSite}CodeSite.ExitMethod( Self, 'SetIndexFieldNames' );{$ENDIF}
end;

procedure TfrmTableLookup.SetUseCtrlGrid(const Value: Boolean);
begin
  {$IFDEF UseCodeSite}CodeSite.EnterMethod( Self, 'SetUseCtrlGrid' );{$ENDIF}
  FfrmUseCtrlGrid := Value;
  if FfrmUseCtrlGrid then
    FfrmAutoCalcFormWidth := False;
  {$IFDEF UseCodeSite}CodeSite.ExitMethod( Self, 'SetUseCtrlGrid' );{$ENDIF}
end;

procedure TfrmTableLookup.edtMemoDblClick(Sender: TObject);
begin
  {$IFDEF UseCodeSite}CodeSite.EnterMethod( Self, 'edtMemoDblClick' );{$ENDIF}
  if FfrmGridDblClickSelects then
    ModalResult := mrOK;
  {$IFDEF UseCodeSite}CodeSite.ExitMethod( Self, 'edtMemoDblClick' );{$ENDIF}
end;

procedure TfrmTableLookup.edtSearchCharsChange(Sender: TObject);
begin
  {$IFDEF UseCodeSite}CodeSite.EnterMethod( Self, 'edtSearchCharsChange' );{$ENDIF}
  if Assigned(srcLookup.DataSet) then
    TDBISAMTable(srcLookup.DataSet).Locate(FIndexFieldNames, VarArrayOf([edtSearchChars.Text]),
                   [loCaseInsensitive, loPartialKey]);
  {$IFDEF UseCodeSite}CodeSite.ExitMethod( Self, 'edtSearchCharsChange' );{$ENDIF}
end;

procedure TfrmTableLookup.edtSearchCharsKeyDown(Sender: TObject; var Key: Word;  Shift: TShiftState);
var
  i: Integer;
begin
  {$IFDEF UseCodeSite}CodeSite.EnterMethod( Self, 'edtSearchCharsKeyDown' );{$ENDIF}
  if Assigned(srcLookup.DataSet) then
    case Key of
      VK_DOWN:
        srcLookup.DataSet.Next;
      VK_UP:
        srcLookup.DataSet.Prior;
      VK_HOME:
        srcLookup.DataSet.First;
      VK_END:
        srcLookup.DataSet.Last;
      VK_PRIOR:
        for i := 1 to FfrmPageRows do
          srcLookup.DataSet.Prior;
      VK_NEXT:
        for i := 1 to FfrmPageRows do
          srcLookup.DataSet.Next;
      VK_ESCAPE:
        RzDialogBtns.ActionCancel.Execute;
    end;
  {$IFDEF UseCodeSite}CodeSite.ExitMethod( Self, 'edtSearchCharsKeyDown' );{$ENDIF}
end;

procedure TfrmTableLookup.cmbSearchByChange(Sender: TObject);
begin
  {$IFDEF UseCodeSite}CodeSite.EnterMethod( Self, 'cmbSearchByChange' );{$ENDIF}
  (srcLookup.DataSet as TDBISAMTable).IndexName := cmbSearchBy.Text;
  edtSearchChars.Text := EmptyStr;
  srcLookup.DataSet.First;
  SetIndexFieldNames;
  edtSearchChars.SetFocus;
  DoIndexChangedEvent;
  {$IFDEF UseCodeSite}CodeSite.ExitMethod( Self, 'cmbSearchByChange' );{$ENDIF}
end;

procedure TfrmTableLookup.dbCtrlGridDblClick(Sender: TObject);
begin
  {$IFDEF UseCodeSite}CodeSite.EnterMethod( Self, 'dbCtrlGridDblClick' );{$ENDIF}
  if FfrmGridDblClickSelects then
    ModalResult := mrOK;
  {$IFDEF UseCodeSite}CodeSite.ExitMethod( Self, 'dbCtrlGridDblClick' );{$ENDIF}
end;

procedure TfrmTableLookup.dbgLookupDblClick(Sender: TObject);
begin
  {$IFDEF UseCodeSite}CodeSite.EnterMethod( Self, 'dbgLookupDblClick' );{$ENDIF}
  if FfrmGridDblClickSelects then
    ModalResult := mrOK;
  {$IFDEF UseCodeSite}CodeSite.ExitMethod( Self, 'dbgLookupDblClick' );{$ENDIF}
end;

procedure TfrmTableLookup.DoIndexChangedEvent;
begin
  {$IFDEF UseCodeSite}CodeSite.EnterMethod( Self, 'DoIndexChangedEvent' );{$ENDIF}
  if (not (csDesigning in ComponentState)) and Assigned(FfrmOnIndexChanged) then begin
    {$IFDEF UseCodeSite} CodeSite.Send('launching index-changed event', cmbSearchBy.Text); {$ENDIF}
    FfrmOnIndexChanged(cmbSearchBy.Text);
  end;
  {$IFDEF UseCodeSite}CodeSite.ExitMethod( Self, 'DoIndexChangedEvent' );{$ENDIF}
end;

{ TccDBISAMLookup }

constructor TccDBISAMLookup.Create(AOwner: TComponent);
begin
  {$IFDEF UseCodeSite}CodeSite.EnterMethod( 'TccDBISAMLookup.Create' );{$ENDIF}
  inherited;

  FAutoCalcFormWidth := True;
  FGridDblClickSelects := True;
  FPageRows := 3;
  FShowIndexList := True;
  FShowCloseBox := False;
  FUseCtrlGrid := False;

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
  {$IFDEF UseCodeSite}CodeSite.ExitMethod( 'TccDBISAMLookup.Create' );{$ENDIF}
end;

function TccDBISAMLookup.Execute: Boolean;
begin
  {$IFDEF UseCodeSite}CodeSite.EnterMethod( 'TccDBISAMLookup.Execute' );{$ENDIF}
  Result := False;
  FfrmTableLookup := TfrmTableLookup.Create(nil);
  try
    with FfrmTableLookup do begin
      SetCaption(FCaption);
      frmGridDblClickSelects := FGridDblClickSelects;
      frmShowIndexList := FShowIndexList;
      frmPageRows := FPageRows;
      frmUseCtrlGrid := FUseCtrlGrid;
      frmAutoCalcFormWidth := FAutoCalcFormWidth;
      frmMatchExact := FMatchExact;
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

      RzDialogBtns.CaptionOK := FButtonOKCaption;
      RzDialogBtns.BtnOK.Visible := not FButtonOKHidden;
      RzDialogBtns.CaptionCancel := FButtonCancelCaption;
      RzDialogBtns.BtnCancel.Visible := not FButtonCancelHidden;

      srcLookup.DataSet := FLookupTable;

      if frmUseCtrlGrid then
        edtMemo.DataField := Trim(FMemoFieldName);

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

      Result := ShowModal = mrOK;
    end;
  finally
    FreeAndNil(FfrmTableLookup);
  end;
  {$IFDEF UseCodeSite}CodeSite.ExitMethod( 'TccDBISAMLookup.Execute' );{$ENDIF}
end;

procedure TccDBISAMLookup.SetCaption(const Value: string);
begin
  FCaption := Value;
  FfrmTableLookup.SetCaption(FCaption);
end;

procedure TccDBISAMLookup.SetMatchExact(const Value: Boolean);
begin
  FMatchExact := Value;
  if Assigned(FfrmTableLookup) then
    FfrmTableLookup.frmMatchExact := Value;
end;

procedure TccDBISAMLookup.SetMisMatchBeep(const Value: Boolean);
begin
  FMisMatchBeep := Value;
  if Assigned(FfrmTableLookup) then
    FfrmTableLookup.frmMisMatchBeep := Value;
end;

procedure TccDBISAMLookup.SetMisMatchMsg(const Value: string);
begin
  FMisMatchMsg := Value;
  if Assigned(FfrmTableLookup) then
    FfrmTableLookup.frmMisMatchMsg := Value;
end;

end.

