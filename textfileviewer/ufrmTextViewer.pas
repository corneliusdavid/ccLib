unit ufrmTextViewer;

interface

uses
  SysUtils, Windows, StdCtrls, Classes, Controls, ExtCtrls, Forms,
  RzDlgBtn, RzEdit, ActnList, Menus, StdActns, Buttons, LayoutSaver;

type
  TfrmTextViewer = class(TForm)
    mmoText: TRzMemo;
    mnuTextViewer: TPopupMenu;
    lsTTextViewerActions: TActionList;
    actTextSizeLarger: TAction;
    actTextSizeSmaller: TAction;
    itmTextSizeLarger: TMenuItem;
    itmTextSizeSmaller: TMenuItem;
    actEditCopy: TEditCopy;
    actEditSelectAll: TEditSelectAll;
    N1: TMenuItem;
    itmTextEditCopy: TMenuItem;
    itmTextEditSelectAll: TMenuItem;
    N2: TMenuItem;
    itmTextViewerDone: TMenuItem;
    actDone: TAction;
    RzDialogButtons: TRzDialogButtons;
    procedure actTextSizeLargerExecute(Sender: TObject);
    procedure actTextSizeSmallerExecute(Sender: TObject);
    procedure actDoneExecute(Sender: TObject);
  end;

  TccTextViewer = class(TComponent)
  private
    FFileName: string;
    procedure ShowTextViewer;
  public
    procedure Execute; overload;
    procedure Execute(const fn: string); overload;
  published
    property FileName: string read FFileName write FFileName;
  end;


const
  CurrTextSizeIndex: Integer = 3; // --->>>> this should be saved as a user setting
var
  frmTextViewer: TfrmTextViewer; // default variable for global use


implementation

{$R *.DFM}

{ TfrmTextViewer }

const
  MaxTextSizes = 14;
  TextSizes: array[1..MaxTextSizes] of Integer = (8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 36, 48, 72);


procedure TfrmTextViewer.actTextSizeLargerExecute(Sender: TObject);
begin
  if CurrTextSizeIndex < MaxTextSizes then
  begin
    Inc(CurrTextSizeIndex);
    mmoText.Font.Size := TextSizes[CurrTextSizeIndex];
    if CurrTextSizeIndex = MaxTextSizes then
      actTextSizeLarger.Enabled := False;
    actTextSizeSmaller.Enabled := True;
  end;
end;

procedure TfrmTextViewer.actTextSizeSmallerExecute(Sender: TObject);
begin
  if CurrTextSizeIndex > 1 then
  begin
    Dec(CurrTextSizeIndex);
    mmoText.Font.Size := TextSizes[CurrTextSizeIndex];
    if CurrTextSizeIndex = 1 then
      actTextSizeSmaller.Enabled := False;
    actTextSizeLarger.Enabled := True;
  end;
end;


procedure TfrmTextViewer.actDoneExecute(Sender: TObject);
begin
  Close;
end;

{ TccTextViewer }

procedure TccTextViewer.ShowTextViewer;
var
  LocalTextViewer: TfrmTextViewer;
begin
  LocalTextViewer := TfrmTextViewer.Create(nil);
  try
    LocalTextViewer.mmoText.Lines.LoadFromFile(FFileName);
    LocalTextviewer.mmoText.Font.Size := TextSizes[CurrTextSizeIndex];
    LocalTextviewer.Caption := FFileName;
    LocalTextViewer.ShowModal;
  finally
    FreeAndNil(LocalTextViewer);
  end;
end;

procedure TccTextViewer.Execute;
var
  s: string;
const
  sTextFileViewer = 'Text file Viewer';
begin
  if Length(FFileName) = 0 then begin
    s := 'Error - no file name given.';
    Application.MessageBox(PChar(s), PChar(sTextFileViewer), MB_OK + MB_DEFBUTTON1 + MB_ICONERROR);
  end else if not FileExists(FFileName) then begin
    s := 'Error - could not find the file, "' + FFileName + '"';
    Application.MessageBox(PChar(s), PChar(sTextFileViewer), MB_OK + MB_DEFBUTTON1 + MB_ICONERROR);
  end else
    ShowTextViewer;
end;

procedure TccTextViewer.Execute(const fn: string);
begin
  FFileName := fn;
  Execute;
end;

end.
