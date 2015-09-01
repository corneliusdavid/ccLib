unit ufrmRegLayoutSaverDemo;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Samples.Spin, LayoutSaver;

type
  TfrmRegLayoutSaver = class(TForm)
    edtStrValue: TLabeledEdit;
    edtBoolValue: TCheckBox;
    edtIntValue: TSpinEdit;
    Label1: TLabel;
    ccRegistryLayoutSaver1: TccRegistryLayoutSaver;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  end;

var
  frmRegLayoutSaver: TfrmRegLayoutSaver;

implementation

{$R *.dfm}

const
  sIntValName = 'an integer value';
  sBoolValName = 'a boolean value';
  sStringValName = 'a string value';

procedure TfrmRegLayoutSaver.FormCreate(Sender: TObject);
begin
  edtStrValue.Text := ccRegistryLayoutSaver1.ResstoreStrValue(sStringValName);
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
