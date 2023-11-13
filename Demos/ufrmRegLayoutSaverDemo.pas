unit ufrmRegLayoutSaverDemo;

interface

uses
  SysUtils, Variants, Classes, Graphics, Spin, StdCtrls,
  Forms, Controls, ExtCtrls, LayoutSaver;

type
  TfrmRegLayoutSaver = class(TForm)
    edtStrValue: TLabeledEdit;
    edtBoolValue: TCheckBox;
    edtIntValue: TSpinEdit;
    Label1: TLabel;
    ccRegistryLayoutSaver1: TccRegistryLayoutSaver;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ccRegistryLayoutSaver1BeforeRestore(Sender: TObject);
    procedure ccRegistryLayoutSaver1BeforeSave(Sender: TObject);
  end;

var
  frmRegLayoutSaver: TfrmRegLayoutSaver;

implementation

{$R *.dfm}

uses
  Dialogs;

const
  sIntValName = 'an integer value';
  sBoolValName = 'a boolean value';
  sStringValName = 'a string value';

procedure TfrmRegLayoutSaver.ccRegistryLayoutSaver1BeforeRestore(Sender: TObject);
begin
  ShowMessage('restoring from ' + ccRegistryLayoutSaver1.Location + ' / ' + ccRegistryLayoutSaver1.Section);
end;

procedure TfrmRegLayoutSaver.ccRegistryLayoutSaver1BeforeSave(Sender: TObject);
begin
  ShowMessage('saving to ' + ccRegistryLayoutSaver1.Location + ' / ' + ccRegistryLayoutSaver1.Section);
end;

procedure TfrmRegLayoutSaver.FormCreate(Sender: TObject);
begin
  edtStrValue.Text := ccRegistryLayoutSaver1.RestoreStrValue(sStringValName);
  edtBoolValue.Checked := ccRegistryLayoutSaver1.RestoreBoolValue(sBoolValName);
  edtIntValue.Value := ccRegistryLayoutSaver1.RestoreIntValue(sIntValName);
end;

procedure TfrmRegLayoutSaver.FormDestroy(Sender: TObject);
begin
  ccRegistryLayoutSaver1.SaveIntValue(sIntValName, edtIntValue.Value);
  ccRegistryLayoutSaver1.SaveBoolValue(sBoolValName, edtBoolValue.Checked);
  ccRegistryLayoutSaver1.SaveStrValue(sStringValName, edtStrValue.Text);
end;

end.
