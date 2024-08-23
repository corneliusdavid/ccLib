unit ufrmIniLayoutSaverDemo;

interface

uses
  Forms, SysUtils, Variants, Classes,
  {$IFDEF XE2orHigher}
  Vcl.Graphics, Vcl.Mask, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Samples.Spin,
  {$ELSE}
  Spin, StdCtrls, Controls, ExtCtrls,
  {$ENDIF}
  LayoutSaver;

type
  TfrmIniLayoutSaver = class(TForm)
    edtStrValue: TLabeledEdit;
    edtBoolValue: TCheckBox;
    edtIntValue: TSpinEdit;
    Label1: TLabel;
    ccIniLayoutSaver1: TccIniLayoutSaver;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  end;

var
  frmIniLayoutSaver: TfrmIniLayoutSaver;

implementation

{$R *.dfm}

const
  sIntValName = 'an integer value';
  sBoolValName = 'a boolean value';
  sStringValName = 'a string value';

procedure TfrmIniLayoutSaver.FormCreate(Sender: TObject);
begin
  edtStrValue.Text := ccIniLayoutSaver1.RestoreStrValue(sStringValName);
  edtBoolValue.Checked := ccIniLayoutSaver1.RestoreBoolValue(sBoolValName);
  edtIntValue.Value := ccIniLayoutSaver1.RestoreIntValue(sIntValName);
end;

procedure TfrmIniLayoutSaver.FormDestroy(Sender: TObject);
begin
  ccIniLayoutSaver1.SaveIntValue(sIntValName, edtIntValue.Value);
  ccIniLayoutSaver1.SaveBoolValue(sBoolValName, edtBoolValue.Checked);
  ccIniLayoutSaver1.SaveStrValue(sStringValName, edtStrValue.Text);
end;

end.
